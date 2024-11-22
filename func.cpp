#include "func.h"
#include <cmath>

double TrigFunction::FuncA(int n, double x) {
    double result = 0; // результат обчислень ряду
    // обчислення ряду Маклорена для sin(x)
    for (int i = 0; i < n; i++) {
        // кожен елемент ряду, що додається до результату
        double term = (std::tgamma(2 * i + 1) / (pow(4, i) * pow(std::tgamma(i + 1), 2) * (2 * i + 1))) * pow(x, 2 * i + 1);
        result += term;
    }
    return result;
}



