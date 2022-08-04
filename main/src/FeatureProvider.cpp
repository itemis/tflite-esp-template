#include "FeatureProvider.h"

void FeatureProvider::SetInputData(const std::vector<float>& inputData) {
  std::copy(inputData.begin(), inputData.end(), data.begin());
}

void FeatureProvider::ExtractFeatures() {
  // apply something to your data
}

void FeatureProvider::WriteDataToModel(TfLiteTensor* modelInput) {
  // TODO(nrieder@itemis.com): check size of modelInput data.
  std::copy(data.begin(), data.end(), modelInput->data.f);
}