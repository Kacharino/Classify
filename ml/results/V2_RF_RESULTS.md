# V2-RF Results - Random Forest mit `max_depth=10` (sw_r IMU)

## Ziel
V2-RF ist die nächste Iteration des Random-Forest-Ansatzes und bleibt ein **separates Modell** (nicht CNN).

Konstant zu V1-RF:
- Daten: `sw_r_acc + sw_r_gyr`
- Resampling: `50 Hz`
- Fenster: `250` Samples (`5s`), Stride `10` (`0.2s`)
- Labeling: Majority-Class pro Fenster
- Klassen: `11` (10 Übungen + `non-exercise`)
- Split: identisch (paper-konform)
- Features: `30` pro Fenster (`mean`, `std`, `min`, `max`, `RMS` je Kanal)

## Änderung gegenüber V1-RF
- `RandomForestClassifier` jetzt mit zusätzlicher Tiefenbegrenzung:
  - `max_depth=10`

Weitere RF-Parameter:
- `n_estimators=100`
- `class_weight="balanced"`
- `random_state=42`
- `n_jobs=-1`

## Datenmengen
- `X_train`: `(119123, 30)`
- `X_unseen`: `(60128, 30)`
- Hinweis: `X_val` wird gebaut, aber im aktuellen Lauf nicht für Hyperparameter-Tuning genutzt.

## Hauptergebnisse
| Split | Accuracy | Macro-F1 |
|---|---:|---:|
| Test Seen | `0.9616` | `0.9144` |
| Test Unseen | `0.9008` | `0.7357` |

## Vergleich
### Gegen V1-RF (entscheidend)
V1-RF Referenz:
- Seen: Acc `0.9688`, Macro-F1 `0.9099`
- Unseen: Acc `0.8731`, Macro-F1 `0.5813`

Delta (V2-RF minus V1-RF):
- Seen Accuracy: `-0.0072`
- Seen Macro-F1: `+0.0045`
- Unseen Accuracy: `+0.0277`
- Unseen Macro-F1: `+0.1544`

### Gegen CNN-V1
CNN-V1 Referenz:
- Seen: Acc `0.9804`, Macro-F1 `0.9591`
- Unseen: Acc `0.9305`, Macro-F1 `0.8110`

Delta (V2-RF minus CNN-V1):
- Seen Accuracy: `-0.0188`
- Seen Macro-F1: `-0.0447`
- Unseen Accuracy: `-0.0297`
- Unseen Macro-F1: `-0.0753`

## Klassenanalyse
### Seen (Auszug F1)
- squats: `0.8804`
- lunges: `0.9062`
- bicep_curls: `0.9550`
- jumping_jacks: `0.6709`
- non-exercise: `0.9746`

### Unseen (Auszug F1)
- squats: `0.4377`
- lunges: `0.7772`
- bicep_curls: `0.8126`
- situps: `0.7445`
- dumbbell_rows: `0.5030`
- lateral_shoulder_raises: `0.5355`
- non-exercise: `0.9485`

Beobachtung:
- Die Tiefenbegrenzung verbessert die Unseen-Generalization des RF deutlich gegenüber V1-RF.
- Kritische Klassen bleiben u. a. `squats`, `dumbbell_rows`, `lateral_shoulder_raises`.

## Fazit
- V2-RF ist ein klarer Fortschritt gegenüber V1-RF, vor allem auf **Unseen**.
- Gegenüber der CNN-Baseline bleibt RF insgesamt schwächer, ist aber als kompakte klassische Baseline deutlich robuster als zuvor.

## Artefakte
- Notebook (Quelle + ausgeführt): `5_v2_random_forest_maxdepth10.ipynb`
- Hinweis: Im aktuellen Notebook wird kein separates RF-Modellartefakt (`.pkl/.joblib`) gespeichert.
