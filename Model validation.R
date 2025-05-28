# This script is licensed under the MIT License.
# Copyright (c) 2024 (Dhakal, Milan)

final_rf_model      


# calculating accuracy with making function

evaluate_rf_model <- function(final_rf_model, test_data) {
  # Predictions (class)
  predictions <- predict(final_rf_model, test_data)
  
  # Predictions (probability)
  pred_prob <- predict(final_rf_model, test_data, type = "prob")[, "1"]
  
  # Confusion Matrix
  conf_matrix <- confusionMatrix(as.factor(predictions), as.factor(test_data$fire))
  
  # Extract Confusion Matrix Components
  TP <- conf_matrix$table[2, 2]
  TN <- conf_matrix$table[1, 1]
  FP <- conf_matrix$table[1, 2]
  FN <- conf_matrix$table[2, 1]
  
  # Metrics
  overall_accuracy <- (TP + TN) / (TP + TN + FP + FN)
  sensitivity <- TP / (TP + FN)
  specificity <- TN / (TN + FP)
  precision <- TP / (TP + FP)
  f1_score <- 2 * (precision * sensitivity) / (precision + sensitivity)
  
  # Kappa
  total <- TP + TN + FP + FN
  expected_agreement <- ((TP + FP) * (TP + FN) + (TN + FP) * (TN + FN)) / total^2
  kappa <- (overall_accuracy - expected_agreement) / (1 - expected_agreement)
  
  # TSS
  TSS <- sensitivity - (FP / (FP + TN))
  
  # AUC
  auc_value <- roc(test_data$fire, pred_prob, levels = c(0, 1), direction = "<")$auc
  
  # Output all in a single line
  cat("Accuracy:", round(overall_accuracy, 4),
      "| Recall:", round(sensitivity, 4),
      "| Specificity:", round(specificity, 4),
      "| Precision:", round(precision, 4),
      "| F1 Score:", round(f1_score, 4),
      "| Kappa:", round(kappa, 4),
      "| TSS:", round(TSS, 4),
      "| AUC:", round(auc_value, 4), "\n")
}



evaluate_rf_model(final_rf_model, test_data)
