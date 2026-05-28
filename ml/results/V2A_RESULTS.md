# V2-A Results - Class Weights (sw_r IMU)

## Ziel
V2-A hält die V1-Pipeline konstant und ergänzt nur `class_weight` im Training.

Unverändert zu V1:
- Daten: `sw_r_acc + sw_r_gyr`
- Resampling: `50 Hz`
- Fenster: `250` Samples (`5s`), Stride `10` (`0.2s`)
- Labeling: Majority-Class pro Fenster
- Klassen: `11` (10 Übungen + `non-exercise`)
- Split: identisch (paper-konform)
- Modellarchitektur: identisch

## Änderung gegenüber V1
- In `model.fit(...)` wurde `class_weight=class_weight_dict` ergänzt.
- Gewichte aus Train-Labels: `w_c = N / (K * n_c)`.

Verwendete Klassengewichte:
- squats: `3.4281`
- lunges: `2.6336`
- bicep_curls: `4.0819`
- situps: `2.6945`
- pushups: `4.1716`
- tricep_extensions: `3.3178`
- dumbbell_rows: `3.8621`
- jumping_jacks: `6.9464`
- dumbbell_shoulder_press: `3.0368`
- lateral_shoulder_raises: `3.0216`
- non-exercise: `0.1233`

## Hauptergebnisse
| Split | Accuracy | Macro-F1 |
|---|---:|---:|
| Test Seen | `0.9823` | `0.9668` |
| Test Unseen | `0.9433` | `0.8555` |

Training:
- Early Stopping bei `Epoch 21`
- Bestes Modell: `Epoch 11`

## Vergleich zu V1
V1 Referenz:
- Seen: Acc `0.9804`, Macro-F1 `0.9591`
- Unseen: Acc `0.9305`, Macro-F1 `0.8110`

Delta (V2-A minus V1):
- Seen Accuracy: `+0.0019`
- Seen Macro-F1: `+0.0077`
- Unseen Accuracy: `+0.0128`
- Unseen Macro-F1: `+0.0445`

## Klassenanalyse (Unseen)
Deutliche Verbesserungen in mehreren problematischen Klassen (Recall/F1), insbesondere:
- `lunges`: Recall stark gestiegen
- `situps`: deutlich stabiler
- `tricep_extensions`: deutlich stabiler
- `squats`: verbessert, aber weiterhin ausbaufähig

Beispiel Unseen (V2-A):
- squats: F1 `0.6414`
- lunges: F1 `0.9187`
- situps: F1 `0.8112`
- tricep_extensions: F1 `0.8964`
- lateral_shoulder_raises: F1 `0.7273`

## Artefakte
- Notebook (Quelle): `4_v2a_class_weight.ipynb`
- Notebook (ausgeführt): `4_v2a_class_weight_run.ipynb`
- Modell: `best_v2a_sw_r_class_weight.keras`
- Config/Norm: `v2a_sw_r_artifacts.json`

## Fazit
V2-A ist ein klarer Fortschritt gegenüber V1, besonders auf **Unseen**-Daten.
`class_weight` ist damit als sinnvoller Standard für die nächsten Iterationen bestätigt.
