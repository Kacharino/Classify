# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build System

The project uses **XcodeGen** — `project.yml` is the source of truth, not the `.xcodeproj`.

```bash
# Regenerate xcodeproj after editing project.yml
xcodegen generate
```

Build, run, and test via Xcode (no CLI build scripts). The app requires a physical iPhone + Apple Watch pair to test the full sensor pipeline — the Simulator has no motion data.

Run tests in Xcode: `Cmd+U` (targets the `ClassifyTests` unit test bundle against the `Classify` iOS target).

## Architecture Overview

Classify is an iOS + watchOS app that automatically identifies gym exercises from wrist motion. The Watch records IMU data per set; the iPhone reassembles it, runs a CNN, and logs the result.

### iPhone App (`Classify/`)

Three `ObservableObject`s are created at app startup and injected as environment objects:

| Class | Role |
|---|---|
| `SessionManager` | Active session state; calls `ExerciseClassifier` on incoming sensor data |
| `WatchConnectivityManager` | WCSession delegate; sends start/stop to Watch, receives batched samples |
| `WorkoutStore` | JSON persistence of completed `WorkoutSession`s (Documents dir, max 100) |

`ExerciseClassifier` is owned by `SessionManager`. It loads `CNNModel_v3c.mlpackage` (CoreML) and `cnn_v2f_artifacts.json` (normalization params + class order) from the bundle at init.

### Watch App (`ClassifyWatch/`)

| Class | Role |
|---|---|
| `WatchMotionManager` | CoreMotion at 50 Hz; records `[ax, ay, az, gx, gy, gz]` |
| `WatchSessionManager` | WCSession delegate; receives commands, sends samples in batches |

Axis correction in `WatchMotionManager`: `ax` and `gx` are negated because the training dataset (MMFit) was recorded on the right wrist; the app runs on the left wrist.

### End-to-End Data Flow

1. **Start** — iPhone: `SessionManager.startSession()` + `WatchConnectivityManager.sendStartCommand()` (via `sendMessage` + `transferUserInfo` dual-send for reliability)
2. **Record** — Watch: user taps Start/Stop per set → `WatchMotionManager` captures at 50 Hz
3. **Transfer** — Watch: `WatchSessionManager.sendSamples()` splits into batches of 25 rows and sends each via `transferUserInfo` with `batchIndex` + `isLast` flags
4. **Reassemble** — iPhone: `WatchConnectivityManager` buffers batches in `pendingBatches: [Int: [[Double]]]`, flushes when `isLast == true`
5. **Classify** — `ExerciseClassifier.classify(samples:)` runs sliding-window inference and appends a `WorkoutSet` to `SessionManager.currentSets`
6. **Stop** — iPhone: `sessionManager.endSession()` → `WorkoutStore.addSession()` → `SummaryView` sheet

### CNN Inference (`ExerciseClassifier`)

- **Input:** `[[Double]]` of shape `N × 6` (accelerometer m/s², gyroscope rad/s), minimum 250 samples
- **Window:** 250 samples (5 s at 50 Hz), stride 25 — all windows are z-score normalized using `means`/`stds` from the artifacts JSON
- **MLMultiArray shape:** `[1, 250, 6]` float32, feature name `"x"`
- **Output tensor name:** `"Identity"` (falls back to first output name)
- **Decision:** majority vote across all windows; `non-exercise` windows are excluded before voting; winner must have ≥ 30% of remaining votes

### UI Structure (iPhone)

`ContentView` is a two-tab `TabView`:
- **Verlauf** (`HistoryView`) — list of past `WorkoutSession`s, swipe-to-delete
- **Workout** (`WorkoutView`) — idle/active states; shows live set list while session is running; presents `SummaryView` as a sheet on stop

### Data Models

- `WorkoutSet` — single classified set: `exerciseLabel`, `confidence`, `isConnectionLost`, `timestamp`
- `WorkoutSession` — array of `WorkoutSet`s with `date` and `duration`; `Codable` for JSON persistence

Connection loss during a session inserts a `WorkoutSet` with `isConnectionLost: true` (shown as a warning row in the UI).
