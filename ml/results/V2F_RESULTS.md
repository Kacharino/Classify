# V2-F Results - Class Weights + BatchNorm + Dropout(0.15) (sw_r IMU)

## Ziel
V2-F hält V2-A konstant und ergänzt Regularisierung in der Modellarchitektur.

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
- `Dropout(0.15)` nach `fc1` und `fc2`

## Hauptergebnisse
| Split | Accuracy | Macro-F1 |
|---|---:|---:|
| Test Seen | `0.9889` | `0.9790` |
| Test Unseen | `0.9497` | `0.8750` |

Training:
- Early Stopping bei `Epoch 32`
- Bestes Modell: `Epoch 22`

## Vergleich
### Gegen V2-A (entscheidend)
V2-A Referenz:
- Seen: Acc `0.9823`, Macro-F1 `0.9668`
- Unseen: Acc `0.9433`, Macro-F1 `0.8555`

Delta (V2-F minus V2-A):
- Seen Accuracy: `+0.0066`
- Seen Macro-F1: `+0.0122`
- Unseen Accuracy: `+0.0064`
- Unseen Macro-F1: `+0.0195`

### Gegen V2-D
V2-D Referenz:
- Seen: Acc `0.9871`, Macro-F1 `0.9762`
- Unseen: Acc `0.9493`, Macro-F1 `0.8730`

Delta (V2-F minus V2-D):
- Seen Accuracy: `+0.0018`
- Seen Macro-F1: `+0.0028`
- Unseen Accuracy: `+0.0004`
- Unseen Macro-F1: `+0.0020`

### Gegen V2-E
V2-E Referenz:
- Seen: Acc `0.9887`, Macro-F1 `0.9789`
- Unseen: Acc `0.9431`, Macro-F1 `0.8582`

Delta (V2-F minus V2-E):
- Seen Accuracy: `+0.0002`
- Seen Macro-F1: `+0.0001`
- Unseen Accuracy: `+0.0066`
- Unseen Macro-F1: `+0.0168`

### Gegen V1
V1 Referenz:
- Seen: Acc `0.9804`, Macro-F1 `0.9591`
- Unseen: Acc `0.9305`, Macro-F1 `0.8110`

Delta (V2-F minus V1):
- Seen Accuracy: `+0.0085`
- Seen Macro-F1: `+0.0199`
- Unseen Accuracy: `+0.0192`
- Unseen Macro-F1: `+0.0640`

## Klassenanalyse (Unseen)
Auszug Unseen F1 (V2-F):
- squats: `0.6964`
- lunges: `0.8649`
- situps: `0.7581`
- tricep_extensions: `0.9239`
- lateral_shoulder_raises: `0.7687`
- jumping_jacks: `0.9130`

Beobachtung:
- Sehr starke Gesamtleistung auf `seen` und `unseen`.
- `squats` bleibt herausfordernd, aber klar besser als in früheren Varianten.

## Fazit
- V2-F verbessert sich gegenüber V2-A, V2-D und V2-E.
- Aktueller Best-Stand für Unseen-Generalization: **V2-F**.

## Artefakte
- Notebook (Quelle + ausgeführt): `4_v2f_batchnorm_dropout015.ipynb`
- Modell: `best_v2f_batchnorm_dropout015.keras`
- Config/Norm: `v2e_batchnorm_only_artifacts.json` (Notebook enthält hier einen Dateinamen-Tippfehler beim Speichern)
