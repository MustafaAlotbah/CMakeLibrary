
add_executable(my_libraryTests "main.cpp" "versionTests.cpp")
target_link_libraries(my_libraryTests PRIVATE my_library::my_library Catch2::Catch2)

add_test(NAME my_libraryTests COMMAND my_libraryTests)