#!/usr/bin/env python3
"""
Unit and Integration Test Suite for PoultryCare ML Inference Pipeline
Verifies preprocessing pipeline, input tensor shapes, dtype, severity thresholds,
and triage signal integration.
"""

import sys
import io
import json
from pathlib import Path
from PIL import Image
import numpy as np

# Add backend directory to sys.path
BACKEND_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(BACKEND_DIR))

from inference_server import (
    preprocess_image,
    run_model_inference,
    assess_postprocessing,
    CLASS_NAMES,
    SEVERITY_CONFIG,
    IMG_SIZE,
)


def test_preprocessing():
    print("\n--- Test 1: Preprocessing Pipeline Contract ---")
    # Create synthetic test image (e.g. 512x384 RGB)
    synthetic_img = Image.new("RGB", (512, 384), color=(140, 180, 95))
    buf = io.BytesIO()
    synthetic_img.save(buf, format="JPEG")
    image_bytes = buf.getvalue()

    tensor = preprocess_image(image_bytes)

    assert tensor.shape == (1, 224, 224, 3), f"Expected shape (1, 224, 224, 3), got {tensor.shape}"
    assert tensor.dtype == np.float32, f"Expected dtype float32, got {tensor.dtype}"
    assert tensor.min() >= 0.0 and tensor.max() <= 255.0, f"Values outside 0..255 range: min={tensor.min()}, max={tensor.max()}"
    print(f" PASS: Shape={tensor.shape}, Dtype={tensor.dtype}, Min={tensor.min():.1f}, Max={tensor.max():.1f}")


def test_severity_thresholds():
    print("\n--- Test 2: Severity Assessment & Calibration Rules ---")

    # 1. Healthy prediction
    healthy_probs = np.array([0.01, 0.96, 0.01, 0.02], dtype=np.float32)
    res_healthy = assess_postprocessing(healthy_probs)
    assert res_healthy["status"] == "healthy", f"Expected healthy, got {res_healthy['status']}"
    assert res_healthy["severity"] is None, f"Expected no severity for healthy, got {res_healthy['severity']}"
    assert res_healthy["urgency"] == "monitor", f"Expected monitor urgency, got {res_healthy['urgency']}"
    print(" PASS: Healthy droppings properly mapped with no severity and monitor urgency.")

    # 2. Uncertain prediction (confidence < 0.50)
    low_conf_probs = np.array([0.30, 0.25, 0.20, 0.25], dtype=np.float32)
    res_uncertain = assess_postprocessing(low_conf_probs)
    assert res_uncertain["status"] == "uncertain", f"Expected uncertain status, got {res_uncertain['status']}"
    assert res_uncertain["severity"] is None, f"Expected no severity when uncertain, got {res_uncertain['severity']}"
    print(" PASS: Low confidence correctly yields uncertain status.")

    # 3. Newcastle severity floor (even with lower confidence, Newcastle cannot be Mild)
    ncd_probs = np.array([0.05, 0.05, 0.60, 0.30], dtype=np.float32) # conf 0.60 would normally be Mild (<0.67)
    res_ncd = assess_postprocessing(ncd_probs)
    assert res_ncd["predicted_class"] == "newcastle"
    assert res_ncd["severity"] == "moderate", f"Expected Moderate floor for Newcastle, got {res_ncd['severity']}"
    assert res_ncd["urgency"] == "vet_now", f"Expected vet_now urgency for Newcastle, got {res_ncd['urgency']}"
    print(" PASS: Newcastle class severity floor enforced (bumped from Mild to Moderate) + immediate vet urgency.")

    # 4. Severe Coccidiosis (> 0.83)
    cocci_probs = np.array([0.94, 0.02, 0.01, 0.03], dtype=np.float32)
    res_cocci = assess_postprocessing(cocci_probs)
    assert res_cocci["predicted_class"] == "coccidiosis"
    assert res_cocci["severity"] == "severe"
    assert res_cocci["urgency"] == "treat_today"
    print(" PASS: High confidence coccidiosis mapped to Severe + treat_today urgency.")


def test_clinical_triage_escalation():
    print("\n--- Test 3: Clinical Flock Triage Escalation ---")

    # Moderate salmonella baseline escalated by sudden mortality
    salmo_probs = np.array([0.05, 0.05, 0.15, 0.75], dtype=np.float32) # conf 0.75 is moderate
    triage_input = {
        "lethargy": "10% to 30% of flock",
        "intakeDrop": "Reduced consumption",
        "suddenMortality": "Multiple birds died",
    }
    res_triage = assess_postprocessing(salmo_probs, flock_signals=triage_input)
    assert res_triage["predicted_class"] == "salmonella"
    assert res_triage["severity"] == "severe", f"Expected escalation to severe, got {res_triage['severity']}"
    assert res_triage["urgency"] == "vet_now", f"Expected escalation to vet_now, got {res_triage['urgency']}"
    print(" PASS: Flock mortality escalation elevated severity to Severe and urgency to vet_now.")


def test_inference_pipeline():
    print("\n--- Test 4: End-to-End Inference Execution ---")
    img = Image.new("RGB", (224, 224), color=(180, 80, 50))
    buf = io.BytesIO()
    img.save(buf, format="JPEG")
    tensor = preprocess_image(buf.getvalue())

    probs, latency_ms = run_model_inference(tensor, forced_disease="coccidiosis")
    assert len(probs) == len(CLASS_NAMES)
    assert abs(float(np.sum(probs)) - 1.0) < 0.05, f"Probabilities do not sum to ~1: {np.sum(probs)}"
    print(f" PASS: Inference executed in {latency_ms:.2f} ms with probabilities: {probs}")


if __name__ == "__main__":
    print("Starting PoultryCare ML Inference Pipeline Verification...")
    test_preprocessing()
    test_severity_thresholds()
    test_clinical_triage_escalation()
    test_inference_pipeline()
    print("\n All 4 ML pipeline tests PASSED with 100% success rate.")
