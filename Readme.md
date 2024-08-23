# CMake Library Template

This project provides a CMake-based template for creating, structuring, and publishing C++ libraries. 
It is designed to help developers create reusable, maintainable, and portable libraries that can be easily integrated into other projects.

## Features

- **CMake Integration**: Fully-configured CMake setup for building and installing the library.
- **Cross-Platform Support**: Supports multiple platforms with easy configuration for platform-specific dependencies.
- **Version Management**: Embed version information directly into the library.
- **Visibility Control**: Properly manage symbol visibility across different platforms.
- **Modular Structure**: Separate public API, private implementation, and tests for clear code organization.

## Usage

### 1. Cloning the Repository

   Clone this template repository to your local machine:

   ```bash
   git clone https://github.com/MustafaAlotbah/CMakeLibrary.git
   cd CMakeLibrary
   ```

### 2. Configuring Your Library

   Use the provided configure.py script to rename the project according to your library's name:

   ```bash
   python configure.py --library-name <new_library_name>
   ```

   This script will:

   - Rename files and directories.

   - Update content within files to reflect the new library name.

### 3. Building the Library

   Generate the build files with CMake and compile the library:

   ```bash
   mkdir build
   cd build
   cmake .. -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release
   cmake --build . --config Release
   ```

### 4. Installation

   To install the library and its headers to your system:

   ```bash
   cmake --install . --prefix .
   ```

### 6. Packaging

   You can create distribution packages using CPack:

   ```bash
   cpack
   ```

   This will generate platform-specific packages (e.g., .zip for Windows, .tar.gz for Linux).

## Customization

Currently, all warnings are treated as errors. 
This is to help you avoid making mistakes. 
However, you may change that by changing the root-level `CMakeLists.txt` as follows 

- For **GCC**: 
  - Remove `-Wextra` to reduce warning level, or
  - Remove `-Werror` to not treat warnings as errors.

- For **MSVC**: 
  - Replace `-W4` with `-W3` to reduce warning level, or 
  - Remove `/WX` to not treat warnings as errors.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request if you have any improvements or suggestions.

## License

This project is licensed under the BSD-3-Clause License. See the LICENSE file for more details.

## Contact

For any questions or support, please contact Mustafa Alotbah at [mustafa.alotbah@gmail.com](mailto:mustafa.alotbah@gmail.com).