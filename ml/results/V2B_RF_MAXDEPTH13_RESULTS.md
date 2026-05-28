# V2B-RF Results - Random Forest mit `max_depth=13` (sw_r IMU)

## Ziel
V2B-RF (`max_depth=13`) ist eine eigenstaendige RF-Variante innerhalb der RF-Linie.

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
- `max_depth=13`
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
| Test Seen | `0.9723` | `0.9272` |
| Test Unseen | `0.8929` | `0.6844` |

## Vergleich
### Gegen V2-RF (`max_depth=10`)
V2-RF Referenz:
- Seen: Acc `0.9616`, Macro-F1 `0.9144`
- Unseen: Acc `0.9008`, Macro-F1 `0.7357`

Delta (V2B-RF-d13 minus V2-RF):
- Seen Accuracy: `+0.0107`
- Seen Macro-F1: `+0.0128`
- Unseen Accuracy: `-0.0079`
- Unseen Macro-F1: `-0.0513`

### Gegen V1-RF
V1-RF Referenz:
- Seen: Acc `0.9688`, Macro-F1 `0.9099`
- Unseen: Acc `0.8731`, Macro-F1 `0.5813`

Delta (V2B-RF-d13 minus V1-RF):
- Seen Accuracy: `+0.0035`
- Seen Macro-F1: `+0.0173`
- Unseen Accuracy: `+0.0198`
- Unseen Macro-F1: `+0.1031`

## Klassenanalyse (Unseen)
Auszug Unseen F1 (V2B-RF-d13):
- squats: `0.4738`
- lunges: `0.7320`
- bicep_curls: `0.3938`
- situps: `0.7319`
- dumbbell_rows: `0.4065`
- lateral_shoulder_raises: `0.5588`
- non-exercise: `0.9430`

Beobachtung:
- `max_depth=13` liefert starke Seen-Werte.
- Auf Unseen sinkt die Macro-F1 gegenueber `max_depth=10`, vor allem durch instabile Klassen wie `bicep_curls`.

## Fazit
- `max_depth=13` ist besser als V1-RF, aber auf Unseen schwaecher als `max_depth=10`.
- Fuer das RF-Ziel (robuste Unseen-Generalization) bleibt `max_depth=10` die bessere Wahl.

## Artefakte
- Notebook (Quelle + ausgefuehrt): `5_v2b_random_forest_maxdepth13.ipynb`
- Hinweis: Im aktuellen Notebook wird kein separates RF-Modellartefakt (`.pkl/.joblib`) gespeichert.

