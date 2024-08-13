


# Example 1
file(GLOB Example_01_SRC "example_01.cpp")
add_executable(Example_01 ${Example_01_SRC})
target_link_libraries(Example_01 my_library)


