#include "func.h"
#include <cmath>
#include <climits>

// Клас TrigFunction обчислює наближення тригонометричних функцій
// за допомогою ряду, заданого кількістю елементів n та значенням x
class TrigFunction {
public:
    /**
     * Обчислює значення функції за допомогою ряду Маклорена для sin(x).
     * @param n - кількість елементів ряду для наближення
     * @param x - значення змінної, для якої обчислюється значення функції
     * @return - наближене значення функції
     */
    double FuncA(int n, double x);
};

/**
 * Обчислює факторіал для заданого числа.
 * @param num - число, для якого обчислюється факторіал
 * @return - значення факторіалу
 */
double factorial(int num) {
    if (num == 0 || num == 1) return 1;
    double result = 1;
    for (int i = 2; i <= num; i++) {
        result *= i;
    }
    return result;
}

double TrigFunction::FuncA(int n, double x) {
    double result = 0; // результат обчислень ряду
    // обчислення ряду Маклорена для sin(x)
    for (int i = 0; i < n; i++) {
        // кожен елемент ряду, що додається до результату
        double term = (factorial(2 * i) / (pow(4, i) * pow(factorial(i), 2) * (2 * i + 1))) * pow(x, 2 * i + 1);
        
        // додавання елементу до суми
        result += term;

        // Перевірка для запобігання надмірних обчислень:
        if (std::abs(term) < 1e-10) { // наприклад, використовуємо поріг 1e-10
            break;
        }
    }
    return result;
}
