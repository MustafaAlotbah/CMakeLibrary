#include <iostream>
#include <my_library/my_library.h>

// Use [[maybe_unused]] together with -Wextra
int main([[maybe_unused]] int argc, [[maybe_unused]] char* argv[]) {

	// Print the version (based on your library's API)
	std::cout << "Welcome to my_library v" << my_library::getVersion() << std::endl;

	return 0;
}