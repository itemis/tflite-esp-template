#pragma once

#include <vector>

class DataProvider{
    public:
        DataProvider() = default;
        ~DataProvider() = default;
        bool Init();
        std::vector<float> Read();
    private:
};



