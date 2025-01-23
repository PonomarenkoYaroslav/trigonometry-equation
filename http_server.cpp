#include <boost/beast/core.hpp>
#include <boost/beast/http.hpp>
#include <boost/asio.hpp>
#include <boost/asio/signal_set.hpp>
#include <vector>
#include <algorithm>
#include <chrono>
#include <string>
#include <iostream>
#include "func.h"

namespace beast = boost::beast; 
namespace http = beast::http; 
namespace net = boost::asio;    
using tcp = net::ip::tcp;       

bool shutdown_requested = false; // Global flag to signal shutdown

// Function to handle GET requests
void handle_request(const http::request<http::string_body>& req, http::response<http::string_body>& res) {
    if (req.method() != http::verb::get) {
        res.result(http::status::method_not_allowed);
        res.body() = "Only GET requests are allowed";
        return;
    }
    auto start_time = std::chrono::high_resolution_clock::now();

    // Generate and process data
    TrigFunction trig;
    std::vector<double> values;
    for (int i = 0; i < 1000000; ++i) {
        values.push_back(trig.FuncA(10, i * 0.1));
    }
    std::sort(values.begin(), values.end());

    auto end_time = std::chrono::high_resolution_clock::now();

    // Calculate elapsed time
    auto elapsed_time = std::chrono::duration_cast<std::chrono::milliseconds>(end_time - start_time).count();

    // Respond with elapsed time
    res.result(http::status::ok);
    res.body() = "Elapsed time: " + std::to_string(elapsed_time) + " ms";
    res.prepare_payload();
}

// Main server function
void run_server(net::io_context& ioc, tcp::endpoint endpoint) {
    tcp::acceptor acceptor(ioc, endpoint);

    while (!shutdown_requested) {
        try {
            tcp::socket socket(ioc);
            acceptor.accept(socket);

            beast::flat_buffer buffer;
            http::request<http::string_body> req;
            http::read(socket, buffer, req);

            http::response<http::string_body> res;
            handle_request(req, res);

            http::write(socket, res);
        } catch (std::exception const& e) {
            std::cerr << "Error: " << e.what() << std::endl;
        }
    }

    std::cout << "Server shutting down gracefully..." << std::endl;
}

// Signal handler for graceful shutdown
void setup_signal_handling(net::io_context& ioc) {
    auto signals = std::make_shared<net::signal_set>(ioc, SIGINT, SIGTERM);

    signals->async_wait([&ioc, signals](boost::system::error_code const& error, int signal_number) {
        if (!error) {
            std::cout << "Received signal " << signal_number << ", initiating shutdown..." << std::endl;
            shutdown_requested = true;
            ioc.stop(); // Stop the io_context loop to clean up
        }
    });
}

int main() {
    try {
        net::io_context ioc;

        // Setup signal handling for SIGINT and SIGTERM
        setup_signal_handling(ioc);

        // Run the server
        tcp::endpoint endpoint(tcp::v4(), 8080); // Port 8080
        std::thread server_thread([&]() { run_server(ioc, endpoint); });

        ioc.run(); // Run the io_context

        server_thread.join(); // Wait for the server thread to finish
    } catch (std::exception const& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}

