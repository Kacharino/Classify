# V2-B Results - Focal Loss (sw_r IMU)

## Ziel
V2-B hält die V1-Pipeline konstant und ersetzt nur die Loss-Funktion durch **Sparse Focal Loss**.

Unverändert zu V1:
- Daten: `sw_r_acc + sw_r_gyr`
- Resampling: `50 Hz`
- Fenster: `250` Samples (`5s`), Stride `10` (`0.2s`)
- Labeling: Majority-Class pro Fenster
- Klassen: `11` (10 Übungen + `non-exercise`)
- Split: identisch (paper-konform)
- Modellarchitektur: identisch
- Callbacks: identisch

## Änderung gegenüber V1
- Loss: von `sparse_categorical_crossentropy` auf Sparse Focal Loss
- Parameter:
  - `gamma = 2.0`
  - `alpha = None`
- `class_weight`: **nicht verwendet**

## Hauptergebnisse
| Split | Accuracy | Macro-F1 |
|---|---:|---:|
| Test Seen | `0.9851` | `0.9696` |
| Test Unseen | `0.9379` | `0.8429` |

Training:
- Early Stopping bei `Epoch 14`
- Bestes Modell: `Epoch 4`

## Vergleich
### Gegen V1
V1 Referenz:
- Seen: Acc `0.9804`, Macro-F1 `0.9591`
- Unseen: Acc `0.9305`, Macro-F1 `0.8110`

Delta (V2-B minus V1):
- Seen Accuracy: `+0.0047`
- Seen Macro-F1: `+0.0105`
- Unseen Accuracy: `+0.0074`
- Unseen Macro-F1: `+0.0319`

### Gegen V2-A
V2-A Referenz:
- Seen: Acc `0.9823`, Macro-F1 `0.9668`
- Unseen: Acc `0.9433`, Macro-F1 `0.8555`

Delta (V2-B minus V2-A):
- Seen Accuracy: `+0.0028`
- Seen Macro-F1: `+0.0028`
- Unseen Accuracy: `-0.0054`
- Unseen Macro-F1: `-0.0126`

## Klassenanalyse (Unseen)
V2-B ist insgesamt stark, aber gegenüber V2-A auf Unseen schwächer.
Auszug Unseen F1 (V2-B):
- squats: `0.5708`
- lunges: `0.7963`
- situps: `0.7513`
- lateral_shoulder_raises: `0.6901`

## Fazit
- V2-B verbessert sich klar gegenüber V1.
- Für das eigentliche Ziel (**Unseen-Generalization**) bleibt **V2-A besser**.
- Aktueller Best-Stand für nächste Iteration: **V2-A als neue Arbeitsbasis**.

## Artefakte
- Notebook (Quelle): `4_v2b_focal_loss.ipynb`
- Notebook (ausgeführt): `4_v2b_focal_loss_run.ipynb`
- Modell: `best_v2b_sw_r_focal.keras`
- Config/Norm: `v2b_sw_r_artifacts.json`
