"""
CMake Library Template Renaming Script.

This script automates the renaming of a CMake-based C++ library project. It handles renaming of
the library, updating file contents to reflect the new library name, and renaming directories
and files accordingly.

This script is intended to be used when you need to rename an existing CMake library template to
fit a new project name and library name.

Author: Mustafa Alotbah
Contact: mustafa.alotbah@gmail.com
"""

import os
import argparse


def parse_arguments():
    """
    Parse command-line arguments to retrieve the new library and project names.

    Returns:
        argparse.Namespace: Parsed arguments containing 'library-name' and 'project-name'.
    """
    parser = argparse.ArgumentParser(description="Rename project and update contents.")
    parser.add_argument('--library-name', required=True, help="The new library name")
    return parser.parse_args()


def replace_and_rename(file_path, replacements, new_file_name=None):
    """
    Replace content within a file and optionally rename the file.

    Args:
        file_path (str): The path to the file that needs to be modified.
        replacements (dict): A dictionary of text replacements where keys are the old text and
                             values are the new text.
        new_file_name (str, optional): The new name for the file. If None, the file is not renamed.

    Returns:
        bool: True if the file was successfully modified and renamed (if applicable), False otherwise.
    """
    if not os.path.exists(file_path):
        print(f"File {file_path} not found.")
        return False

    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()

    for old, new in replacements.items():
        content = content.replace(old, new)

    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(content)

    if new_file_name:
        new_file_path = os.path.join(os.path.dirname(file_path), new_file_name)
        os.rename(file_path, new_file_path)
        print(f"Modified and renamed file to {new_file_path}")
    else:
        print(f"Modified {file_path}")

    return True


def rename_directory(old_dir_path, new_dir_path):
    """
    Rename a directory in the project structure.

    Args:
        old_dir_path (str): The current path of the directory to be renamed.
        new_dir_path (str): The new path (name) for the directory.

    Returns:
        bool: True if the directory was successfully renamed, False otherwise.
    """
    if not os.path.exists(old_dir_path):
        print(f"Directory {old_dir_path} not found.")
        return False

    if os.path.exists(new_dir_path):
        print(f"Directory {new_dir_path} already exists.")
        return False

    os.rename(old_dir_path, new_dir_path)
    print(f"Renamed directory {old_dir_path} to {new_dir_path}")
    return True


def modify_file(base_path, file_subpath, replacements, new_file_name=None):
    """
    Modify a file based on the given replacements and optionally rename the file.

    Args:
        base_path (str): The base directory path of the project.
        file_subpath (str): The relative path to the file within the project directory structure.
        replacements (dict): A dictionary of text replacements to be made in the file.
        new_file_name (str, optional): The new name for the file, if it needs to be renamed.

    Returns:
        bool: True if the file was successfully modified and renamed (if applicable), False otherwise.
    """
    file_path = os.path.join(base_path, file_subpath)
    return replace_and_rename(file_path, replacements, new_file_name)


def rename_project(base_path, library_name):
    """
    Perform the renaming of the CMake library project by updating all relevant files and directories.

    This function handles the modification of CMake configuration files, header files, source files,
    and their respective directories to reflect the new library name.

    Args:
        base_path (str): The base path of the project.
        library_name (str): The new name for the library.
    """

    # Modify and rename files

    modify_file(base_path, 'CMakeLists.txt', {
        'project(lib_my_library': f'project(lib_{library_name}',
        'add_subdirectory(my_library)': f'add_subdirectory({library_name})'
    })

    modify_file(base_path, 'cmake/my_libraryConfig.cmake.in', {
        '@PACKAGE_INIT@': '@PACKAGE_INIT@',
        'my_libraryTargets.cmake': f'{library_name}Targets.cmake'
    }, f'{library_name}Config.cmake.in')

    # Public Headers

    modify_file(base_path, 'include/my_library/my_library_export.h', {
        'MY_LIBRARY': library_name.upper()
    }, f'{library_name}_export.h')

    modify_file(base_path, 'include/my_library/my_library.h', {
        'MY_LIBRARY': library_name.upper(),
        'my_library_export.h': f'{library_name}_export.h',
        'namespace my_library': f'namespace {library_name}'
    }, f'{library_name}.h')

    rename_directory(
        os.path.join(base_path, 'include', 'my_library'),
        os.path.join(base_path, 'include', library_name)
    )

    # Library

    modify_file(base_path, 'my_library/CMakeLists.txt', {
        'my_library': library_name,
        'MY_LIBRARY': library_name.upper(),
        'MY_LIBRARY_EXPORTS': f'{library_name.upper()}_EXPORTS'
    })

    # Private Headers

    modify_file(base_path, 'my_library/internal/my_library_internal.h', {
        'namespace my_library::': f'namespace {library_name}::'
    }, f'{library_name}_internal.h')

    # Library Source Files

    modify_file(base_path, 'my_library/source/my_library_internal.cpp', {
        'my_library_internal.h': f'{library_name}_internal.h',
        'MY_LIBRARY_VERSION': f'{library_name.upper()}_VERSION',
        'my_library::internal::': f'{library_name}::internal::'
    }, f'{library_name}_internal.cpp')

    modify_file(base_path, 'my_library/source/my_library.cpp', {
        'my_library/my_library.h': f'{library_name}/{library_name}.h',
        'my_library_internal.h': f'{library_name}_internal.h',
        'my_library::': f'{library_name}::'
    }, f'{library_name}.cpp')

    rename_directory(
        os.path.join(base_path, 'my_library'),
        os.path.join(base_path, library_name)
    )

    # Tests

    modify_file(base_path, 'tests/CMakeLists.txt', {
        'my_libraryTests': f"{library_name}Tests"
    })

    modify_file(base_path, 'tests/my_libraryTests/CMakeLists.txt', {
        'my_library': library_name
    })

    modify_file(base_path, 'tests/my_libraryTests/versionTests.cpp', {
        'my_library/my_library.h': f'{library_name}/{library_name}.h',
        '\"my_library Version\"': f'\"{library_name} Version\"',
        'my_library::': f'{library_name}::'
    })

    rename_directory(
        os.path.join(base_path, 'tests', 'my_libraryTests'),
        os.path.join(base_path, 'tests', f"{library_name}Tests")
    )

    # Examples

    modify_file(base_path, 'examples/example_01/CMakeLists.txt', {
        'my_library': library_name
    })

    modify_file(base_path, 'examples/example_01/main.cpp', {
        'my_library': library_name
    })


def main():
    """
    Main entry point for the script.

    This function parses command-line arguments to get the new library and project names,
    and then triggers the renaming process.
    """
    args = parse_arguments()

    base_path = os.getcwd()

    rename_project(base_path, args.library_name)


if __name__ == '__main__':
    main()
