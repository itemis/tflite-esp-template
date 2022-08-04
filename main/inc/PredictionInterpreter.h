#pragma once

#include "tensorflow/lite/c/common.h"

enum class Prediction {
  UNKNOWN = 0
  // add your predictions
};

class PredictionInterpreter {
 public:
  PredictionInterpreter() = default;
  ~PredictionInterpreter() = default;
  virtual Prediction GetResult(TfLiteTensor* model_output);
};