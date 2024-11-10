#include "func.h"
#include <cmath>

double TrigFunction::FuncA(int n, double x) {
    double result = 0;
    double x = 0.5;
    double n = 2;
    for (int i = 0; i < n; i++) {
        double term = (factorial(2 * i) / (pow(4, i) * pow(factorial(i), 2) * (2 * i + 1))) * pow(x, 2 * i + 1);
        result += term;
    }
    return result;
}

double factorial(int num) {
    if (num == 0 || num == 1) return 1;
    double result = 1;
    for (int i = 2; i <= num; i++) {
        result *= i;
    }
    return result;
}