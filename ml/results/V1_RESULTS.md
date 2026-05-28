# V1 Results - MM-Fit (sw_r IMU, paper-nah)

## 1) Ziel und Scope
V1 implementiert eine paper-nahe Replikation der Klassifikation aus `3432701` mit Fokus auf **rechter Smartwatch-IMU**:

- Daten: `sw_r_acc` + `sw_r_gyr`
- Resampling: `50 Hz`
- Fenster: `5 s` (`250` Samples)
- Stride: `0.2 s` (`10` Samples)
- Labeling: **Majority-Class pro Fenster**
- Klassen: `10 exercises + non-exercise` (insgesamt `11`)
- Feste Splits wie im Paper (Session-basiert)

Umgesetzte Notebooks/Artefakte:
- Notebook (Quelle): `3_v1_mmfit_sw_r_paper_like.ipynb`
- Notebook (ausgeführt): `3_v1_mmfit_sw_r_paper_like_run.ipynb`
- Bestes Modell: `best_v1_sw_r.keras`
- Konfig + Normalisierung: `v1_sw_r_artifacts.json`

## 2) Daten-Splits
Session-Splits (paper-konform):
- Train: `1,2,3,4,6,7,8,16,17,18`
- Validation: `14,15,19`
- Test Seen: `9,10,11`
- Test Unseen: `0,5,12,13,20`

Fensteranzahl pro Split:
- Train: `119,123`
- Validation: `26,138`
- Test Seen: `41,041`
- Test Unseen: `60,128`

## 3) Klassenverteilung (Window-Level)
### Train (119,123)
- squats: `3,159` (`2.65%`)
- lunges: `4,112` (`3.45%`)
- bicep_curls: `2,653` (`2.23%`)
- situps: `4,019` (`3.37%`)
- pushups: `2,596` (`2.18%`)
- tricep_extensions: `3,264` (`2.74%`)
- dumbbell_rows: `2,804` (`2.35%`)
- jumping_jacks: `1,559` (`1.31%`)
- dumbbell_shoulder_press: `3,566` (`2.99%`)
- lateral_shoulder_raises: `3,584` (`3.01%`)
- non-exercise: `87,807` (`73.71%`)

### Validation (26,138)
- squats: `849` (`3.25%`)
- lunges: `1,246` (`4.77%`)
- bicep_curls: `990` (`3.79%`)
- situps: `1,192` (`4.56%`)
- pushups: `835` (`3.19%`)
- tricep_extensions: `921` (`3.52%`)
- dumbbell_rows: `766` (`2.93%`)
- jumping_jacks: `308` (`1.18%`)
- dumbbell_shoulder_press: `1,167` (`4.46%`)
- lateral_shoulder_raises: `810` (`3.10%`)
- non-exercise: `17,054` (`65.25%`)

### Test Seen (41,041)
- squats: `1,026` (`2.50%`)
- lunges: `1,343` (`3.27%`)
- bicep_curls: `950` (`2.31%`)
- situps: `1,341` (`3.27%`)
- pushups: `808` (`1.97%`)
- tricep_extensions: `1,082` (`2.64%`)
- dumbbell_rows: `857` (`2.09%`)
- jumping_jacks: `474` (`1.15%`)
- dumbbell_shoulder_press: `1,194` (`2.91%`)
- lateral_shoulder_raises: `1,105` (`2.69%`)
- non-exercise: `30,861` (`75.20%`)

### Test Unseen (60,128)
- squats: `1,471` (`2.45%`)
- lunges: `2,096` (`3.49%`)
- bicep_curls: `1,231` (`2.05%`)
- situps: `1,696` (`2.82%`)
- pushups: `1,120` (`1.86%`)
- tricep_extensions: `1,195` (`1.99%`)
- dumbbell_rows: `1,189` (`1.98%`)
- jumping_jacks: `643` (`1.07%`)
- dumbbell_shoulder_press: `1,051` (`1.75%`)
- lateral_shoulder_raises: `1,188` (`1.98%`)
- non-exercise: `47,248` (`78.58%`)

## 4) Modell und Training
### 4.1 Architektur-Hyperparameter
- Input-Shape gesamt: `(250, 6)`
- Interner Split:
  - ACC-Branch: `(250, 3)`
  - GYR-Branch: `(250, 3)`
- Branch-Block (ACC und GYR identisch):
  - `Conv1D(filters=9, kernel_size=11, strides=2, padding="same", groups=3, activation="relu")`
  - `Conv1D(filters=15, kernel_size=11, strides=2, padding="same", groups=3, activation="relu")`
  - `Conv1D(filters=24, kernel_size=11, strides=2, padding="same", activation="relu")`
  - `Flatten()`
- Fusion und Klassifikationskopf:
  - `Concatenate()`
  - `Dense(100, activation="relu")`
  - `Dense(100, activation="relu")`
  - `Dense(100, activation="relu")`
  - `Dense(11, activation="softmax")`
- Parameteranzahl: `184,215`

### 4.2 Trainings-Hyperparameter
- Optimizer: `Adam(learning_rate=1e-3)`
- Loss: `sparse_categorical_crossentropy`
- Metrik: `accuracy`
- Batch size: `128`
- Max. Epochen: `40`
- Seed: `42`
- `class_weight`: **nicht verwendet**
- Explizite Regularisierung:
  - `Dropout`: **nein**
  - `L2/weight decay`: **nein**
  - `BatchNorm`: **nein**

### 4.3 Callback-Parameter
`EarlyStopping` (konfiguriert):
- `monitor="val_accuracy"`
- `patience=10`
- `restore_best_weights=True`
- `verbose=1`

`EarlyStopping` (Defaults, nicht überschrieben):
- `min_delta=0`
- `mode="auto"`
- `baseline=None`
- `start_from_epoch=0`

`ReduceLROnPlateau` (konfiguriert):
- `monitor="val_accuracy"`
- `factor=0.1`
- `patience=5`
- `min_lr=1e-6`
- `verbose=1`

`ReduceLROnPlateau` (Defaults, nicht überschrieben):
- `mode="auto"`
- `min_delta=1e-4`
- `cooldown=0`

`ModelCheckpoint` (konfiguriert):
- `filepath="best_v1_sw_r.keras"`
- `monitor="val_accuracy"`
- `save_best_only=True`
- `verbose=1`

### 4.4 Adam-Defaults (nicht überschrieben)
- `beta_1=0.9`
- `beta_2=0.999`
- `epsilon=1e-7`
- `amsgrad=False`

### 4.5 Tatsächlicher Trainingsverlauf
- Early Stopping ausgelöst bei `Epoch 15`
- Bestes Modell: Gewichte aus `Epoch 5` wiederhergestellt

## 5) Hauptergebnisse
### Gesamtmetriken
| Split | Accuracy | Macro-F1 |
|---|---:|---:|
| Test Seen | `0.9804` | `0.9591` |
| Test Unseen | `0.9305` | `0.8110` |

Interpretation:
- Sehr starke Leistung auf Seen-Subjects.
- Spürbarer Generalisierungsabfall auf Unseen-Subjects (insb. in minority exercise classes).

## 6) Klassenweise Ergebnisse
### Test Seen
| Klasse | Precision | Recall | F1 | Support |
|---|---:|---:|---:|---:|
| squats | 0.9940 | 0.9630 | 0.9782 | 1026 |
| lunges | 0.9857 | 0.9784 | 0.9821 | 1343 |
| bicep_curls | 0.9909 | 0.6905 | 0.8139 | 950 |
| situps | 0.9009 | 0.9963 | 0.9462 | 1341 |
| pushups | 0.9755 | 0.9839 | 0.9797 | 808 |
| tricep_extensions | 0.9869 | 0.9741 | 0.9805 | 1082 |
| dumbbell_rows | 0.9870 | 0.9778 | 0.9824 | 857 |
| jumping_jacks | 1.0000 | 0.9008 | 0.9478 | 474 |
| dumbbell_shoulder_press | 0.9617 | 0.9891 | 0.9752 | 1194 |
| lateral_shoulder_raises | 0.9925 | 0.9620 | 0.9770 | 1105 |
| non-exercise | 0.9831 | 0.9911 | 0.9871 | 30861 |

### Test Unseen
| Klasse | Precision | Recall | F1 | Support |
|---|---:|---:|---:|---:|
| squats | 0.9527 | 0.3834 | 0.5468 | 1471 |
| lunges | 0.9518 | 0.5930 | 0.7307 | 2096 |
| bicep_curls | 0.9583 | 0.7474 | 0.8398 | 1231 |
| situps | 0.6597 | 0.7052 | 0.6817 | 1696 |
| pushups | 0.9631 | 0.9321 | 0.9474 | 1120 |
| tricep_extensions | 0.9920 | 0.7280 | 0.8398 | 1195 |
| dumbbell_rows | 0.8061 | 0.9579 | 0.8755 | 1189 |
| jumping_jacks | 0.9742 | 0.8227 | 0.8921 | 643 |
| dumbbell_shoulder_press | 0.9262 | 0.9791 | 0.9519 | 1051 |
| lateral_shoulder_raises | 0.6908 | 0.6111 | 0.6485 | 1188 |
| non-exercise | 0.9456 | 0.9882 | 0.9664 | 47248 |

## 7) Was wir aus V1 lernen
1. **Baseline ist stark**: V1 liefert eine robuste paper-nahe Referenz.
2. **Nicht-Übung dominiert** stark (bis `78.58%` in Unseen), daher ist Macro-F1 wichtig.
3. **Generalization Gap** vorhanden: Seen (`0.9591` Macro-F1) vs. Unseen (`0.8110` Macro-F1).
4. Schwache Unseen-Recall-Klassen: `squats`, `lunges`, `situps`, `lateral_shoulder_raises`.
5. Für V2 sind besonders sinnvoll:
   - class balancing (`class_weight`/focal loss),
   - IMU-Augmentation,
   - ggf. robustere zeitliche Modelle oder post-hoc smoothing.

## 8) Reproduzierbarkeit
- Notebook vollständig ausführen: `3_v1_mmfit_sw_r_paper_like.ipynb`
- Erwarteter Ergebnis-Output: `3_v1_mmfit_sw_r_paper_like_run.ipynb`
- Modell und Konfigurationen:
  - `best_v1_sw_r.keras`
  - `v1_sw_r_artifacts.json`
