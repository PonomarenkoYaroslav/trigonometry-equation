#include <boost/beast/core.hpp>
#include <boost/beast/http.hpp>
#include <boost/asio.hpp>
#include <vector>
#include <algorithm>
#include <chrono>
#include <string>
#include "func.h"
#include <iostream>

namespace beast = boost::beast; 
namespace http = beast::http; 
namespace net = boost::asio;    
using tcp = net::ip::tcp;       

// Обробка GET-запиту
void handle_request(const http::request<http::string_body>& req, http::response<http::string_body>& res) {
    if (req.method() != http::verb::get) {
        res.result(http::status::method_not_allowed);
        res.body() = "Only GET requests are allowed";
        return;
    }

    auto start_time = std::chrono::high_resolution_clock::now();
    
    // Генерація масиву значень
    TrigFunction trig;
    std::vector<double> values;
    for (int i = 0; i < 1000000; ++i) {
        values.push_back(trig.FuncA(10, i * 0.1));
    }


    // Сортування масиву

    std::sort(values.begin(), values.end());
    auto end_time = std::chrono::high_resolution_clock::now();

    // Час виконання
    auto elapsed_time = std::chrono::duration_cast<std::chrono::milliseconds>(end_time - start_time).count();

    // Відповідь
    res.result(http::status::ok);
    res.body() = "Elapsed time: " + std::to_string(elapsed_time) + " ms";
    res.prepare_payload();
}

// Основна функція
int main() {
    try {
        net::io_context ioc;
        tcp::acceptor acceptor(ioc, tcp::endpoint(tcp::v4(), 8080)); // Порт 8080

        while (true) {
            tcp::socket socket(ioc);
            acceptor.accept(socket);

            beast::flat_buffer buffer;
            http::request<http::string_body> req;
            http::read(socket, buffer, req);

            http::response<http::string_body> res;
            handle_request(req, res);

            http::write(socket, res);
        }
    } catch (std::exception const& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
}

