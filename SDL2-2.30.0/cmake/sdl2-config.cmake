# SDL2 CMake configuration file:
# This file is meant to be placed in a cmake subfolder of SDL2-devel-2.x.y-VC

cmake_minimum_required(VERSION 3.0...3.5)

include(FeatureSummary)
set_package_properties(SDL2 PROPERTIES
    URL "https://www.libsdl.org/"
    DESCRIPTION "low level access to audio, keyboard, mouse, joystick, and graphics hardware"
)

# Copied from `configure_package_config_file`
macro(set_and_check _var _file)
    set(${_var} "${_file}")
    if(NOT EXISTS "${_file}")
        message(FATAL_ERROR "File or directory ${_file} referenced by variable ${_var} does not exist !")
    endif()
endmacro()

# Copied from `configure_package_config_file`
macro(check_required_components _NAME)
    foreach(comp ${${_NAME}_FIND_COMPONENTS})
        if(NOT ${_NAME}_${comp}_FOUND)
            if(${_NAME}_FIND_REQUIRED_${comp})
                set(${_NAME}_FOUND FALSE)
            endif()
        endif()
    endforeach()
endmacro()

set(SDL2_FOUND TRUE)

if(CMAKE_SIZEOF_VOID_P STREQUAL "4")
    set(_sdl_arch_subdir "x86")
elseif(CMAKE_SIZEOF_VOID_P STREQUAL "8")
    set(_sdl_arch_subdir "x64")
else()
    set(SDL2_FOUND FALSE)
    return()
endif()

# For compatibility with autotools sdl2-config.cmake, provide SDL2_* variables.

set_and_check(SDL2_PREFIX       "${CMAKE_CURRENT_LIST_DIR}/..")
set_and_check(SDL2_EXEC_PREFIX  "${CMAKE_CURRENT_LIST_DIR}/..")
set_and_check(SDL2_INCLUDE_DIR  "${SDL2_PREFIX}/include")
set(SDL2_INCLUDE_DIRS           "${SDL2_INCLUDE_DIR}")
set_and_check(SDL2_BINDIR       "${SDL2_PREFIX}/lib/${_sdl_arch_subdir}")
set_and_check(SDL2_LIBDIR       "${SDL2_PREFIX}/lib/${_sdl_arch_subdir}")

set(SDL2_LIBRARIES      SDL2::SDL2main SDL2::SDL2-static)
set(SDL2MAIN_LIBRARY    SDL2::SDL2main)
set(SDL2TEST_LIBRARY    SDL2::SDL2test)

# All targets are created, even when some might not be requested though COMPONENTS.
# This is done for compatibility with CMake generated SDL2-target.cmake files.

set(_sdl2_static_private_libs_in " -Wl,--dynamicbase -Wl,--nxcompat -Wl,--high-entropy-va -ldinput8 -ldxguid -luser32 -lgdi32 -lwinmm -limm32 -lole32 -loleaut32 -lshell32 -lsetupapi -lversion -luuid")

# Convert _sdl2_static_private_libs to list and keep only libraries + library directories
string(REGEX MATCHALL "(-[lm]([-a-zA-Z0-9._]+))|(-Wl,[^ ]*framework[^ ]*)|(-pthread)" _sdl2_static_private_libs "${_sdl2_static_private_libs_in}")
string(REGEX REPLACE "^-l" "" _sdl2_static_private_libs "${_sdl2_static_private_libs}")
string(REGEX REPLACE ";-l" ";" _sdl2_static_private_libs "${_sdl2_static_private_libs}")
string(REGEX MATCHALL "-L([-a-zA-Z0-9._/]+)" _sdl2_static_private_libdirs "${_sdl2_static_private_libs_in}")
string(REGEX REPLACE "^-L" "" _sdl2_static_private_libdirs "${_sdl2_static_private_libdirs}")
string(REGEX REPLACE ";-L" ";" _sdl2_static_private_libdirs "${_sdl2_static_private_libdirs}")

set(_sdl2_link_libraries ${_sdl2_libraries})

set(_sdl2_library "${SDL2_LIBDIR}/SDL2.lib")
if(EXISTS "${_sdl2_library}")
  if(NOT TARGET SDL2::SDL2-static)
    add_library(SDL2::SDL2-static STATIC IMPORTED)
    set_target_properties(SDL2::SDL2-static
      PROPERTIES
      IMPORTED_LOCATION "${_sdl2_library}"
      INTERFACE_INCLUDE_DIRECTORIES "${SDL2_INCLUDE_DIRS}"
      INTERFACE_LINK_LIBRARIES "${_sdl2_static_private_libs}"
      INTERFACE_LINK_DIRECTORIES "${_sdl2_static_private_libdirs}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C"
      COMPATIBLE_INTERFACE_STRING "SDL_VERSION"
      INTERFACE_SDL_VERSION "SDL2"
    )
  endif()
  set(SDL2_SDL2_FOUND TRUE)
else()
  set(SDL2_SDL2_FOUND FALSE)
endif()
unset(_sdl2_library)

set(_sdl2main_library "${SDL2_LIBDIR}/SDL2main.lib")
if(EXISTS "${_sdl2main_library}")
    if(NOT TARGET SDL2::SDL2main)
        add_library(SDL2::SDL2main STATIC IMPORTED)
        set_target_properties(SDL2::SDL2main
        PROPERTIES
            IMPORTED_LOCATION "${_sdl2main_library}"
            COMPATIBLE_INTERFACE_STRING "SDL_VERSION"
            INTERFACE_SDL_VERSION "SDL2"
        )
    endif()
    set(SDL2_SDL2main_FOUND TRUE)
else()
    set(SDL2_SDL2_FOUND FALSE)
endif()
unset(_sdl2main_library)

set(_sdl2test_library "${SDL2_LIBDIR}/SDL2test.lib")
if(EXISTS "${_sdl2test_library}")
    if(NOT TARGET SDL2::SDL2test)
        add_library(SDL2::SDL2test STATIC IMPORTED)
        set_target_properties(SDL2::SDL2test
            PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES "${SDL2_INCLUDE_DIRS}"
                IMPORTED_LOCATION "${_sdl2test_library}"
                COMPATIBLE_INTERFACE_STRING "SDL_VERSION"
                INTERFACE_SDL_VERSION "SDL2"
        )
    endif()
    set(SDL2_SDL2test_FOUND TRUE)
else()
    set(SDL2_SDL2_FOUND FALSE)
endif()
unset(_sdl2test_library)

check_required_components(SDL2)
