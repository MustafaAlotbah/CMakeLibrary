#!/bin/bash

# Get the version argument
VERSION=${1:-"test"}

# Define paths
INSTALL_TEMP="./installation_tests_temp"
CATCH2="./dependencies/linux_x86_64/Catch2/"
TEST_ARTIFACT="./output/artifact/v$VERSION/linux_x86_64/"
LIBRARY_NAME="my_library"

# Check if the test artifact exists
if [ ! -d "$TEST_ARTIFACT" ]; then
  echo "Testing artifact could not be found! Did you run './release.sh $VERSION'?"
  exit 1
fi

# Function to build and test the library
Invoke_LibraryBuild() {
    local BuildMode=$1
    local BuildSystem=$2
    local GeneratorName

    OUTPUT_RELEASE="./output/$BuildMode/"

    if [ "$BuildSystem" == "GCC" ]; then
        GeneratorName="Unix Makefiles"
    else
        echo "Unsupported build system: $BuildSystem"
        exit 1
    fi

    echo "Testing Installation for $GeneratorName in $BuildMode mode."

    # Step 1: Create a temporary directory for installation tests
    if [ ! -d "$INSTALL_TEMP" ]; then
        mkdir -p "$INSTALL_TEMP"
    fi

    # Step 2: Copy necessary files and dependencies
    mkdir -p "$INSTALL_TEMP/dependencies/linux_x86_64/"
    cp ./installation_tests/CMakeLists.txt "$INSTALL_TEMP/CMakeLists.txt"
    cp -r "$CATCH2" "$INSTALL_TEMP/dependencies/linux_x86_64/Catch2"
    cp -r "$TEST_ARTIFACT" "$INSTALL_TEMP/dependencies/linux_x86_64/$LIBRARY_NAME"
    cp -r ./tests "$INSTALL_TEMP/tests"

    # Step 3: Navigate to the temporary folder
    cd "$INSTALL_TEMP" || exit

    # Step 4: Create build folder and run CMake
    mkdir -p build
    cd build || exit

    cmake .. -G "$GeneratorName" -DCMAKE_BUILD_TYPE="$BuildMode"
    if [ $? -ne 0 ]; then
        cd ../../..
        rm -rf "$INSTALL_TEMP"
        echo "CMake configuration failed for $GeneratorName in $BuildMode mode."
        exit 1
    fi

    cmake --build . --config "$build_mode"  
    if [ $? -ne 0 ]; then
        cd ../../..
        rm -rf "$INSTALL_TEMP"
        echo "Build failed for $GeneratorName in $BuildMode mode."
        exit 1
    fi

    # Step 5: Copy the resulting binaries (adjust paths as needed)
    cp "../dependencies/linux_x86_64/$LIBRARY_NAME/$BuildMode/bin/"* "$OUTPUT_RELEASE"

    # Step 6: Run the tests
    cd tests || exit
    ctest --output-on-failure
    if [ $? -ne 0 ]; then
        cd ../../../
        rm -rf "$INSTALL_TEMP"
        echo "Tests failed for $GeneratorName in $BuildMode mode."
        exit 1
    fi

    # Step 7: Return to the root directory and clean up
    cd ../../../ || exit
    echo "Success for $GeneratorName in $BuildMode mode."
    rm -rf "$INSTALL_TEMP"
}

# Test with GCC in Release mode
Invoke_LibraryBuild "Release" "GCC"

# Test with GCC in Debug mode
Invoke_LibraryBuild "Debug" "GCC"

echo "All operations completed."
