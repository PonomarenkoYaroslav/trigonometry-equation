#include <gtest/gtest.h>
#include <chrono>
#include <vector>
#include <algorithm>
#include "func.h"

TEST(CalculationTimeTest, WithinRange) {
    TrigFunction trig;
    std::vector<double> values;
    auto start_time = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < 1000000; ++i) {
        values.push_back(trig.FuncA(10, i * 0.1));
    }

    
    std::sort(values.begin(), values.end()); // Сортування
    auto end_time = std::chrono::high_resolution_clock::now();

    // Обчислення часу у мілісекундах
    auto elapsed_time = std::chrono::duration_cast<std::chrono::milliseconds>(end_time - start_time).count();

    // Перевірка часу у мілісекундах
    EXPECT_GE(elapsed_time, 5000); // Мінімум 5000 мс (5 секунд)
    EXPECT_LE(elapsed_time, 20000); // Максимум 20000 мс (20 секунд)
}

