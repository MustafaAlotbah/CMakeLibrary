# Script initialization: Defines a parameter to specify the version of the release being tested
param(
    [string]$Version = "test"
)

# Define key directory paths required for the installation validation process
# $installTemp:  Temporary workspace for conducting installation testing
# $deps:         Directory containing build dependencies (target architecture is win_x86_64)
# $testArtifact: Output directory for compiled artifacts of the current version
# $libraryName:  The name of the library under test, used for directory structure consistency
$installTemp = ".\installation_tests_temp"
$deps = "\dependencies\win_x86_64\"
$testArtifact = ".\output\artifact\v$Version\win_x86_64\"
$libraryName = "my_library"

# Preliminary validation: Ensures the presence of the required build artifact for the specified version
if (-not (Test-Path $testArtifact))
{
    Write-Error "Testing artifact could not be found! Did you run '.\release.ps1 -Version $Version'?"
    exit 1
}

# Function to orchestrate the library integration build and validation process across different configurations
function Invoke-LibraryBuild
{
    param(
        [string]$BuildMode,   # Defines the build configuration (e.g., Debug/Release)
        [string]$BuildSystem  # Defines the build system to be used (e.g., MinGW, Visual Studio)
    )

    # Initial housekeeping:
    # Removes any pre-existing temporary installation directories to ensure a clean build environment
    if (Test-Path $installTemp)
    {
        Write-Host "Build directory exists. Emptying it to ensure a clean workspace..."
        Remove-Item -Recurse -Force $installTemp
    }

    # Create a temporary directory to host installation files
    mkdir $installTemp > $null

    # Build system abstraction: Set the appropriate CMake generator based on the selected build system
    if ($BuildSystem -eq "MinGW")
    {
        $GeneratorName = "MinGW Makefiles"
    }
    else
    {
        $GeneratorName = "Visual Studio 17 2022"
    }

    Write-Host "Testing Installation for $GeneratorName in $BuildMode mode." -ForegroundColor Blue

    # Copy necessary components for testing (CMakeLists, dependencies, test suites) to the temporary workspace
    Copy-Item .\installation_tests\CMakeLists.txt  "$installTemp\CMakeLists.txt"
    Copy-Item -Recurse .\$deps                     "$installTemp\$deps\"
    Copy-Item -Recurse $testArtifact               "$installTemp\$deps\$libraryName"
    Copy-Item -Recurse .\tests                     "$installTemp\tests"

    # Navigate to temp folder
    Set-Location $installTemp

    # Create build folder and run CMake
    mkdir build > $null
    Set-Location build

    # Generate build system files based on the specified generator and configuration
    cmake .. -G "$GeneratorName" -DCMAKE_BUILD_TYPE="$BuildMode"
    if (-not $?)
    {
        Set-Location ../../
        Remove-Item -Path $installTemp -Recurse -Force
        Write-Host "CMake configuration failed for $GeneratorName in $BuildMode mode." -ForegroundColor Red
        exit 1
    }

    # Compile the project using the generated build files
    cmake --build . --config "$BuildMode"
    if (-not $?)
    {
        Set-Location ../../
        Remove-Item -Path $installTemp -Recurse -Force
        Write-Host "Build failed for $GeneratorName in $BuildMode mode." -ForegroundColor Red
        exit 1
    }

    # Copy the binaries from the dependency folder structure into the release output directory
    # Assuming binaries are in the structure \PackageName\BuildSystem\BuildMode\bin\*
    Get-ChildItem -Directory "..\$deps" | ForEach-Object {
        $package = $_.Name
        $sourcePath = Join-Path "..\$deps\$package\$BuildSystem\$BuildMode\bin" "*.*"

        # Validate source path existence and copy binaries to the output folder
        if (Test-Path $sourcePath)
        {
            Copy-Item "..\$deps\$package\$BuildSystem\$BuildMode\bin\*.*" "..\output\$BuildMode\"
            if (-not $?)
            {
                Set-Location ../../
                Remove-Item -Path $installTemp -Recurse -Force
                Write-Host "Could not copy binaries" -ForegroundColor Red
                exit 1
            }
        }
    }

    # Navigate to the test suite directory and run the CTest test harness with output enabled for failures
    Set-Location .\tests\
    ctest --output-on-failure -C "$BuildMode"
    if (-not $?)
    {
        Set-Location ../../../
        Remove-Item -Path $installTemp -Recurse -Force
        Write-Host "Tests failed for $GeneratorName in $BuildMode mode." -ForegroundColor Red
        exit 1
    }

    # Return to the main directory
    Set-Location ../../../

    # Clean up the temporary installation tests folder
    Write-Host "Success for $GeneratorName in $BuildMode mode." -ForegroundColor Green
    Remove-Item -Path $installTemp -Recurse -Force
}


# Test with MinGW in Release mode
Invoke-LibraryBuild -BuildMode "Release" -BuildSystem "MinGW"

# Test with MinGW in Debug mode
Invoke-LibraryBuild -BuildMode "Debug"   -BuildSystem "MinGW"

# Test with Visual Studio 17 2022  in Debug mode
Invoke-LibraryBuild -BuildMode "Release" -BuildSystem "VisualStudio"

# Test with Visual Studio 17 2022  in Debug mode
Invoke-LibraryBuild -BuildMode "Debug"   -BuildSystem "VisualStudio"

Write-Host "All operations completed."
