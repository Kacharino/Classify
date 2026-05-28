# V1-RF Results - Random Forest (sw_r IMU, neues Modell)

## Ziel
V1-RF ist eine **separate Baseline** mit klassischem ML (Random Forest) und keine V1-CNN-Variante.

Konstant zur bisherigen Datenpipeline:
- Daten: `sw_r_acc + sw_r_gyr`
- Resampling: `50 Hz`
- Fenster: `250` Samples (`5s`), Stride `10` (`0.2s`)
- Labeling: Majority-Class pro Fenster
- Klassen: `11` (10 Übungen + `non-exercise`)
- Split: identisch (paper-konform)

## Modellansatz (neu gegenüber CNN)
- Modell: `RandomForestClassifier`
- Hyperparameter:
  - `n_estimators=100`
  - `class_weight="balanced"`
  - `random_state=42`
  - `n_jobs=-1`
- Input-Features pro Fenster: `30`
  - je Kanal (`6` Kanäle): `mean`, `std`, `min`, `max`, `RMS`
  - also `5 × 6 = 30` Features

## Datenmengen
- `X_train`: `(119123, 30)`
- `X_unseen`: `(60128, 30)`
- Hinweis: `X_val` wird gebaut, aber im aktuellen Lauf nicht für Hyperparameter-Tuning oder Early Stopping genutzt.

## Hauptergebnisse
| Split | Accuracy | Macro-F1 |
|---|---:|---:|
| Test Seen | `0.9688` | `0.9099` |
| Test Unseen | `0.8731` | `0.5813` |

## Vergleich zum CNN-Baseline V1
CNN-V1 Referenz:
- Seen: Acc `0.9804`, Macro-F1 `0.9591`
- Unseen: Acc `0.9305`, Macro-F1 `0.8110`

Delta (V1-RF minus CNN-V1):
- Seen Accuracy: `-0.0116`
- Seen Macro-F1: `-0.0492`
- Unseen Accuracy: `-0.0574`
- Unseen Macro-F1: `-0.2297`

## Klassenanalyse
### Seen (Auszug F1)
- squats: `0.8844`
- bicep_curls: `0.7791`
- jumping_jacks: `0.5706`
- non-exercise: `0.9798`

### Unseen (Auszug F1)
- squats: `0.4373`
- lunges: `0.5145`
- bicep_curls: `0.0288`
- dumbbell_rows: `0.1722`
- lateral_shoulder_raises: `0.5546`
- non-exercise: `0.9298`

Beobachtung:
- Der RF klassifiziert `non-exercise` stark, bricht aber bei mehreren Übungsklassen auf Unseen deutlich ein.
- Der Generalization-Gap ist deutlich stärker als beim CNN.

## Fazit
- V1-RF ist als schneller, interpretierbarer Klassik-Baseline nützlich.
- Für das eigentliche Ziel (robuste Unseen-Generalization über Übungsklassen) ist CNN klar überlegen.

## Artefakte
- Notebook (Quelle + ausgeführt): `5_v1_random_forest.ipynb`
- Hinweis: Im aktuellen Notebook wird kein separates RF-Modellartefakt (`.pkl/.joblib`) gespeichert.
