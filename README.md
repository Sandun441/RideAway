# RideAway — On-Device Crash Detection for Cyclists using 1D-CNN and TFLite

> Real-time crash detection on a smartphone. No internet. No server. Under 50 ms.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)](https://flutter.dev)
[![TFLite](https://img.shields.io/badge/TensorFlow%20Lite-quantized-orange)](https://www.tensorflow.org/lite)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

---

## Motivation

Cyclists and scooter riders are among the most vulnerable road users. In a serious crash, the window for emergency response matters enormously — yet most riders are alone, and calling for help may be impossible if they're unconscious or disoriented.

Existing solutions either require dedicated hardware (expensive, not adopted) or depend on cloud inference (unavailable when connectivity fails at the moment it matters most). RideAway addresses this gap: a cross-platform mobile app that detects crashes in real time using only the IMU sensors already in every smartphone, running an on-device ML model that works fully offline.

---

## How It Works

RideAway continuously reads accelerometer and gyroscope data from the phone's IMU. A sliding window of sensor readings is featurized and fed into a quantized 1D-CNN running via TensorFlow Lite. When a crash is detected above a confidence threshold, the app triggers an alert — with a short cancellation window for false positives — and can notify an emergency contact.

```
IMU sensors (accel + gyro)
        │
        ▼
Sliding window (44 features/window)
        │
        ▼
Quantized 1D-CNN (TFLite, 59.9 KB)
        │
        ▼
Crash / No-crash  (<50 ms inference)
        │
        ▼
Alert + emergency contact notification
```

---

## Dataset

Data was collected using [Sensor Logger](https://www.tszheichoi.com/sensorlogger) across two classes:

| Class | Description | Samples |
|---|---|---|
| `crash` | Simulated crash events: sudden stops, drops, falls from bike | — |
| `no_crash` | Normal riding: bumps, sharp turns, braking, acceleration | — |

**Sensor streams collected:** 3-axis accelerometer, 3-axis gyroscope (6 raw signals total)

**Feature engineering:** A sliding window approach extracts 44 features per window, including time-domain statistics (mean, std, min, max, skewness, kurtosis), signal magnitude area (SMA), and inter-axis correlation features.

> **Limitation:** Data was collected from a single phone model. IMU calibration varies across manufacturers, and the model may not generalize to all hardware without retraining or fine-tuning on new device data. This is a known open problem in IMU-based activity recognition.

---

## Model Architecture

Two models were trained and evaluated:

### Baseline: Random Forest
A classical ML baseline using the 44 hand-crafted features. Establishes a performance floor and validates the feature engineering approach.

### Final: 1D-CNN
A 1D convolutional neural network operating directly on the windowed, featurized sensor data. Chosen for its ability to capture local temporal patterns in the signal while remaining lightweight enough for on-device deployment.

The final model was quantized (post-training integer quantization via TensorFlow Lite) to reduce size and inference latency while preserving accuracy.

**Model size:** 59.9 KB (quantized TFLite)

---

## Results

Evaluation at decision threshold **0.35** on held-out test set:

| Metric | Value | Target (SRS) | Status |
|---|---|---|---|
| Recall (crash detection rate) | **0.969** | ≥ 0.95 | ✅ |
| False Positive Rate | **0.018** | ≤ 0.05 | ✅ |
| Inference latency (on-device) | **< 50 ms** | < 100 ms | ✅ |
| Model size | **59.9 KB** | < 200 KB | ✅ |

**Threshold rationale:** A threshold of 0.35 (rather than the default 0.50) was chosen to prioritise recall — in a safety-critical application, missing a real crash (false negative) is more costly than an occasional false alarm. The cancellation window in the app mitigates the UX impact of false positives.

> **Limitation:** The threshold was tuned on data from the same collection setup. Real-world recall may differ across riding styles, terrain types, and phone mounting positions (pocket vs handlebar vs bag).

---

## Technical Stack

| Layer | Technology |
|---|---|
| Mobile app | Flutter (cross-platform, iOS + Android) |
| ML runtime | TensorFlow Lite (on-device, offline) |
| Model training | TensorFlow / Keras (Python) |
| Feature engineering | Pandas, NumPy, Scikit-learn |
| Backend / notifications | Firebase |
| Data collection | Sensor Logger |

---

## Repository Structure

```
RideAway/
├── lib/
│   ├── services/
│   │   └── collision_detection_service.dart   # TFLite inference pipeline
│   └── ...
├── assests/
│   ├── ml/
│       └── crash_detector.tflite              # Quantized final model
│   ├── notebooks/
│       │   ├── 01_data_exploration.ipynb
│       │   ├── 02_feature_engineering.ipynb
│       │   ├── 03_baseline_random_forest.ipynb
│       │   └── 04_cnn_training_and_evaluation.ipynb    
├
└── README.md
```

---

## Limitations & Future Work

This section exists because we think honest evaluation is part of good engineering.

**Current limitations:**
- Single-device training data — generalization across phone models is untested
- Simulated crash events, not real crash recordings (ethical constraint)
- No distinction between crash types (low-speed fall vs high-speed collision)
- Phone mounting position affects IMU readings significantly

**Planned improvements:**
- Collect data across multiple device types and mounting positions
- Explore personalization: fine-tune on a per-user baseline to reduce false positives
- Investigate federated learning for privacy-preserving model improvement across users
- Add severity estimation (not just crash/no-crash, but rough impact magnitude)

---

## Team

Built by a team of 3, led by [Sandun Liyanage](https://github.com/Sandun441).

---

## Citation

If you use this work or dataset in your research, please cite:

```
@software{rideaway2025,
  author = {L.G.S.B.Liyanage, A.J.M.R.L.Jayasundara and K.R.A.R.Jayathilaka  },
  title = {RideAway: On-Device Crash Detection for Cyclists using 1D-CNN and TFLite},
  year = {2025},
  url = {https://github.com/Sandun441/RideAway}
}
```
