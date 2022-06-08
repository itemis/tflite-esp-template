# TinyML deployment 

**Table of Contents:**

1. [General information](#generalinformation)
2. [TrainingDataRecorder](#traindatarecorder)
3. [DataProvider](#dataprovider)
4. [FeatureProvider](#featureprovider)
5. [main](#main)
6. [main_function](#mainfunctions)
7. [PredictionInterpreter](#predictioninterpreter)
8. [PredictionHandler](#predictionhandler)

---

## General information
This file will guide you through the architecture for the embedded device in greater detail than [ARCHITECTURE.md](../ARCHITECTURE.md).
We focus on describing the initialization process and the super loop implemented in `main_functions.cpp` in greater detail.
Our embedded architecture is based on the TinyML pipeline of [Pete Warden and Daniel Situnayake](https://tinymlbook.files.wordpress.com/2020/01/tflite_micro_preview.pdf).
Our changes are aimed at making the architecture more beginner friendly and converting code from a C-style to an OOP and C++11 based style.
Accordingly we use classes to pipe our data through the different stages of processing.
The figure below summarizes the data flow.

![Data flow](/img/schema_pipeline_simplified.png)

## TrainDataRecorder

This file should be used to record some training data. This data needs to be stored in some way. We usally pipe the data to a CSV file.

## DataProvider

This file  is almost identical to TrainDataRecorder except for stored data part. This class contains two functions. The first function is called init(). We use this file to initiliaze our sensors. The second function is called Read(). Here we read the sensor data. This file pipes the incoming data to the feature provider.

## FeatureProvider

Within this class we implemented three functions. The first one SetInputData() copies the data from DataProvider into a variable from FeatureProvider. ExtractFeatures() performs some mathematical operations on the data to make it easier for the model to recognize features. Keep in mind, the operations used, have to be the same ones as the operations used during model creation. The last function is called WriteDataToModel. This functions copies all the preprocessed data to our TfLite input tensor.

## main

We use this file as a wrapper for the main function `app_main()` which is required by FreeRTOS. The `app_main()` function creates tasks within FreeRTOS which contains functions. The Task creates the setup und main function we use in `main_function.cpp` to run our code in an "arduinoish" way.


## main_functions

First we create a namespace in which we declare some variables and arrays we will use later to store some values and tensors. We also initialize the tensor arena size, which declares the needed memory space for our model. The last step is to initialize our class objects which we will use to send our data through the different steps.

After that we jump into the setup function. Where we let our `error_reporter` pointer point to the address of a micro error reporter. We need to do that because the micro error reporter is developed for MPUs as a derived class of error reporter, but unfortunately it doesn't have access to all functionality, unless we do the above pointer magic.

```c++
    static tflite::MicroErrorReporter micro_error_reporter;
    error_reporter = &micro_error_reporter;
```
Now we import our C array, containing the model information to TfLite micro.
This is done just by calling the `GetModel` function and passing the micro model file as an argument.

```c++
    model = tflite::GetModel(micro_model);
```

Then we create an object called resolver from `AllOpsResolver`. This object contains basically all possible operations that our model needs to be executed. To load all operations is a very inefficent way to initiliaze the model. There's another way to load only the needed operations but we will keep it simple, here. If you wanna know which operations our model needs, see [Model_creation.md](../model_creation/README.md).
Then we pass the resolver together with our model pointer, the `tensor_arena` array, the actual value `TensorArenaSize`, and `error_reporter` to the interpreter.

The interpreter is a TfLite object that has all information about our model, which operations have to be loaded and how much memory the whole AI will need.
Also the interpreter holds the input and output tensors, we need to pass our data into. 
We set our variables `model_input` and `model_output` to those tensors for convenience.

```c++
    model_input = interpreter->input(0);
    model_output = interpreter->output(0);
```
To check if our model has the right shape we use the following if statement.

```c++
    if ((model_input->dims->size != 4 || (model_input->dims->data[0] != 1) ||
        (model_input->dims->data[1] != 128) ||
        (model_input->dims->data[2] != 3) ||
        (model_input->dims->data[3] != 1) ||
        (model_input->type != kTfLiteFloat32))) {
        error_reporter->Report("Bad input tensor parameters in model\n");
        return;
    }
```
below you can find a example using data from a accelerometer which provides 128 per axis and every datapoint is a scalar.

    - dim 0 -> TfLite wrapper
    - dim 1 -> we wait for 128 values to be stored
    - dim 2 -> we do that for 3 channels
    - dim 3 -> every channel contains a scalar at the time
    - type  -> data type we used for our input while model creation

In order to know which dimensions you need, you have to know how the model was developed.

The last thing we do in the setup function ist to initialize the periphery by calling the Init() function from data_provider.

Now we jump into the loop() function. This function is very short thanks to our architecture. First we call SetInputData from our object feature_provider, passing as argument the Read() function from our object data_provider. After that we can extract features from the data within feature_provider by calling the function ExtractFeatures(). Then we call the function WriteDataToModel with the model_input variable as argument. Thats how our data goes in the interpreter.
The Interpreter calls now the function Invoke(), which does all the magic for us, by knowing all parameters it needs to know. it automatically writes the output of the Invoke function to our model_output variable. This variable we pass as argument to our prediction_interpreter to interpret the result and then it goes to prediction_handler to do something with the result. These two objects we will discuss now.

```c++
void loop() {
    // read raw data and convert data to format suitable for model
    feature_provider.SetInputData(data_provider.Read());
    feature_provider.ExtractFeatures();
    feature_provider.WriteDataToModel(model_input);

    // run inference on pre-processed data
    TfLiteStatus invoke_status = interpreter->Invoke();
    if (invoke_status != kTfLiteOk) {
        error_reporter->Report("Invoke failed");
        return;
    }

    // interpret raw model predictions
    auto prediction = prediction_interpreter.GetResult(model_output);

    // act upon processed predictions
    prediction_handler.Update(prediction);

    vTaskDelay(0.5 * pdSECOND);
}
```

## PredictionInterpreter

Within this file we've created a function called GetResult() where we take the output tensor from the interpreter and apply a simple threshold differentiation in which we say that every output below 50% means idle state and every output above 50% means circle state. below you can find more examples, keep in mind that your solution has to fit your model output.

- examples
    - function over n-ary-class probabilities
        - class 1 has 0.56
        - class 2 has 0.33
        - class 3 has 0.65
        - max function returns class 3
    - mapping of enum to semantics
        - class 1 maps to apple
        - class 2 maps to orange
        - class 3 maps to pear

## PredictionHandler

Here we can use the output from PredictionInterpreter to perform some actions with it. Within the file you can find the Update() function which we use to simply print the actual state. but you can do some fancy stuff with it below you can find some examples

- examples
    - cloud interaction
    - actuator control
    - Grafana
    - MQTT
    - WiFi

