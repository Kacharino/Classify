# V4B-RF Results - Random Forest mit mehr statischen Features (48 Features, sw_r IMU)

## Ziel
V4B-RF erweitert die Featurebasis weiter und prueft, ob zusaetzliche statische Kennwerte die RF-Leistung verbessern.

Konstant zur RF-Pipeline:
- Daten: `sw_r_acc + sw_r_gyr`
- Resampling: `50 Hz`
- Fenster: `250` Samples (`5s`), Stride `10` (`0.2s`)
- Labeling: Majority-Class pro Fenster
- Klassen: `11` (10 Uebungen + `non-exercise`)
- Split: identisch (paper-konform)

## Aenderung gegenueber V2-RF
Feature-Set von `30` auf `48` erweitert:
- Basis (`30`): `mean`, `std`, `min`, `max`, `RMS` je Kanal (`6`)
- Neu (`+18`): weitere statische Features je Kanal
  - `median` (`+6`)
  - `MAD` (mean absolute deviation, `+6`)
  - `zero crossing rate` (`+6`)

Hinweis:
- In diesem Notebook werden **keine** Korrelationsfeatures verwendet.

Modellparameter (unveraendert):
- `RandomForestClassifier`
- `n_estimators=100`
- `max_depth=10`
- `class_weight="balanced"`
- `random_state=42`
- `n_jobs=-1`

## Datenmengen
- `X_train`: `(119123, 48)`
- `X_unseen`: `(60128, 48)`
- Hinweis: `X_val` wird gebaut, aber im aktuellen Lauf nicht fuer Hyperparameter-Tuning genutzt.

## Hauptergebnisse
| Split | Accuracy | Macro-F1 |
|---|---:|---:|
| Test Seen | `0.9683` | `0.9326` |
| Test Unseen | `0.9065` | `0.7423` |

Trainingsdauer (Fit-Log):
- `100/100` Baeume nach ca. `5.4s` abgeschlossen

## Vergleich
### Gegen V4A-RF (alternative Feature-Erweiterung mit Korrelationen)
V4A-RF Referenz:
- Seen: Acc `0.9671`, Macro-F1 `0.9244`
- Unseen: Acc `0.9039`, Macro-F1 `0.7411`

Delta (V4B-RF minus V4A-RF):
- Seen Accuracy: `+0.0012`
- Seen Macro-F1: `+0.0082`
- Unseen Accuracy: `+0.0026`
- Unseen Macro-F1: `+0.0012`

### Gegen V2-RF (30 Features, ohne Korrelationen/erweiterte Statik)
V2-RF Referenz:
- Seen: Acc `0.9616`, Macro-F1 `0.9144`
- Unseen: Acc `0.9008`, Macro-F1 `0.7357`

Delta (V4B-RF minus V2-RF):
- Seen Accuracy: `+0.0067`
- Seen Macro-F1: `+0.0182`
- Unseen Accuracy: `+0.0057`
- Unseen Macro-F1: `+0.0066`

### Gegen V1-RF
V1-RF Referenz:
- Seen: Acc `0.9688`, Macro-F1 `0.9099`
- Unseen: Acc `0.8731`, Macro-F1 `0.5813`

Delta (V4B-RF minus V1-RF):
- Seen Accuracy: `-0.0005`
- Seen Macro-F1: `+0.0227`
- Unseen Accuracy: `+0.0334`
- Unseen Macro-F1: `+0.1610`

## Klassenanalyse (Unseen)
Auszug Unseen F1 (V4B-RF):
- squats: `0.4558`
- lunges: `0.7883`
- bicep_curls: `0.7892`
- situps: `0.7663`
- pushups: `0.8047`
- dumbbell_rows: `0.4804`
- lateral_shoulder_raises: `0.5605`
- non-exercise: `0.9523`

Beobachtung:
- Gegenueber V4A steigen die Gesamtmetriken leicht.
- Schwierige Unseen-Klassen bleiben weiterhin `squats` und `dumbbell_rows`.

## Fazit
- V4B-RF liefert den besten Stand innerhalb der bisherigen RF-Feature-Engineering-Schritte.
- Zusaetzliche statische Features sind sinnvoll, aber der Zugewinn gegenueber V4A ist moderat.

## Artefakte
- Notebook (Quelle + ausgefuehrt): `5_v4b_random_forest_more_static_features.ipynb`
- Hinweis: Im aktuellen Notebook wird kein separates RF-Modellartefakt (`.pkl/.joblib`) gespeichert.
