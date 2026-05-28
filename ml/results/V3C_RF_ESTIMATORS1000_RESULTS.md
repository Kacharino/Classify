# V3C-RF Results - Random Forest mit `n_estimators=1000` (sw_r IMU)

## Ziel
V3C-RF testet die maximale Baumanzahl dieser Reihe bei gleicher RF-Konfiguration (`max_depth=10`).

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
- `n_estimators=1000`
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
| Test Seen | `0.9623` | `0.9170` |
| Test Unseen | `0.9002` | `0.7334` |

Trainingsdauer (Fit-Log):
- `1000/1000` Baeume nach ca. `47.3s` abgeschlossen

## Vergleich
### Gegen V2-RF (`n_estimators=100`, `max_depth=10`)
V2-RF Referenz:
- Seen: Acc `0.9616`, Macro-F1 `0.9144`
- Unseen: Acc `0.9008`, Macro-F1 `0.7357`

Delta (V3C-RF minus V2-RF):
- Seen Accuracy: `+0.0007`
- Seen Macro-F1: `+0.0026`
- Unseen Accuracy: `-0.0006`
- Unseen Macro-F1: `-0.0023`

### Gegen V3A-RF (`n_estimators=200`)
V3A-RF Referenz:
- Seen: Acc `0.9621`, Macro-F1 `0.9162`
- Unseen: Acc `0.9004`, Macro-F1 `0.7355`

Delta (V3C-RF minus V3A-RF):
- Seen Accuracy: `+0.0002`
- Seen Macro-F1: `+0.0008`
- Unseen Accuracy: `-0.0002`
- Unseen Macro-F1: `-0.0021`

### Gegen V1-RF
V1-RF Referenz:
- Seen: Acc `0.9688`, Macro-F1 `0.9099`
- Unseen: Acc `0.8731`, Macro-F1 `0.5813`

Delta (V3C-RF minus V1-RF):
- Seen Accuracy: `-0.0065`
- Seen Macro-F1: `+0.0071`
- Unseen Accuracy: `+0.0271`
- Unseen Macro-F1: `+0.1521`

## Klassenanalyse (Unseen)
Auszug Unseen F1 (V3C-RF):
- squats: `0.4407`
- lunges: `0.7732`
- bicep_curls: `0.8105`
- situps: `0.7461`
- dumbbell_rows: `0.4778`
- lateral_shoulder_raises: `0.5380`
- non-exercise: `0.9479`

Beobachtung:
- Gegenueber `n_estimators=200/500` kaum veraenderte Metriken.
- Der Hauptunterschied ist die deutlich laengere Trainingszeit.

## Fazit
- V3C-RF bietet keine relevante Qualitaetssteigerung trotz hoher Baumanzahl.
- Fuer Effizienz/Leistung ist eine kleinere Baumanzahl (z. B. `100` oder `200`) sinnvoller.

## Artefakte
- Notebook (Quelle + ausgefuehrt): `5_v3c_random_forest_estimators1000.ipynb`
- Hinweis: Im aktuellen Notebook wird kein separates RF-Modellartefakt (`.pkl/.joblib`) gespeichert.

