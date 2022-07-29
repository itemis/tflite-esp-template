![template](https://github.com/itemis/tflite-esp-template/actions/workflows/cmake.yml/badge.svg)

**Table of Contents:**

1. [General information](#general-information)
1. [Requirements](#requirements)
1. [ARCHITECTURE](#architecture)
1. [CONTRIBUTING](#contributing)
1. [LICENSE](#license)
1. [Contact](#contact)

# General information

This repository contains a template which you can use to develop your own TinyML projects with an ESP-Board of your choice and the ESP-IDF. 

The provided template is based on the TinyML pipeline which you can find in Pete Warden’s and Daniel Situnayake’s TinyML book. Our pipeline consists of five steps. First, data collection requires connecting with hardware and reading data to your PC. Second, preprocessing involves reshaping data into a format suited for training a ML model. Third, design and training. Training is done using Google’s TensorFlow framework. Fourth, the model must be converted from TensorFlow to Tensorflow Lite and then to a C or C++ compatible format. Lastly, we deploy the model onto a microcontroller and run inference.

# Requirements

## Python, model creation

**Python**

Install Python. Version 3.10 is tested.

Install packages

    pip install -r requirements.txt

## Embedded C/C++, embedded model deployment

**Espressif IDF**

Version 1.4 is tested.
Install via VSCode > Extensions > ESP-IDF > Express installation with all defaults.
At the end of the installation a command is shown.
This command should be executed to grant complete permissions.

**Libraries**

Next, download dependencies for the embedded system.

    chmod +x scripts/update_components.sh
    ./scripts/update_components.sh

## Respect the pipeline requirements

1. Data must be present in order to start training.
2. Preprocessing may be necessary.
3. A model must be trained and stored.
4. The model must be converted to a C array and included in the embedded code.
5. You cannot run your project on an MCU before completing above steps.

# Running

## Python environment

Execute Jupyter files via GUI.

## Embedded environment

See [ESP documentation](https://docs.espressif.com/projects/esp-idf/en/v4.1/get-started/index.html) for an initial setup of the embedded environment.
Afterwards, feel free to use this shorthand.

    get_idf && idf.py build && idf.py -p /dev/ttyUSB0 flash monitor

# Architecture

The architecture of this repository is designed to be simple and self explanatory.
You can find a detailed description in the [ARCHITECTURE.md](ARCHITECTURE.md) file.

# Contributing

Pull requests are welcome.
We don't have a specific template for PRs.
Please follow style guides for Python and C++.
For Python style, we follow [PEP 8](https://peps.python.org/pep-0008/) and [PEP 257](https://peps.python.org/pep-0257/).
For C++ we follow the [Google style guide](https://google.github.io/styleguide/cppguide.html).

# License

Copyright (c) 2022 itemis AG<br>
All rights reserved.

This source code is licensed under the Apache-2.0 license found in the [license](LICENSE.md) file in the root directory of this source tree. 

# Contact

Feel free to contact us if you have any questions!

rafael.tappe.maestro@itemis.com<br>
nikolas.rieder@itemis.com
