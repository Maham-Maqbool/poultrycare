#!/usr/bin/env python3
"""
Test client to verify HTTP POST endpoint /api/diagnose against inference_server.py
"""

import sys
import io
import time
import json
import base64
import urllib.request
from pathlib import Path
from PIL import Image

def test_http_endpoint():
    # 1. Create a synthetic test image
    img = Image.new("RGB", (300, 300), color=(120, 160, 80))
    buf = io.BytesIO()
    img.save(buf, format="JPEG")
    b64_str = base64.b64encode(buf.getvalue()).decode("utf-8")

    payload = {
        "image_base64": b64_str,
        "flock_signals": {
            "lethargy": "10% to 30% of flock",
            "intakeDrop": "Reduced consumption",
            "suddenMortality": "None in 24h",
        },
        "forced_disease": "coccidiosis",
    }

    req = urllib.request.Request(
        "http://127.0.0.1:8000/api/diagnose",
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST"
    )

    try:
        with urllib.request.urlopen(req, timeout=5) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            print("HTTP Status:", resp.status)
            print("Response:", json.dumps(data, indent=2))
            assert "predicted_class" in data
            assert data["predicted_class"] == "coccidiosis"
            assert "severity" in data
            assert "urgency" in data
            assert "latency" in data
            print("\n API client verification PASSED!")
            return True
    except Exception as e:
        print("API test failed:", e)
        return False

if __name__ == "__main__":
    test_http_endpoint()
