# Model creation

**Table of Contents:**

1. [General information](#generalinformation)
1. [preprocess](#preprocess)
1. [model](#model)
1. [convert](#convert)
1. [main](#main)

---

## General information
This file will guide you through the designed architecture for the model ceation part in python. This arcitecture is written with simplicity mind, if you want to have see a more mathematical perspecitve you can link here. The figure below shows the data flow we aimed for. <br>In this section we will focus on the Tensorflow enviroment part. 

![Data flow](/img/schema_pipeline.png)

## preprocess

- how to process data
- examples
    - fourier transform
    - one-hot encoding
- keras dataset class
- correspondence to FeatureProvider.cpp

## 

- dense layers
- images and cnns
- time series classification
- transfer learning

## Model training

- overfitting
- keras callbacks
    - early stopping
    - intermediate saving as .h5
- full model saving as .pb
- how to run a single prediction

## Model conversion

- summary

### Convert TensorFlow/Keras model to TfLite

- quantization
- representative dataset
- regularization and generalization
- accuracy drop
- data types
    float32 default
    uint8_t deprecation
    possibilities with int8_t, int16_t

### Convert TfLite model to C-string

- evaluating model.cpp (C-array) size
    - ESP32 memory limitations
    - kTensorArenaSize implications
- copying model.cpp to main/src/model.cpp
