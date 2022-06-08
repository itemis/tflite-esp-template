**Table of Contents:**

1. [General information](#general-information)
1. [Repository structure](#repository-structure)
1. [ARCHITECTURE](#architecture)
1. [CONTRIBUTING](#contributing)
1. [LICENSE](#license)
1. [Contact](#contact)

# General information

This repository contains a template which you can use to develop your own TinyML projects with an ESP-Board of your choice and the ESP-IDF. 

The provided pipeline is based on the TinyML pipeline which you can find in Pete Warden’s and Daniel Situnayake’s TinyML book.
Our pipeline consists of five steps.
First, data collection requires connecting to hardware and reading data to your PC.
Second, preprocessing involves reshaping data into a format suitable for training a ML model.
Third, model design and training.
Training is done using Google’s TensorFlow framework. Fourth, the model must be converted from TensorFlow to Tensorflow Lite and then to a C or C++ compatible format. Lastly, we deploy the model onto a microcontroller to compute predictions.

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
