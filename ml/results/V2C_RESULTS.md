# V2-C Results - Class Weights + IMU Augmentation (sw_r IMU)

## Ziel
V2-C hält V2-A konstant und ergänzt nur leichte IMU-Augmentation im Training.

Unverändert zu V2-A:
- Daten: `sw_r_acc + sw_r_gyr`
- Resampling: `50 Hz`
- Fenster: `250` Samples (`5s`), Stride `10` (`0.2s`)
- Labeling: Majority-Class pro Fenster
- Klassen: `11` (10 Übungen + `non-exercise`)
- Split: identisch (paper-konform)
- Modellarchitektur: identisch
- `class_weight`: aktiv (wie V2-A)

## Änderung gegenüber V2-A
Augmentation nur im Training (`train_seq`, nicht in val/test):
- `jitter`: additives Gauß-Rauschen, `std = 0.01`
- `scaling`: amplituden scaling pro Sample/Kanal, `std = 0.05`

## Hauptergebnisse
| Split | Accuracy | Macro-F1 |
|---|---:|---:|
| Test Seen | `0.9884` | `0.9784` |
| Test Unseen | `0.9388` | `0.8357` |

Training:
- Early Stopping bei `Epoch 27`
- Bestes Modell: `Epoch 17`

## Vergleich
### Gegen V2-A (entscheidend)
V2-A Referenz:
- Seen: Acc `0.9823`, Macro-F1 `0.9668`
- Unseen: Acc `0.9433`, Macro-F1 `0.8555`

Delta (V2-C minus V2-A):
- Seen Accuracy: `+0.0061`
- Seen Macro-F1: `+0.0116`
- Unseen Accuracy: `-0.0045`
- Unseen Macro-F1: `-0.0198`

### Gegen V1
V1 Referenz:
- Seen: Acc `0.9804`, Macro-F1 `0.9591`
- Unseen: Acc `0.9305`, Macro-F1 `0.8110`

Delta (V2-C minus V1):
- Seen Accuracy: `+0.0080`
- Seen Macro-F1: `+0.0193`
- Unseen Accuracy: `+0.0083`
- Unseen Macro-F1: `+0.0247`

## Klassenanalyse (Unseen)
Auszug Unseen F1 (V2-C):
- squats: `0.5379`
- lunges: `0.8386`
- situps: `0.8014`
- lateral_shoulder_raises: `0.7479`

Beobachtung:
- V2-C verbessert v. a. `seen` deutlich.
- Für das eigentliche Ziel (`unseen`-Generalisierung) ist V2-C schlechter als V2-A.

## Fazit
- V2-C ist besser als V1, aber schlechter als V2-A auf Unseen.
- Aktuell beste Variante für Unseen-Generalization bleibt: **V2-A**.

## Artefakte
- Notebook (Quelle): `4_v2c_augmentation.ipynb`
- Notebook (ausgeführt): `4_v2c_augmentation_run.ipynb`
- Modell: `best_v2c_sw_r_class_weight_aug.keras`
- Config/Norm: `v2c_sw_r_artifacts.json`
