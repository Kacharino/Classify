# V3B-RF Results - Random Forest mit `n_estimators=500` (sw_r IMU)

## Ziel
V3B-RF untersucht den Effekt weiterer Baumanzahl-Erhoehung bei gleicher RF-Konfiguration (`max_depth=10`).

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
- `n_estimators=500`
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
| Test Seen | `0.9623` | `0.9169` |
| Test Unseen | `0.8999` | `0.7327` |

Trainingsdauer (Fit-Log):
- `500/500` Baeume nach ca. `24.0s` abgeschlossen

## Vergleich
### Gegen V2-RF (`n_estimators=100`, `max_depth=10`)
V2-RF Referenz:
- Seen: Acc `0.9616`, Macro-F1 `0.9144`
- Unseen: Acc `0.9008`, Macro-F1 `0.7357`

Delta (V3B-RF minus V2-RF):
- Seen Accuracy: `+0.0007`
- Seen Macro-F1: `+0.0025`
- Unseen Accuracy: `-0.0009`
- Unseen Macro-F1: `-0.0030`

### Gegen V3A-RF (`n_estimators=200`)
V3A-RF Referenz:
- Seen: Acc `0.9621`, Macro-F1 `0.9162`
- Unseen: Acc `0.9004`, Macro-F1 `0.7355`

Delta (V3B-RF minus V3A-RF):
- Seen Accuracy: `+0.0002`
- Seen Macro-F1: `+0.0007`
- Unseen Accuracy: `-0.0005`
- Unseen Macro-F1: `-0.0028`

### Gegen V1-RF
V1-RF Referenz:
- Seen: Acc `0.9688`, Macro-F1 `0.9099`
- Unseen: Acc `0.8731`, Macro-F1 `0.5813`

Delta (V3B-RF minus V1-RF):
- Seen Accuracy: `-0.0065`
- Seen Macro-F1: `+0.0070`
- Unseen Accuracy: `+0.0268`
- Unseen Macro-F1: `+0.1514`

## Klassenanalyse (Unseen)
Auszug Unseen F1 (V3B-RF):
- squats: `0.4393`
- lunges: `0.7731`
- bicep_curls: `0.7993`
- situps: `0.7451`
- dumbbell_rows: `0.4757`
- lateral_shoulder_raises: `0.5380`
- non-exercise: `0.9478`

Beobachtung:
- Gegenueber `n_estimators=200` keine relevante Verbesserung.
- Mehr Baeume erhoehen hier vor allem die Laufzeit.

## Fazit
- V3B-RF bleibt auf praktisch gleichem Niveau wie V2/V3A.
- `n_estimators=500` ist im aktuellen Setup kaum effizient.

## Artefakte
- Notebook (Quelle + ausgefuehrt): `5_v3b_random_forest_estimators500.ipynb`
- Hinweis: Im aktuellen Notebook wird kein separates RF-Modellartefakt (`.pkl/.joblib`) gespeichert.

