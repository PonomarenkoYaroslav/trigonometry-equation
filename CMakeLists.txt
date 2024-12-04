cmake_minimum_required(VERSION 3.10)

# Назва проекту
project(HttpServer)

# Додаємо стандарти C++
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Додаємо вихідні файли
add_executable(http_server
    http_server.cpp
    func.cpp
)

# Додаємо шляхи до заголовкових файлів
include_directories(${CMAKE_SOURCE_DIR})

# Посилання на бібліотеки
target_link_libraries(http_server
    boost_system
    boost_thread
    pthread
)

