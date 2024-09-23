param (
    [string]$Version
)

if (-not $Version) {
    Write-Error "No version provided. Usage: .\release.ps1 -Version 0.1.0"
    exit 1
}

# Set the build directory
$BuildDir = "build"

function Invoke-LibraryBuild {
    param (
        [string]$BuildSystem,
        [string]$BuildMode
    )

    # Ensure the build directory exists or create it
    if (Test-Path $BuildDir) {
        Write-Host "Build directory exists. Emptying it..."
        Remove-Item -Recurse -Force $BuildDir
    }
    New-Item -ItemType Directory -Path $BuildDir

    Set-Location $BuildDir

    if ($BuildSystem -eq "MinGW") {
        Write-Host "Running CMake with MinGW Makefiles..."
        cmake .. -G "MinGW Makefiles"
        if (-not $?) {
            Set-Location ..
            Write-Host "CMake configuration failed for MinGW." -ForegroundColor Red
            exit 1
        }
    } elseif ($BuildSystem -eq "VisualStudio") {
        Write-Host "Running CMake with Visual Studio 17 2022..."
        cmake .. -G "Visual Studio 17 2022"
        if (-not $?) {
            Set-Location ..
            Write-Host "CMake configuration failed for Visual Studio." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Error "Invalid build system selected: $BuildSystem"
        exit 1
    }

    Write-Host "Building the project in $BuildMode mode..."
    cmake --build . --config $BuildMode
    if (-not $?) {
        Set-Location ..
        Write-Host "Build failed for $BuildSystem in $BuildMode mode." -ForegroundColor Red
        exit 1
    }

    # Construct the installation path
    $InstallDir = "../output/artifact/v$Version/win_x86_64/$BuildSystem/$BuildMode"
    Write-Host "Installing the project to $InstallDir..."
    cmake --install . --prefix $InstallDir --config $BuildMode
    if (-not $?) {
        Set-Location ..
        Write-Host "Installation failed for $BuildSystem in $BuildMode mode." -ForegroundColor Red
        exit 1
    }

    Write-Host "Build for $BuildSystem in $BuildMode mode completed."

    Set-Location ..
}

# Build with MinGW in Release mode
Invoke-LibraryBuild -BuildSystem "MinGW" -BuildMode "Release"

# Build with MinGW in Debug mode
Invoke-LibraryBuild -BuildSystem "MinGW" -BuildMode "Debug"

# Build with Visual Studio 17 2022 in Release mode
Invoke-LibraryBuild -BuildSystem "VisualStudio" -BuildMode "Release"

# Build with Visual Studio 17 2022 in Debug mode
Invoke-LibraryBuild -BuildSystem "VisualStudio" -BuildMode "Debug"

Write-Host "All operations completed."
