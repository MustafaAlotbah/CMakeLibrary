
add_executable(my_libraryTests "main.cpp" "versionTests.cpp")
target_link_libraries(my_libraryTests PRIVATE my_library Catch2::Catch2)
