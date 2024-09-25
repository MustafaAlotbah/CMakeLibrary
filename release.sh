#!/bin/bash

# Get the version argument
VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Error: No version provided. Usage: ./release.sh <version>"
    exit 1
fi

# Set the build directory
BuildDir="build"
LIBRARY_NAME="my_library"

# Function to build the project
build_project() {
    local build_system=$1
    local build_mode=$2

    # Ensure the build directory exists or create it
    if [ -d "$BuildDir" ]; then
        echo "Build directory exists. Emptying it..."
        rm -rf "$BuildDir"
    fi
    mkdir -p "$BuildDir"

    cd "$BuildDir" || exit

    echo "Running CMake with Makefiles..."
    cmake .. -G "Unix Makefiles" -DCMAKE_BUILD_TYPE="$build_mode" || exit

    echo "Building the project in $build_mode mode..."
    cmake --build . --config "$build_mode"  || exit

    # Construct the installation path
    InstallDir="../output/artifact/v$VERSION/linux_x86_64/$LIBRARY_NAME/$build_system/$build_mode"
    echo "Installing the project to $InstallDir..."
    cmake --install . --prefix "$InstallDir" --config "$build_mode" || exit

    echo "Build for $build_system in $build_mode mode completed."

    cd ..
}

# Build with GCC in Release mode
build_project "GCC" "Release"

# Build with GCC in Debug mode
build_project "GCC" "Debug"

echo "All operations completed."
