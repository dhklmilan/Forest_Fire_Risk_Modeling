# This script is licensed under the MIT License.
# Copyright (c) 2024 (Dhakal, Milan)


#============== HYPERPARAMETER TUNNING WITOHUT CROSS VALIDATION ===========================================================
#==============                                                 ===========================================================

# Initialize best model performance tracking without cross validation
best_auc_rf <- 0
best_model_rf <- NULL
best_params_rf <- list()
# Perform grid search
for (mtry_val in c(1, 3, 5, 7, 9, 11)) {
  for (nodesize_val in c(1, 3, 5, 7)) {
    for (ntree_val in c(200, 300, 500, 700, 1000)) {
      
      gc()
      
      # Train Random Forest model
      rf_model <- randomForest(
        fire ~ ., 
        data = train_data, 
        ntree = ntree_val, 
        mtry = mtry_val, 
        nodesize = nodesize_val
      )
      
      # Predict probabilities on testing data
      test_prob <- predict(rf_model, test_data, type = "prob")[, '1']
      
      # Compute AUC
      
      auc_value <- roc(test_data$fire, test_prob, levels = c(0,1), direction = "<")$auc
      
      
      cat("Training model with mtry =", mtry_val, 
          ", nodesize =", nodesize_val, ", ntree =", ntree_val,
          "    AUC:", auc_value, "\n")
      
      # Store best model
      if (auc_value > best_auc_rf) {  # Compare with best_auc_rf
        best_auc_rf <- auc_value
        best_model_rf <- rf_model
        best_params_rf <- list(mtry = mtry_val, nodesize = nodesize_val, ntree = ntree_val)
        
        gc()
        
      }
    }
  }
}



best_model_rf

# Retrain best model on full dataset using best hyperparameters
final_rf_model <- randomForest(
  fire ~ .,
  data = train_data,
  ntree = best_params_rf$ntree,
  mtry = best_params_rf$mtry,
  nodesize = best_params_rf$nodesize
)
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



# ==========================hyperparameter tunnig with k fold cross validation ============================================================================
# i can not perform k fold cross validation due to insufficient data sets.
# Set number of folds
k_folds <- 5

# Create k-folds on the full dataset
set.seed(42)
folds <- createFolds(train_data$fire, k = k_folds, list = TRUE, returnTrain = FALSE)


best_auc_rf <- 0
best_model_rf <- NULL
best_params_rf <- list()

for (mtry_val in c(1, 3, 5, 7, 9, 11)) {
  for (nodesize_val in c(1, 3, 5, 7)) {
    for (ntree_val in c(200, 300, 500, 700, 1000)) {
      
      auc_scores <- c()
      
      for (i in 1:k_folds) {
        gc()
        
        # Correctly split train_data into fold-train and fold-test
        fold_test_indices <- folds[[i]]
        cv_test_data <- train_data[fold_test_indices, ]
        cv_train_data <- train_data[-fold_test_indices, ]
        
        rf_model <- randomForest(
          fire ~ ., 
          data = cv_train_data, 
          ntree = ntree_val, 
          mtry = mtry_val, 
          nodesize = nodesize_val
        )
        
        test_prob <- predict(rf_model, cv_test_data, type = "prob")[, "1"]
        auc_fold <- roc(cv_test_data$fire, test_prob, levels = c(0, 1), direction = "<")$auc
        auc_scores <- c(auc_scores, auc_fold)
      }
      
      mean_auc <- mean(auc_scores)
      cat("CV mean AUC for mtry =", mtry_val, 
          ", nodesize =", nodesize_val, ", ntree =", ntree_val,
          "    Mean AUC:", mean_auc, "\n")
      
      if (mean_auc > best_auc_rf) {
        best_auc_rf <- mean_auc
        best_model_rf <- rf_model  # this will be from the last fold
        best_params_rf <- list(mtry = mtry_val, nodesize = nodesize_val, ntree = ntree_val)
        gc()
      }
    }
  }
}

# Retrain best model on full dataset using best hyperparameters
final_rf_model <- randomForest(
  fire ~ .,
  data = train_data,
  ntree = best_params_rf$ntree,
  mtry = best_params_rf$mtry,
  nodesize = best_params_rf$nodesize
)
final_rf_model
best_model_rf



