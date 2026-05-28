# V5A-RF Results - Random Forest mit FFT-Features (114 Features, sw_r IMU)

## Ziel
V5A-RF erweitert die bisherige RF-Featurebasis um Frequenzinformationen (FFT) und testet den Effekt auf die Generalisierung.

Konstant zur RF-Pipeline:
- Daten: `sw_r_acc + sw_r_gyr`
- Resampling: `50 Hz`
- Fenster: `250` Samples (`5s`), Stride `10` (`0.2s`)
- Labeling: Majority-Class pro Fenster
- Klassen: `11` (10 Uebungen + `non-exercise`)
- Split: identisch (paper-konform)

## Aenderung gegenueber V4C-RF
Feature-Set von `54` auf `114` erweitert:
- Statische Features je Kanal (`48`):
  - `mean`, `std`, `min`, `max`, `RMS`, `median`, `MAD`, `zero crossing rate` (`8 x 6`)
- Korrelationsfeatures (`6`):
  - ACC: `ax-ay`, `ax-az`, `ay-az`
  - GYR: `gx-gy`, `gx-gz`, `gy-gz`
- Neu in V5A (`+60`):
  - FFT-Betraege, erste `10` Frequenzbins je Kanal (`10 x 6`)

Modellparameter (unveraendert):
- `RandomForestClassifier`
- `n_estimators=100`
- `max_depth=10`
- `class_weight="balanced"`
- `random_state=42`
- `n_jobs=-1`

## Datenmengen
- `X_train`: `(119123, 114)`
- `X_unseen`: `(60128, 114)`
- Hinweis: `X_val` wird gebaut, aber im aktuellen Lauf nicht fuer Hyperparameter-Tuning genutzt.

## Hauptergebnisse
| Split | Accuracy | Macro-F1 |
|---|---:|---:|
| Test Seen | `0.9744` | `0.9500` |
| Test Unseen | `0.9124` | `0.7599` |

Trainingsdauer (Fit-Log):
- `100/100` Baeume nach ca. `10.7s` abgeschlossen

## Vergleich
### Gegen V4C-RF (54 Features, ohne FFT)
V4C-RF Referenz:
- Seen: Acc `0.9700`, Macro-F1 `0.9306`
- Unseen: Acc `0.9079`, Macro-F1 `0.7463`

Delta (V5A-RF minus V4C-RF):
- Seen Accuracy: `+0.0044`
- Seen Macro-F1: `+0.0194`
- Unseen Accuracy: `+0.0045`
- Unseen Macro-F1: `+0.0136`

### Gegen V4B-RF
V4B-RF Referenz:
- Seen: Acc `0.9683`, Macro-F1 `0.9326`
- Unseen: Acc `0.9065`, Macro-F1 `0.7423`

Delta (V5A-RF minus V4B-RF):
- Seen Accuracy: `+0.0061`
- Seen Macro-F1: `+0.0174`
- Unseen Accuracy: `+0.0059`
- Unseen Macro-F1: `+0.0176`

### Gegen V2-RF
V2-RF Referenz:
- Seen: Acc `0.9616`, Macro-F1 `0.9144`
- Unseen: Acc `0.9008`, Macro-F1 `0.7357`

Delta (V5A-RF minus V2-RF):
- Seen Accuracy: `+0.0128`
- Seen Macro-F1: `+0.0356`
- Unseen Accuracy: `+0.0116`
- Unseen Macro-F1: `+0.0242`

## Klassenanalyse (Unseen)
Auszug Unseen F1 (V5A-RF):
- squats: `0.5043`
- lunges: `0.8089`
- bicep_curls: `0.7953`
- situps: `0.7666`
- pushups: `0.8249`
- dumbbell_rows: `0.4927`
- lateral_shoulder_raises: `0.6459`
- non-exercise: `0.9537`

Beobachtung:
- Die FFT-Erweiterung verbessert die Gesamtmetriken gegenueber den V4-Varianten konsistent.
- Schwierige Unseen-Klassen bleiben insbesondere `squats` und `dumbbell_rows`.

## Fazit
- V5A-RF ist der aktuell beste Stand innerhalb der RF-Linie.
- FFT-Features liefern in diesem Setup einen klaren Mehrwert.

## Artefakte
- Notebook (Quelle + ausgefuehrt): `5_v5a_random_forest_fft.ipynb`
- Hinweis: Im aktuellen Notebook wird kein separates RF-Modellartefakt (`.pkl/.joblib`) gespeichert.

