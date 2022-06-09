## Download and Update Dependencies

Navigate to your project's root folder.

    cd path/to/project

Make the component update script executable.

    chmod +x scripts/update_components.sh

Run the component update script.

    ./scripts/update_components.sh

## Adding Dependencies

If possible, add dependencies as git submodules.
This makes sense especially when dependencies are under active development such as TfLite Micro.

Consider the example of the MPU6050, a 6-axis accelerometer (gyroscope).
Add a repository containing the relevant component as submodule to `components`.
If the relevant component is buried inside the submodule repository add the submodule to `components/sources` instead. 

    git submodule add https://github.com/jrowberg/i2cdevlib components/sources/i2cdevlib

If necessary, modify `scripts/update_components.sh` to extract the components from the submodule repository.
The extracted component must have the form of a folder containing a `CMakeLists.txt` file and should live in `components`.

```bash
    # add the following code to update_components.sh
    rm -r components/MPU6050
    cp components/sources/i2cdevlib/ESP32_ESP-IDF/components/MPU6050 components/MPU6050
```

Run the component update script to extract the dependencies.

    ./scripts/update_components

Update `main/CMakeLists.txt` to include added dependencies.
Add your component within `idf_component_register()`, to the right hand side of `REQUIRES`.
Leave a space between existing components.

```bash
idf_component_register(SRCS ${SOURCES}
                        INCLUDE_DIRS . inc
                        REQUIRES existing_component MPU6050)
```