cmake_minimum_required(VERSION 3.20)
project(lib_my_library VERSION 0.1.0)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)


# Check the compiler and set compiler flags accordingly
if (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    message(STATUS "Configuring for GCC/Clang")

    if(WIN32)
        set(BuildPipeline "MinGW")
    elseif (UNIX AND NOT APPLE)
        set(BuildPipeline "GCC")
    endif()

    # Set compiler flags for GCC/Clang
    if (CMAKE_BUILD_TYPE MATCHES Debug)
        message(STATUS "Configuring for a Debug build")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wpedantic -Werror -Wextra -Wall -g3 -Og")
        add_definitions(-DDEBUG_MODE)
    else ()
        message(STATUS "Configuring for a Release build")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wpedantic -Werror -Wextra -Wall -g0 -O3")
    endif ()

elseif (CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    message(STATUS "Configuring for MSVC")
    set(BuildPipeline "VisualStudio")

    # Enable Hot Reload for MSVC compilers if supported.
    if (POLICY CMP0141)
        message(STATUS "Configuring Hot Reload for MSVC")
        cmake_policy(SET CMP0141 NEW)
        set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,RelWithDebInfo>:EditAndContinue>,$<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>>")
    endif()

    # Set compiler flags for MSVC
    if (CMAKE_BUILD_TYPE MATCHES Debug)
        message(STATUS "Configuring for a Debug build")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4 /WX /Zi /Od /DDEBUG_MODE")
        add_definitions(-DDEBUG_MODE)
    else ()
        message(STATUS "Configuring for a Release build")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4 /WX /Ox /DNDEBUG")
    endif ()

else ()
    message(WARNING "Unknown compiler, using default settings")
endif()

# Enable compile command to accelerate indexing for some IDEs (Visual Studio, CLion)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Define the platform-specific paths and packaging configurations.
# This ensures that the correct dependencies are used depending on the platform.
if(WIN32)

    # Set the dependency folder for Windows x64.
    set(DEPENDENCY_FOLDER "${CMAKE_SOURCE_DIR}/dependencies/win_x86_64/")

    # Use ZIP as the packaging format for Windows.
    set(CPACK_GENERATOR "ZIP")


elseif (UNIX AND NOT APPLE)
    # Set the dependency folder for Linux x64.
    set(DEPENDENCY_FOLDER "${CMAKE_SOURCE_DIR}/dependencies/linux_x86_64/")

    # Use TGZ (tarball gzip) as the packaging format for Linux.
    set(CPACK_GENERATOR "TGZ")

else()

    # Fatal error if the platform is unsupported.
    message(FATAL_ERROR "Unsupported Platform: ${CMAKE_SYSTEM_NAME}")

endif()

# Set the CMake prefix path to include platform-specific dependency directories.
# This helps CMake locate the required libraries and packages.
set(CMAKE_PREFIX_PATH
        "${DEPENDENCY_FOLDER}/pkgconfig/"
        "${DEPENDENCY_FOLDER}/Catch2/"
)


# Find required packages
find_package(PkgConfig REQUIRED)

# Set output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/output/${BuildPipeline}/$<CONFIG>/")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/output/${BuildPipeline}/$<CONFIG>/")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/output/${BuildPipeline}/$<CONFIG>/lib/")

# Include subdirectories for building
add_subdirectory(my_library)
add_subdirectory(tests)
add_subdirectory(examples)