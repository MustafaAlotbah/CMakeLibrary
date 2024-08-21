# Define the my_library library target
add_library(my_library SHARED)

# Add sources to the my_library library target
target_sources(my_library PRIVATE
        source/my_library.cpp
        source/my_library_internal.cpp
        # Add more files as needed
)

# Pass the version to the source code via a preprocessor definition
target_compile_definitions(my_library PRIVATE MY_LIBRARY_VERSION="${PROJECT_VERSION}")
target_compile_definitions(my_library PRIVATE BUILDING_MY_LIBRARY="1")

# Specify the include directories for the target
target_include_directories(my_library
    PUBLIC
        # Use absolute path for building
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../include>

        # Use relative path for installation
        $<INSTALL_INTERFACE:include>
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/internal
)

# Find and link the required libraries below
#find_package(SOMELIBRARY_LIB NAMES somelibrary libsomelibrary)
#target_link_libraries(my_library PRIVATE ${SOMELIBRARY_LIB})
#
## Optionally, you can check if the library was found and provide a useful error message
#if (NOT SOMELIBRARY_LIB)
#    message(FATAL_ERROR "some library static library not found.")
#endif()


# Hide Internal functions
if (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(Logify PRIVATE -fvisibility=hidden)
endif ()
set_target_properties(my_library PROPERTIES CXX_VISIBILITY_PRESET hidden)
set_target_properties(my_library PROPERTIES VISIBILITY_INLINES_HIDDEN YES)

# Installation Rules
# Define the installation directories
install(TARGETS my_library
        EXPORT my_libraryTargets
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
        RUNTIME DESTINATION bin
        INCLUDES DESTINATION include
)


# Install the public headers
install(DIRECTORY ../include/ DESTINATION include)

# Install the package configuration files
install(EXPORT my_libraryTargets
        FILE my_libraryTargets.cmake
        NAMESPACE my_library::
        DESTINATION lib/cmake/my_library
)

# Create and install the package configuration files
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
        "${CMAKE_CURRENT_BINARY_DIR}/my_libraryConfigVersion.cmake"
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
        "../cmake/my_libraryConfig.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/my_libraryConfig.cmake"
        INSTALL_DESTINATION lib/cmake/my_library
)

install(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/my_libraryConfig.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/my_libraryConfigVersion.cmake"
        DESTINATION lib/cmake/my_library
)


# Set the package name and version
set(CPACK_PACKAGE_NAME "my_library")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_PACKAGE_CONTACT "Mustafa Alotbah <mustafa.alotbah@gmail.com>")

# CPACK_GENERATOR set by parent CMakeLists.txt
include(CPack)