# V2-E Results - Class Weights + BatchNorm (ohne Dropout, sw_r IMU)

## Ziel
V2-E hält V2-A konstant und ergänzt nur `BatchNormalization` in der Modellarchitektur.

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
- **Kein** `Dropout` (Unterschied zu V2-D)

## Hauptergebnisse
| Split | Accuracy | Macro-F1 |
|---|---:|---:|
| Test Seen | `0.9887` | `0.9789` |
| Test Unseen | `0.9431` | `0.8582` |

Training:
- Early Stopping bei `Epoch 27`
- Bestes Modell: `Epoch 17`

## Vergleich
### Gegen V2-A (entscheidend)
V2-A Referenz:
- Seen: Acc `0.9823`, Macro-F1 `0.9668`
- Unseen: Acc `0.9433`, Macro-F1 `0.8555`

Delta (V2-E minus V2-A):
- Seen Accuracy: `+0.0064`
- Seen Macro-F1: `+0.0121`
- Unseen Accuracy: `-0.0002`
- Unseen Macro-F1: `+0.0027`

### Gegen V2-D
V2-D Referenz:
- Seen: Acc `0.9871`, Macro-F1 `0.9762`
- Unseen: Acc `0.9493`, Macro-F1 `0.8730`

Delta (V2-E minus V2-D):
- Seen Accuracy: `+0.0016`
- Seen Macro-F1: `+0.0027`
- Unseen Accuracy: `-0.0062`
- Unseen Macro-F1: `-0.0148`

### Gegen V1
V1 Referenz:
- Seen: Acc `0.9804`, Macro-F1 `0.9591`
- Unseen: Acc `0.9305`, Macro-F1 `0.8110`

Delta (V2-E minus V1):
- Seen Accuracy: `+0.0083`
- Seen Macro-F1: `+0.0198`
- Unseen Accuracy: `+0.0126`
- Unseen Macro-F1: `+0.0472`

## Klassenanalyse (Unseen)
Auszug Unseen F1 (V2-E):
- squats: `0.6815`
- lunges: `0.8379`
- situps: `0.7693`
- tricep_extensions: `0.9109`
- lateral_shoulder_raises: `0.7468`
- jumping_jacks: `0.9327`

Beobachtung:
- Sehr starke `seen`-Leistung.
- Unseen insgesamt nur leicht über V2-A und klar unter V2-D.

## Fazit
- V2-E ist besser als V1 und auf Augenhöhe mit V2-A bei Unseen.
- Für das Hauptziel (Unseen-Generalization) bleibt **V2-D** die bessere Variante.

## Artefakte
- Notebook (Quelle + ausgeführt): `4_v2e_batchnorm_only.ipynb`
- Modell: `best_v2e_batchnorm_only.keras`
- Config/Norm: `v2e_batchnorm_only_artifacts.json`
