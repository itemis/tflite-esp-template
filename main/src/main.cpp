#include "esp_log.h"
#include "esp_system.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "main_functions.h"

void tf_main(int argc, char* argv[]) {
  setup();
  while (true) {
    loop();
  }
}

extern "C" void app_main() {
  xTaskCreate((TaskFunction_t)&tf_main, "tensorflow", 10 * 1024, NULL, 8, NULL);
  vTaskDelete(NULL);
}