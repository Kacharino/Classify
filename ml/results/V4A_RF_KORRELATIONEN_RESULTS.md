# V4A-RF Results - Random Forest mit Korrelations-Features (36 Features, sw_r IMU)

## Ziel
V4A-RF erweitert die RF-Featurebasis um Achsen-Korrelationen und bleibt ansonsten in der RF-Konfiguration konstant.

Konstant zur RF-Pipeline:
- Daten: `sw_r_acc + sw_r_gyr`
- Resampling: `50 Hz`
- Fenster: `250` Samples (`5s`), Stride `10` (`0.2s`)
- Labeling: Majority-Class pro Fenster
- Klassen: `11` (10 Uebungen + `non-exercise`)
- Split: identisch (paper-konform)

## Aenderung gegenueber V2-RF
Feature-Set von `30` auf `36` erweitert:
- Basis (`30`): `mean`, `std`, `min`, `max`, `RMS` je Kanal (`6`)
- Neu (`+6`): Korrelationen zwischen Achsen
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
- `X_train`: `(119123, 36)`
- `X_unseen`: `(60128, 36)`
- Hinweis: `X_val` wird gebaut, aber im aktuellen Lauf nicht fuer Hyperparameter-Tuning genutzt.

## Hauptergebnisse
| Split | Accuracy | Macro-F1 |
|---|---:|---:|
| Test Seen | `0.9671` | `0.9244` |
| Test Unseen | `0.9039` | `0.7411` |

Trainingsdauer (Fit-Log):
- `100/100` Baeume nach ca. `5.8s` abgeschlossen

## Vergleich
### Gegen V2-RF (30 Features, ohne Korrelationen)
V2-RF Referenz:
- Seen: Acc `0.9616`, Macro-F1 `0.9144`
- Unseen: Acc `0.9008`, Macro-F1 `0.7357`

Delta (V4A-RF minus V2-RF):
- Seen Accuracy: `+0.0055`
- Seen Macro-F1: `+0.0100`
- Unseen Accuracy: `+0.0031`
- Unseen Macro-F1: `+0.0054`

### Gegen V1-RF
V1-RF Referenz:
- Seen: Acc `0.9688`, Macro-F1 `0.9099`
- Unseen: Acc `0.8731`, Macro-F1 `0.5813`

Delta (V4A-RF minus V1-RF):
- Seen Accuracy: `-0.0017`
- Seen Macro-F1: `+0.0145`
- Unseen Accuracy: `+0.0308`
- Unseen Macro-F1: `+0.1598`

## Klassenanalyse (Unseen)
Auszug Unseen F1 (V4A-RF):
- squats: `0.4776`
- lunges: `0.8022`
- bicep_curls: `0.7820`
- situps: `0.7628`
- dumbbell_rows: `0.4393`
- lateral_shoulder_raises: `0.6146`
- non-exercise: `0.9478`

Beobachtung:
- Das erweiterte Feature-Set verbessert die Gesamtmetriken gegenueber V2-RF.
- Trotz Zugewinnen bleiben `squats` und `dumbbell_rows` schwierige Unseen-Klassen.

## Fazit
- V4A-RF ist ein klarer Fortschritt gegenueber V2-RF.
- Korrelations-Features sind in dieser RF-Pipeline sinnvoll.

## Artefakte
- Notebook (Quelle + ausgefuehrt): `5_v4a_random_forest_korrelationen.ipynb`
- Hinweis: Im aktuellen Notebook wird kein separates RF-Modellartefakt (`.pkl/.joblib`) gespeichert.

