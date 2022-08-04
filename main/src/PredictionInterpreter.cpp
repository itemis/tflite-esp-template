#include "PredictionInterpreter.h"

Prediction PredictionInterpreter::GetResult(TfLiteTensor* model_output) {
  return Prediction::UNKNOWN;
}