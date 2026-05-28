# V2-D Results - Class Weights + BatchNorm + Dropout (sw_r IMU)

## Ziel
V2-D hält V2-A konstant und ergänzt nur Regularisierung in der Modellarchitektur.

Unverändert zu V2-A:
- Daten: `sw_r_acc + sw_r_gyr`
- Resampling: `50 Hz`
- Fenster: `250` Samples (`5s`), Stride `10` (`0.2s`)
- Labeling: Majority-Class pro Fenster
- Klassen: `11` (10 Übungen + `non-exercise`)
- Split: identisch (paper-konform)
- `class_weight`: aktiv (wie V2-A)
- Loss: `sparse_categorical_crossentropy`

## Änderung gegenüber V2-A
- `BatchNormalization` nach jeder `Conv1D` in beiden Branches (ACC/GYR)
- `Dropout(0.3)` nach `fc1` und `fc2`

## Hauptergebnisse
| Split | Accuracy | Macro-F1 |
|---|---:|---:|
| Test Seen | `0.9871` | `0.9762` |
| Test Unseen | `0.9493` | `0.8730` |

Training:
- Early Stopping bei `Epoch 35`
- Bestes Modell: `Epoch 25`

## Vergleich
### Gegen V2-A (entscheidend)
V2-A Referenz:
- Seen: Acc `0.9823`, Macro-F1 `0.9668`
- Unseen: Acc `0.9433`, Macro-F1 `0.8555`

Delta (V2-D minus V2-A):
- Seen Accuracy: `+0.0048`
- Seen Macro-F1: `+0.0094`
- Unseen Accuracy: `+0.0060`
- Unseen Macro-F1: `+0.0175`

### Gegen V1
V1 Referenz:
- Seen: Acc `0.9804`, Macro-F1 `0.9591`
- Unseen: Acc `0.9305`, Macro-F1 `0.8110`

Delta (V2-D minus V1):
- Seen Accuracy: `+0.0067`
- Seen Macro-F1: `+0.0171`
- Unseen Accuracy: `+0.0188`
- Unseen Macro-F1: `+0.0620`

## Klassenanalyse (Unseen)
Auszug Unseen F1 (V2-D):
- squats: `0.6055`
- lunges: `0.8915`
- situps: `0.7739`
- tricep_extensions: `0.9230`
- lateral_shoulder_raises: `0.7621`
- jumping_jacks: `0.9341`

Beobachtung:
- Sehr starke Gesamtleistung auf Unseen.
- `squats` bleibt die schwierigste Klasse.

## Fazit
- V2-D verbessert sowohl `seen` als auch `unseen` gegenüber V2-A.
- Aktueller Best-Stand für Unseen-Generalization: **V2-D**.

## Artefakte
- Notebook (Quelle + ausgeführt): `4_v2d_batchnorm_dropout.ipynb`
- Modell: `best_v2d_dropout_batchnorm.keras`
- Config/Norm: `v2d_dropout_batchnorm_artifacts.json`
