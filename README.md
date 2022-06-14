**Table of Contents:**

1. [General information](#general-information)
1. [Repository structure](#repository-structure)
1. [ARCHITECTURE](#architecture)
1. [CONTRIBUTING](#contributing)
1. [LICENSE](#license)
1. [Contact](#contact)

# General information

This repository contains a template which you can use to develop your own TinyML projects with an ESP-Board of your choice and the ESP-IDF. 

The provided pipeline is based on the TinyML pipeline which you can find in Pete Warden’s and Daniel Situnayake’s TinyML book. Our pipeline consists of five steps. First, data collection requires connecting with hardware and reading data to your PC. Second, preprocessing involves reshaping data into a format suited for training a ML model. Third, design and training. Training is done using Google’s TensorFlow framework. Fourth, the model must be converted from TensorFlow to Tensorflow Lite and then to a C or C++ compatible format. Lastly, we deploy the model onto a microcontroller and run inference.

The architecture of this repository is designed to be simple and self explanatory. In the following sections we will show you what you can find in each folder. If you want a deeper look you can click on the title to get more information. We recommend to read all readme's in this repo.

# Architecture

[Here](ARCHITECTURE.md) you can find the architecture of our pipeline.

# Contributing

Pull requests are welcome.
We don't have a specific template for PRs.
Please follow style guides for Python and C++.
For Python style, we follow [PEP 8](https://peps.python.org/pep-0008/) and [PEP 257](https://peps.python.org/pep-0257/).
For C++ we follow the [Google style guide](https://google.github.io/styleguide/cppguide.html).

# License

# Contact

Feel free to contact us if you have any questions:

rafael.tappe.maestro@itemis.com<br>
nikolas.rieder@itemis.com
