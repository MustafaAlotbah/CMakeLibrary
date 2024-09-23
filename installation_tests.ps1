param(
    [string]$Version = "test"
)

# Define paths
$installTemp = ".\installation_tests_temp"
$catch2 = ".\dependencies\win_x86_64\Catch2\"
$testArtifact = ".\output\artifact\v$Version\win_x86_64\"
$libraryName = "my_library"

# Create temporary directory for installation tests
if (-not (Test-Path $testArtifact))
{
    Write-Error "Testing artifact could not be found! Did you run '.\release.ps1 -Version $Version'?"
    exit 1
}

# Prepare library for integratin build
function Invoke-LibraryBuild
{
    param(
        [string]$BuildMode,
        [string]$BuildSystem
    )

    $outputRelease = ".\output\$BuildMode\"

    if ($BuildSystem -eq "MinGW")
    {
        $GeneratorName = "MinGW Makefiles"
    }
    else
    {
        $GeneratorName = "Visual Studio 17 2022"
    }

    Write-Host "Testing Installation for $GeneratorName in $BuildMode mode." -ForegroundColor Blue

    # Create temporary directory for installation tests
    if (-not (Test-Path $installTemp))
    {
        mkdir $installTemp
    }

    # Copy necessary files and dependencies
    Copy-Item .\installation_tests\CMakeLists.txt  "$installTemp\CMakeLists.txt"
    Copy-Item -Recurse $catch2                     "$installTemp\dependencies\win_x86_64\Catch2"
    Copy-Item -Recurse $testArtifact               "$installTemp\dependencies\win_x86_64\$libraryName"
    Copy-Item -Recurse .\tests                     "$installTemp\tests"

    # Navigate to temp folder
    Set-Location $installTemp

    # Create build folder and run CMake
    mkdir build
    Set-Location build

    cmake .. -G "$GeneratorName" -DCMAKE_BUILD_TYPE="$BuildMode"
    if (-not $?)
    {
        Set-Location ../../../
        Remove-Item -Path $installTemp -Recurse -Force
        Write-Host "CMake configuration failed for $GeneratorName in $BuildMode mode." -ForegroundColor Red
        exit 1
    }

    cmake --build . --config $BuildMode
    if (-not $?)
    {
        Set-Location ../../../
        Remove-Item -Path $installTemp -Recurse -Force
        Write-Host "Build failed for $GeneratorName in $BuildMode mode." -ForegroundColor Red
        exit 1
    }

    # Copy the resulting binaries (adjust paths as needed)
    Copy-Item "..\dependencies\win_x86_64\$libraryName\$BuildSystem\$BuildMode\bin\*.*" ..\$outputRelease

    # Run the tests
    Set-Location .\tests\
    ctest --output-on-failure -C $BuildMode
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
