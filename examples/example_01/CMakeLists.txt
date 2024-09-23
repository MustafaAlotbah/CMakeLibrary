
# Here define your example executable
add_executable(Example_01 "main.cpp")
target_link_libraries(Example_01 PRIVATE my_library::my_library)