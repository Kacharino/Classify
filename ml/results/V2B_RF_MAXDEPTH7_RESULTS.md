# V2B-RF Results - Random Forest mit `max_depth=7` (sw_r IMU)

## Ziel
V2B-RF (`max_depth=7`) ist eine eigenstaendige RF-Variante innerhalb der RF-Linie.

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
- `n_estimators=100`
- `max_depth=7`
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
| Test Seen | `0.9179` | `0.8660` |
| Test Unseen | `0.8407` | `0.6799` |

## Vergleich
### Gegen V2-RF (`max_depth=10`)
V2-RF Referenz:
- Seen: Acc `0.9616`, Macro-F1 `0.9144`
- Unseen: Acc `0.9008`, Macro-F1 `0.7357`

Delta (V2B-RF-d7 minus V2-RF):
- Seen Accuracy: `-0.0437`
- Seen Macro-F1: `-0.0484`
- Unseen Accuracy: `-0.0601`
- Unseen Macro-F1: `-0.0558`

### Gegen V1-RF
V1-RF Referenz:
- Seen: Acc `0.9688`, Macro-F1 `0.9099`
- Unseen: Acc `0.8731`, Macro-F1 `0.5813`

Delta (V2B-RF-d7 minus V1-RF):
- Seen Accuracy: `-0.0509`
- Seen Macro-F1: `-0.0439`
- Unseen Accuracy: `-0.0324`
- Unseen Macro-F1: `+0.0986`

## Klassenanalyse (Unseen)
Auszug Unseen F1 (V2B-RF-d7):
- squats: `0.3553`
- lunges: `0.6324`
- bicep_curls: `0.7750`
- situps: `0.6767`
- dumbbell_rows: `0.4477`
- lateral_shoulder_raises: `0.5435`
- non-exercise: `0.9089`

Beobachtung:
- Das flache Modell (`max_depth=7`) ist insgesamt klar unter dem `max_depth=10`-Setup.
- Positiv ist v. a. die Unseen-Macro-F1-Verbesserung gegenueber V1-RF.

## Fazit
- `max_depth=7` ist fuer diese Daten zu restriktiv.
- Als RF-Baseline ist `max_depth=10` deutlich staerker.

## Artefakte
- Notebook (Quelle + ausgefuehrt): `5_v2b_random_forest_maxdepth7.ipynb`
- Hinweis: Im aktuellen Notebook wird kein separates RF-Modellartefakt (`.pkl/.joblib`) gespeichert.

