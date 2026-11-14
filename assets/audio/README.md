# PoultryCare Audio Guidance Engine

The application synthesizes real-time spoken audio guidance in both Urdu (`ur-PK`) and English (`en-US`) dynamically using the on-device Text-to-Speech (`flutter_tts`) engine configured in `DiseaseAudioService` and `AudioPlayerWidget`.

- Spoken audio explanations are generated dynamically according to the exact classified disease (Newcastle Disease, Coccidiosis, Salmonella, or Healthy baseline), measured clinical ratios, calibrated severity, and veterinary biosecurity advice.
- No static audio files are required for operation.
