# Classify 🏋️

Bachelorarbeit an der FH Technikum Wien: Vergleich von 1D-CNN und Random Forest
zur Klassifikation von 11 Fitnessübungen anhand von Handgelenk-IMU-Daten
(Apple Watch, 50 Hz) – mit Deployment als native watchOS-App.

---

## 📱 App Preview

<p align="center">
  <img src="assets/ClassifyDemo.png" width="700" alt="Classify App Preview"/>
</p>

---

## 🛠️ Tech Stack

**ML & Training**

![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![TensorFlow](https://img.shields.io/badge/TensorFlow-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white)
![scikit-learn](https://img.shields.io/badge/scikit--learn-F7931E?style=for-the-badge&logo=scikit-learn&logoColor=white)
![MLflow](https://img.shields.io/badge/MLflow-0194E2?style=for-the-badge&logo=mlflow&logoColor=white)
![Google Colab](https://img.shields.io/badge/Google_Colab-F9AB00?style=for-the-badge&logo=googlecolab&logoColor=white)

**Deployment**

![Swift](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![Xcode](https://img.shields.io/badge/Xcode-147EFB?style=for-the-badge&logo=xcode&logoColor=white)
![CoreML](https://img.shields.io/badge/CoreML-000000?style=for-the-badge&logo=apple&logoColor=white)

---

## ✨ Was die App kann

- Fitnessübungen in Echtzeit erkennen (10 Kraftübungen + Non-Exercise)
- IMU-Daten vom Handgelenk erfassen und klassifizieren
- Ergebnis direkt auf der Apple Watch anzeigen

---

## ⚙️ Wie ich es gebaut habe

1. **Datenvorbereitung** – MM-Fit Dataset (Modalität `sw_r`, 50 Hz),
   Sliding Window (250 Samples, Stride 25), Achsenkorrektur für linkes Handgelenk
2. **Modellentwicklung** – Vergleich von 1D-CNN (Dual-Branch für Acc/Gyro)
   und Random Forest mit 114 handcrafted Features
3. **Hyperparameter-Optimierung** – Optuna mit TPE Sampler + PercentilePruner,
   Experiment Tracking via MLflow
4. **Deployment** – CoreML Export musste manuell via MIL gebaut werden
   (Workaround für TF 2.16 XLA-Bug), Inferenz via Majority Vote
5. **watchOS App** – Swift, WCSession `transferUserInfo()` statt `sendMessage()`
   (IDS Bluetooth Timeout bei 50 Hz)

**Bestes Ergebnis:** CNN V3-C – Macro-F1 = **0.8946** auf ungesehenen Testdaten

---

## 💡 Was ich gelernt habe

Machine Learning funktioniert nicht per Zauberhand. Man kann nicht einfach ein
Modell mit Daten füttern und erwarten dass es automatisch alles lernt.
Was wirklich den Unterschied macht:

- **Feintuning ist alles** – Hyperparameter-Optimierung, Datenaufbereitung
  und Modellarchitektur entscheiden über Erfolg oder Misserfolg
- **Gute Zahlen ≠ gutes Deployment** – ein hoher Accuracy-Wert bedeutet nicht,
  dass das Modell in der realen Welt genauso gut funktioniert
- **Versionierung von Anfang an** – MLflow und ähnliche Tools (z.B. Neptune)
  sind kein Nice-to-have, sondern essentiell um den Überblick zu behalten
- **Google Colab als Gamechanger** – GPU-Training (T4) war kostenlos möglich,
  auch ohne leistungsstarke Hardware. Ein MacBook Air reicht völlig aus,
  wenn man die richtigen Tools kennt
- **AI als Werkzeug** – Claude Code hat mir enorm geholfen, vor allem für Swift
  und CoreML, Sprachen die ich vorher nicht kannte. Wenn man AI gut führen kann,
  kann man damit Dinge umsetzen die weit über das eigene aktuelle Wissen hinausgehen

---

## 🔧 Was man verbessern könnte

- Mehr und vielfältigere Trainingsdaten – am besten selbst aufgezeichnet,
  von mehreren Personen mit verschiedenen Bewegungsmustern
- Dadurch würden auch aktuell unzuverlässige Klassen (Squats, Push-ups,
  Lateral Raises) besser klassifiziert werden

---

## 🚀 How to Run

### watchOS App
1. Xcode öffnen und `Classify.xcodeproj` laden
2. iPhone und Apple Watch verbinden
3. Build & Run auf dem Gerät

> **Voraussetzungen:** Mac, Xcode, iPhone, Apple Watch

### ML Training
Der Trainingscode befindet sich im `ml/` Ordner.
Die Notebooks wurden auf Google Colab mit T4 GPU ausgeführt.

> **Voraussetzungen:** Python, TensorFlow, scikit-learn, Optuna, MLflow  
> Empfehlung: Google Colab für GPU-Zugang
