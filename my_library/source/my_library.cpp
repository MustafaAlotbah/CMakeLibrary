
#include "my_library/my_library.h"
#include "my_library_internal.h"

std::string my_library::getVersion() {
	return	internal::internalGetVersion();
}