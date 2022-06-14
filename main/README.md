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
We focus on describing the initialization process and the super loop implemented in `main_functions.cpp`.
The figure below summarizes the data flow in the embedded environment.

![Data flow](/img/schema_deployment_simplified.png)

## main_functions

In global namespace we initialize the pipeline's main objects starting with the DataProvider. Additionally, TensorFlow objects are declared.
Notably, the model and the tensor arena size, which defines the needed memory space for our model.

In the `loop` function we let the `error_reporter` point to the address of a `MicroErrorReporter` object.
We need to do that because `MicroErrorReporter` is developed for MCUs as a derived class of `ErrorReporter`.
This is necessary because `MicroErrorReporter` doesn't have access to all functions of `ErrorReporter`, unless we do the above pointer magic.

```c++
    static tflite::MicroErrorReporter micro_error_reporter;
    error_reporter = &micro_error_reporter;
```

Now we import our C array, containing the model information to TfLite micro.
This is done by calling the `GetModel` function and passing the `micro_model` array as an argument.

```c++
    model = tflite::GetModel(micro_model);
```

Then we create an object called `resolver` from `AllOpsResolver`.
This object contains all operations supported by TensorFlow Micro.
These operations are necessary to execute our model.
Loading all operations is a inefficent with regards to memory consumption.
There's a way to load only the necessary operations but we will keep it simple, here.
If you'd like to know which operations our model needs, have a look at the section about [limited TensorFlow and TfLite Micro compatibility](#limited-support-between-TensorFlow-and-TfLite-Micro) and the [model creation](../model_creation/README.md).
Then we pass the resolver together with our model pointer, the `tensor_arena` array, the value `TensorArenaSize`,and `error_reporter` to the interpreter in order to initialize it.

The interpreter is a TfLite object that has all information about our model; which operations need to be loaded and how much memory the model needs.
Also, the interpreter holds the input and output arrays we need to pass our data into. 
We set our variables `model_input` and `model_output` to those arrays for convenience.
As a side note, `model_input` expects a 1-dimensional representation of your input. 

```c++
    model_input = interpreter->input(0);
    model_output = interpreter->output(0);
```

To check if our model has the right shape we use the following set of conditions.

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

Below you find an example using data from an accelerometer.
A single movement is described by 128 time-steps and the 3 acceleration axes.

    - dim 0 -> TfLite expects data in batches; TensorFlow wraps the input into 1 batch 
    - dim 1 -> we wait for 128 values to be collected
    - dim 2 -> we do that for 3 axes
    - dim 3 -> every channel contains a scalar at a given time; a scalar has dimension 1
    - type  -> data type we used for our input during model creation

In order to know which dimensions you need to plug in, you should know how the model was developed.

The last thing we do in the setup function is to initialize the periphery by calling the `Init` function from `data_provider`.

Now we jump into the `loop` function.
This function is very short thanks to our architecture.
First we call `SetInputData` from our object `feature_provider`, passing as argument the `Read` function from our object `data_provider`.
After that we extract features from the data within `feature_provider` by calling the function `ExtractFeatures`.
Then we call the function `WriteDataToModel` with the `model_input` variable as argument.
Thats how our data goes in the interpreter.
The interpreter calls the function `Invoke`, which does all the magic for us; by knowing all parameters.
In other words, it does prediction.
Then, the interpreter writes the output of the `Invoke` function to our `model_output` variable.
We pass this variable as argument to our `prediction_interpreter` to interpret the result.
The result is passed to `prediction_handler` for further action; for example actuator control.

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

## Memory limitations

Static memory allocation is limited to less than 160 kB on ESP32 based MCUs such as the ESP-EYE v2.1, as documented [here](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/system/mem_alloc.html).
Before any model inference takes place we initialize memory in the `tensor_arena`.
TFLite Micro expects static memory allocation for `tensor_arena`.
The combination of ESP32 and TFLite is therefore not ideal for larger models, see [this issue](https://github.com/espressif/tflite-micro-esp-examples/issues/3).
Due to the limitations, the `kTensorArenaSize` should not exceed around $150 \cdot 1024$ bytes in the following code snippet.

    constexpr int kTensorArenaSize = 150 * 1024;
    alignas(16) uint8_t tensor_arena[kTensorArenaSize];

Working with image data we have $x$ and $y$ dimensions and 3 color channels. We also must consider the data type of each pixel.

$\text{required memory} = x \cdot y \cdot \text{channels} \cdot \text{bytes}_\text{dtype}$

For example take an image with 240 $\times$ 240 and `int32` pixels. An `int32` takes up 4 bytes of memory.

$\text{memory} = 240 \cdot 240 \cdot 3 \cdot 4 = 691200 \text{ bytes}$

Reducing the image size to 96 $\times$ 96 yields.

$\text{memory} = 96 \cdot 96 \cdot 3 \cdot 4 = 110592 \text{ bytes}$

We can also use `uint8` types to represent 0 to 255, which is the range of pixel intensities, with one byte.

$\text{memory} = 96 \cdot 96 \cdot 3 \cdot 1 = 27648 \text{ bytes}$

Ensure to pass the `tensorflow` task a memory amount somewhat larger than the size of `tensor_arena`.
For example we have $120 \cdot 1024$ for `tensorflow` and $115 \cdot 1024$ for `tensor_arena`.

    extern "C" void app_main() {
        xTaskCreate((TaskFunction_t)&tf_main, "tensorflow", 120 * 1024, NULL, 8, NULL);
        vTaskDelete(NULL);
    }

## Limited support between TensorFlow and TfLite Micro

Not all TensorFlow operations (layers) are supported by TfLite.
And not all TfLite operations (layers) are supported by TfLite Micro.
Find a list of supported TfLite Micro operations, [here](https://github.com/tensorflow/tflite-micro/blob/main/tensorflow/lite/micro/all_ops_resolver.cc).

The TensorFlow modules that are used in the model architecture must be imported from TfLite.
Manually inspect the source code.

Add the header.

    #include "tensorflow/lite/micro/micro_mutable_op_resolver.h"

Add the number of imports.

    static tflite::MicroMutableOpResolver<your number of imports> micro_op_resolver;

Add the imports. For example a dense layer is the built in operator fully connected.

    micro_op_resolver.AddBuiltin(
        tflite::BuiltinOperator_FULLY_CONNECTED,
        tflite::ops::micro::Register_FULLY_CONNECTED());

If this fails you may wish to import all modules.
Include a different resolver.

    #include "tensorflow/lite/micro/all_ops_resolver.h"

And declare it differently, too.    

    static tflite::ops::micro::AllOpsResolver resolver;

Note, not all layers in TF exist in TfLite Micro, therefore not all architectures will work.
Check the [source code](https://github.com/tensorflow/tflite-micro/blob/main/tensorflow/lite/micro/all_ops_resolver.cc) to see which layers are available.
It's still not as simple as that.
For example, dropout cannot be found in the layers but still works because it's just a weight manipulation within possibly existing layers.
