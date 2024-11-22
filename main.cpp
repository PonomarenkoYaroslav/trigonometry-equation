#include <iostream>
#include "func.h"

int main() {
    TrigFunction trigFunc;
    int n = 5;
    double x = 0.5;
    std::cout << "Результат функції: " << trigFunc.FuncA(n, x) << std::endl;
    return 0;
}
