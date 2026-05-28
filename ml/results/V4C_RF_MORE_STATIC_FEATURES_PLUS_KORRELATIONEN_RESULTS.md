# V4C-RF Results - Random Forest mit mehr statischen Features + Korrelationen (54 Features, sw_r IMU)

## Ziel
V4C-RF kombiniert die Feature-Erweiterungen aus den vorherigen RF-Schritten in einem Modell.

Konstant zur RF-Pipeline:
- Daten: `sw_r_acc + sw_r_gyr`
- Resampling: `50 Hz`
- Fenster: `250` Samples (`5s`), Stride `10` (`0.2s`)
- Labeling: Majority-Class pro Fenster
- Klassen: `11` (10 Uebungen + `non-exercise`)
- Split: identisch (paper-konform)

## Aenderung gegenueber V4B-RF
Feature-Set von `48` auf `54` erweitert:
- Statische Features je Kanal (`48`):
  - `mean`, `std`, `min`, `max`, `RMS`, `median`, `MAD`, `zero crossing rate` (`8 x 6`)
- Plus `6` Korrelationsfeatures:
  - ACC: `ax-ay`, `ax-az`, `ay-az`
  - GYR: `gx-gy`, `gx-gz`, `gy-gz`

Modellparameter (unveraendert):
- `RandomForestClassifier`
- `n_estimators=100`
- `max_depth=10`
- `class_weight="balanced"`
- `random_state=42`
- `n_jobs=-1`

## Datenmengen
- `X_train`: `(119123, 54)`
- `X_unseen`: `(60128, 54)`
- Hinweis: `X_val` wird gebaut, aber im aktuellen Lauf nicht fuer Hyperparameter-Tuning genutzt.

## Hauptergebnisse
| Split | Accuracy | Macro-F1 |
|---|---:|---:|
| Test Seen | `0.9700` | `0.9306` |
| Test Unseen | `0.9079` | `0.7463` |

Trainingsdauer (Fit-Log):
- `100/100` Baeume nach ca. `6.6s` abgeschlossen

## Vergleich
### Gegen V4B-RF (48 Features, nur statisch erweitert)
V4B-RF Referenz:
- Seen: Acc `0.9683`, Macro-F1 `0.9326`
- Unseen: Acc `0.9065`, Macro-F1 `0.7423`

Delta (V4C-RF minus V4B-RF):
- Seen Accuracy: `+0.0017`
- Seen Macro-F1: `-0.0020`
- Unseen Accuracy: `+0.0014`
- Unseen Macro-F1: `+0.0040`

### Gegen V4A-RF (36 Features, Korrelationen + Basis)
V4A-RF Referenz:
- Seen: Acc `0.9671`, Macro-F1 `0.9244`
- Unseen: Acc `0.9039`, Macro-F1 `0.7411`

Delta (V4C-RF minus V4A-RF):
- Seen Accuracy: `+0.0029`
- Seen Macro-F1: `+0.0062`
- Unseen Accuracy: `+0.0040`
- Unseen Macro-F1: `+0.0052`

### Gegen V2-RF (30 Features)
V2-RF Referenz:
- Seen: Acc `0.9616`, Macro-F1 `0.9144`
- Unseen: Acc `0.9008`, Macro-F1 `0.7357`

Delta (V4C-RF minus V2-RF):
- Seen Accuracy: `+0.0084`
- Seen Macro-F1: `+0.0162`
- Unseen Accuracy: `+0.0071`
- Unseen Macro-F1: `+0.0106`

## Klassenanalyse (Unseen)
Auszug Unseen F1 (V4C-RF):
- squats: `0.5043`
- lunges: `0.8046`
- bicep_curls: `0.7570`
- situps: `0.7579`
- pushups: `0.8068`
- dumbbell_rows: `0.4343`
- lateral_shoulder_raises: `0.6399`
- non-exercise: `0.9511`

Beobachtung:
- V4C verbessert die Unseen-Gesamtmetriken leicht gegenueber V4B.
- Trotz Zugewinnen bleiben insbesondere `dumbbell_rows` und `squats` kritische Klassen.

## Fazit
- V4C-RF ist der aktuell beste Stand der RF-Feature-Engineering-Linie auf Unseen.
- Der Gewinn gegenueber V4B ist vorhanden, aber moderat.

## Artefakte
- Notebook (Quelle + ausgefuehrt): `5_v4c_random_forest_more_static_features_plus_korrelationen.ipynb`
- Hinweis: Im aktuellen Notebook wird kein separates RF-Modellartefakt (`.pkl/.joblib`) gespeichert.
- Hinweis: In der Notebook-Testzeile steht `sollte (48,) sein`; der tatsaechliche Output ist konsistent `54` Features.

