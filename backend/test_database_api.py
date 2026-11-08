"""
Integration Test for PoultryCare Backend API & Database Persistence Layer.
Verifies the complete Chapter 5 write-path:
scans -> predictions -> feedback -> history retrieval.
"""

import sys
import io
import json
import base64
import unittest
from pathlib import Path
from PIL import Image

PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from backend.db import SessionLocal
from backend.models_db import Scan, Prediction, Feedback, Disease
from backend.inference_server import (
    preprocess_image,
    run_model_inference,
    assess_postprocessing,
    save_diagnosis_to_db,
    compute_image_hash,
)


class TestDatabaseAndAPI(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # Create a sample test image in memory
        img = Image.new("RGB", (300, 300), color=(120, 150, 80))
        buf = io.BytesIO()
        img.save(buf, format="JPEG")
        cls.test_image_bytes = buf.getvalue()

    def test_1_diseases_table_seeded(self):
        """Verifies diseases table contains the 4 classes in English and Urdu."""
        db = SessionLocal()
        try:
            diseases = db.query(Disease).all()
            codes = [d.code for d in diseases]
            self.assertIn("coccidiosis", codes)
            self.assertIn("healthy", codes)
            self.assertIn("ncd", codes)
            self.assertIn("salmonella", codes)
            for d in diseases:
                self.assertTrue(len(d.name_en) > 0)
                self.assertTrue(len(d.name_ur) > 0)
                self.assertTrue(len(d.signs_en) > 0)
            print(f"[Test PASS] Diseases reference table has {len(diseases)} classes.")
        finally:
            db.close()

    def test_2_diagnosis_write_path(self):
        """Verifies that running diagnosis creates persistent rows in scans and predictions."""
        tensor, orig_w, orig_h = preprocess_image(self.test_image_bytes)
        probs, inf_ms = run_model_inference(tensor, forced_disease="Coccidiosis")
        flock_signals = {"mortality": "high", "spread": "rapid"}
        result = assess_postprocessing(probs, flock_signals)
        latencies = {"preprocess_ms": 12.5, "inference_ms": inf_ms, "total_ms": inf_ms + 12.5}
        img_hash = compute_image_hash(self.test_image_bytes)

        scan_id = save_diagnosis_to_db(
            image_hash=img_hash,
            orig_w=orig_w,
            orig_h=orig_h,
            flock_signals=flock_signals,
            result=result,
            latencies=latencies,
        )

        self.assertIsNotNone(scan_id)

        # Verify in database
        db = SessionLocal()
        try:
            saved_scan = db.query(Scan).filter_by(id=scan_id).first()
            self.assertIsNotNone(saved_scan)
            self.assertEqual(saved_scan.image_width, 300)
            self.assertEqual(saved_scan.image_height, 300)

            saved_pred = db.query(Prediction).filter_by(scan_id=scan_id).first()
            self.assertIsNotNone(saved_pred)
            self.assertEqual(saved_pred.predicted_class, "coccidiosis")
            self.assertEqual(saved_pred.severity, "severe")  # Escalated due to mortality
            self.assertEqual(saved_pred.certainty, "confident")
            print(f"[Test PASS] Diagnosis write-path verified! Scan ID: {scan_id}")
            self.__class__.created_scan_id = scan_id
        finally:
            db.close()

    def test_3_feedback_submission(self):
        """Verifies submitting feedback linked to the created scan."""
        scan_id = getattr(self.__class__, "created_scan_id", None)
        self.assertIsNotNone(scan_id)

        db = SessionLocal()
        try:
            fb = Feedback(
                scan_id=scan_id,
                was_helpful=True,
                confirmed_by_vet=True,
                comment="Confirmed by Dr. Tariq via fecal microscopy.",
            )
            db.add(fb)
            db.commit()

            saved_fb = db.query(Feedback).filter_by(scan_id=scan_id).first()
            self.assertIsNotNone(saved_fb)
            self.assertTrue(saved_fb.was_helpful)
            self.assertTrue(saved_fb.confirmed_by_vet)
            print("[Test PASS] Feedback table correctly recorded veterinarian confirmation.")
        finally:
            db.close()


if __name__ == "__main__":
    unittest.main()

