#include <catch2/catch.hpp>
#include <my_library/my_library.h>


TEST_CASE("my_library Version", "[getVersion]") {
	REQUIRE(my_library::getVersion() == "0.1.0");
}