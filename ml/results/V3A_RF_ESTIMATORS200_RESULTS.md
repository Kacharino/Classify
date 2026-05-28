# V3A-RF Results - Random Forest mit `n_estimators=200` (sw_r IMU)

## Ziel
V3A-RF untersucht den Effekt von mehr Baeumen bei gleicher RF-Konfiguration (`max_depth=10`).

Konstant zur RF-Pipeline:
- Daten: `sw_r_acc + sw_r_gyr`
- Resampling: `50 Hz`
- Fenster: `250` Samples (`5s`), Stride `10` (`0.2s`)
- Labeling: Majority-Class pro Fenster
- Klassen: `11` (10 Uebungen + `non-exercise`)
- Split: identisch (paper-konform)
- Features: `30` pro Fenster (`mean`, `std`, `min`, `max`, `RMS` je Kanal)

## Modellparameter
- `RandomForestClassifier`
- `n_estimators=200`
- `max_depth=10`
- `class_weight="balanced"`
- `random_state=42`
- `n_jobs=-1`

## Datenmengen
- `X_train`: `(119123, 30)`
- `X_unseen`: `(60128, 30)`
- Hinweis: `X_val` wird gebaut, aber im aktuellen Lauf nicht fuer Hyperparameter-Tuning genutzt.

## Hauptergebnisse
| Split | Accuracy | Macro-F1 |
|---|---:|---:|
| Test Seen | `0.9621` | `0.9162` |
| Test Unseen | `0.9004` | `0.7355` |

Trainingsdauer (Fit-Log):
- `200/200` Baeume nach ca. `8.8s` abgeschlossen

## Vergleich
### Gegen V2-RF (`n_estimators=100`, `max_depth=10`)
V2-RF Referenz:
- Seen: Acc `0.9616`, Macro-F1 `0.9144`
- Unseen: Acc `0.9008`, Macro-F1 `0.7357`

Delta (V3A-RF minus V2-RF):
- Seen Accuracy: `+0.0005`
- Seen Macro-F1: `+0.0018`
- Unseen Accuracy: `-0.0004`
- Unseen Macro-F1: `-0.0002`

### Gegen V1-RF
V1-RF Referenz:
- Seen: Acc `0.9688`, Macro-F1 `0.9099`
- Unseen: Acc `0.8731`, Macro-F1 `0.5813`

Delta (V3A-RF minus V1-RF):
- Seen Accuracy: `-0.0067`
- Seen Macro-F1: `+0.0063`
- Unseen Accuracy: `+0.0273`
- Unseen Macro-F1: `+0.1542`

## Klassenanalyse (Unseen)
Auszug Unseen F1 (V3A-RF):
- squats: `0.4406`
- lunges: `0.7678`
- bicep_curls: `0.8179`
- situps: `0.7437`
- dumbbell_rows: `0.4845`
- lateral_shoulder_raises: `0.5464`
- non-exercise: `0.9482`

Beobachtung:
- Gegenueber `n_estimators=100` sind die Unterschiede nur minimal.
- Mehr Baeume liefern hier keinen klaren Unseen-Gewinn.

## Fazit
- V3A-RF ist praktisch auf dem Niveau von V2-RF.
- `n_estimators=200` bringt in diesem Setup kaum Mehrwert gegenueber `100`.

## Artefakte
- Notebook (Quelle + ausgefuehrt): `5_v3a_random_forest_estimators200.ipynb`
- Hinweis: Im aktuellen Notebook wird kein separates RF-Modellartefakt (`.pkl/.joblib`) gespeichert.

