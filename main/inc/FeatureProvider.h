#pragma once

#include <vector>

#include "tensorflow/lite/c/common.h"

class FeatureProvider {
 public:
  FeatureProvider() = default;
  ~FeatureProvider() = default;
  void SetInputData(const std::vector<float>& inputData);
  virtual void ExtractFeatures();
  void WriteDataToModel(TfLiteTensor* modelInput);

 private:
  std::vector<float> data;
};
