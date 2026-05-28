import mlflow

# Experiment starten
mlflow.set_experiment("mein_erstes_experiment")

with mlflow.start_run(run_name="test_run"):
    
    # Parameter loggen
    mlflow.log_param("max_depth", 10)
    mlflow.log_param("n_estimators", 100)
    
    # Simuliertes Training...
    unseen_f1 = 0.7599
    seen_f1 = 0.9500
    
    # Metriken loggen
    mlflow.log_metric("unseen_macro_f1", unseen_f1)
    mlflow.log_metric("seen_macro_f1", seen_f1)

print("Run abgeschlossen!")