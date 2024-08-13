
#pragma once

#ifdef _WIN32
#ifdef BUILDING_MY_LIBRARY
#define MY_LIBRARY_API __declspec(dllexport)
#else
#define MY_LIBRARY_API __declspec(dllimport)
#endif
#else
#if defined(__GNUC__) && __GNUC__ >= 4
#define MY_LIBRARY_API __attribute__((visibility("default")))
#else
#define MY_LIBRARY_API
#endif
#endif