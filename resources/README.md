# PoultryCare ML Model Resources

This directory holds the exported machine learning artifacts, configuration schemas, and labels exported from the Google Colab training pipeline.

## Files in this Directory

| File | Description | Source |
|---|---|---|
| `labels.txt` | Class indices in exact output order: 0: Coccidiosis, 1: Healthy, 2: Newcastle, 3: Salmonella | Generated during Colab export |
| `severity_config.json` | Calibrated certainty thresholds and class minimum floors for severity classification | Tuned on validation split in Colab |
| `model_meta.json` | Input tensor contract (`[1, 224, 224, 3]`, RGB, `float32`, range `0..255`) and accuracy metrics | Exported metadata |
| `poultry_mobilenetv2_fp16.tflite` | Exported FP16 TensorFlow Lite model | Downloaded from Colab `deploy/` |

## How to Copy the Trained Model File from Colab

If you ran `poultry_training.ipynb` on Google Colab:
1. In Colab, look in the left sidebar file browser under `/content/PoultryFYP/outputs/deploy/` or download `/content/poultry_results.zip`.
2. Extract or copy `poultry_mobilenetv2_fp16.tflite` (or `poultry_mobilenetv2_fp32.tflite`) into this `resources/` folder.
3. The inference backend service (`backend/inference_server.py`) will automatically detect and load the model weights for live inference!
