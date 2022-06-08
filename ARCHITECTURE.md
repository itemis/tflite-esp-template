# Architecture

![schema pipeline](img/schema_pipeline.png)

## [Components/](./components/README.md)

The first folder components/ will contain all libraries we need for our project.

## [img/](./img/README.md)

Not much to see here, some images and documentation!

## [main/](./main/README.md)

Under main/ you find the code that runs on the microcontroller during deployment. We call this the deployment pipeline. It’s a continuous cycle of receiving data from connected sensors, applying manipulations to the data (called preprocessing), making predictions, interpreting those and finally performing an action. From the figure below you can gather the internal structure of the main folder. Let’s go over each file.

*TrainDataRecorder.cpp*<br>
We record sensor data to train a machine learning model. The data is written to a CSV file, which we can load later on using Python.

*DataProvider.cpp*<br>
The code in this file provides sensor data to the model during deployment of a microcontroller. The structure is similar to TrainDataRecorder.cpp file; instead of writing to a CSV file, data is passed to the FeatureProvider class.

*FeatureProvider.cpp*<br>
The FeatureProvide applies preprocessing to the data coming in from the DataProvider. The included class has three functions. SetInputData receives data from the DataProvider, ExtractFeatures applies mathematical transformations onto data to extract relevant features. This transformation needs to be the same that you apply to the data that the ML model is trained with. That is because our model can only understand data that is similar to our training data. With the last function WriteDataToModel we pass the preprocessed data to our model in order to interpret the data.

*main.cpp*<br>
Here we wrap the entry function for FreeRTOS. Within the entry function we create a task which contains two functions, the setup and loop function, which you can find in the main_functions.cpp.

*micro_model.cpp*<br>
This file contains the converted TfLite model in the form of a C array.

*PredictionInterpreter.cpp*<br>
Within this file we interpret the raw result produced by the TfLite interpreter. An example of this is mapping a numerical value to a semantic concept. For example in a binary scenario a value <0.5 could mean no and a value >=0.5 would be interpreted as yes.

*PredictionHandler.cpp*<br>
Depending on what kind of result PredictionInterpreter gives us, we control actuators or send data to the cloud for further action.
 
*main_functions.cpp*<br>
Everything comes together here. We define a setup and loop function as initialized in the main.cpp file. This keeps things simple and in line with Arduino syntax. Within the setup function we configure TfLite to read our model and we initialize periphery modules . Within the loop function we call the data and feature providers to receive the sensor data in its desired shape. Then we pass the data to the TfLite interpreter we configured earlier. The resulting prediction is passed to the prediction interpreter to get a result based on a threshold. Afterwards we call the prediction handler to act on the result.

## [model_creation/](./model_creation/README.md)

In this folder you find the model creation pipeline, where we use the CSV file provided by the TrainDataRecorder.cpp file to develop a machine learning model with the TensorFlow library. This folder contains three main files which we will discuss in detail in the next section.

*preprocess.ipynb*<br>
We use this file to preprocess our data and to split data into three sets; namely training, validation and test data.

*model.ipynb*<br>
Here we design and train a machine learning model.

*convert.ipynb*<br>
This file converts the model from TensorFlow format to a TfLite format and lastly to a C array which contains all the information about the model.

## [scripts/](./scripts/README.md)

This folder contains two scripts. The first one update_components downloads all the needed dependencies. The second one copies the content of your developed c array string to the appropriate file in the main folder. You should take a look into this folder before you start working with this repository.
