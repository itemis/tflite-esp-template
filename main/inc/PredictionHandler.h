#pragma once

#include "PredictionInterpreter.h"

class PredictionHandler {
 public:
  PredictionHandler() = default;
  ~PredictionHandler() = default;
  void Update(Prediction prediction);

 private:
};