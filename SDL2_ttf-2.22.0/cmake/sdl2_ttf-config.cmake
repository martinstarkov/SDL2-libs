# SDL2_ttf CMake configuration file:
# This file is meant to be placed in a cmake subfolder of SDL2_ttf-devel-2.x.y-VC

include(FeatureSummary)
set_package_properties(SDL2_ttf PROPERTIES
    URL "https://www.libsdl.org/projects/SDL_ttf/"
    DESCRIPTION "Support for TrueType (.ttf) font files with Simple Directmedia Layer"
)

cmake_minimum_required(VERSION 3.5)

set(SDL2_ttf_FOUND TRUE)

set(SDL2TTF_VENDORED TRUE)

set(SDL2TTF_HARFBUZZ TRUE)
set(SDL2TTF_FREETYPE TRUE)

if(CMAKE_SIZEOF_VOID_P STREQUAL "4")
    set(_sdl_arch_subdir "x86")
elseif(CMAKE_SIZEOF_VOID_P STREQUAL "8")
    set(_sdl_arch_subdir "x64")
else()
    unset(_sdl_arch_subdir)
    set(SDL2_ttf_FOUND FALSE)
    return()
endif()

set(_sdl2ttf_incdir       "${CMAKE_CURRENT_LIST_DIR}/../include")
set(_sdl2ttf_library      "${CMAKE_CURRENT_LIST_DIR}/../lib/${_sdl_arch_subdir}/SDL2_ttf.lib")
set(_sdl2ttf_dll          "${CMAKE_CURRENT_LIST_DIR}/../lib/${_sdl_arch_subdir}/SDL2_ttf.dll")

set(_sdl2ttf_extra_static_libraries " -lusp10 -lgdi32 -lrpcrt4  -lusp10 -lgdi32 -lrpcrt4 -lfreetype")
string(STRIP "${_sdl2ttf_extra_static_libraries}" _sdl2ttf_extra_static_libraries)

# Convert _sdl2ttf_extra_static_libraries to list and keep only libraries
string(REGEX MATCHALL "(-[lm]([-a-zA-Z0-9._]+))|(-Wl,[^ ]*framework[^ ]*)" _sdl2ttf_extra_static_libraries "${_sdl2ttf_extra_static_libraries}")
string(REGEX REPLACE "^-l" "" _sdl2ttf_extra_static_libraries "${_sdl2ttf_extra_static_libraries}")
string(REGEX REPLACE ";-l" ";" _sdl2ttf_extra_static_libraries "${_sdl2ttf_extra_static_libraries}")

# All targets are created, even when some might not be requested though COMPONENTS.
# This is done for compatibility with CMake generated SDL2_ttf-target.cmake files.

if(NOT TARGET SDL2_ttf::SDL2_ttf)
    add_library(SDL2_ttf::SDL2_ttf STATIC IMPORTED)
    set_target_properties(SDL2_ttf::SDL2_ttf
        PROPERTIES
        IMPORTED_LOCATION "${_sdl2ttf_library}"
        INTERFACE_INCLUDE_DIRECTORIES "${_sdl2ttf_incdir}"
        INTERFACE_LINK_LIBRARIES "${_sdl2ttf_extra_static_libraries}"
    )
endif()

unset(_sdl2ttf_extra_static_libraries)
unset(_sdl_arch_subdir)
unset(_sdl2ttf_incdir)
unset(_sdl2ttf_library)
unset(_sdl2ttf_dll)
