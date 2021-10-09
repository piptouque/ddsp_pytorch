# - Find the MKL-DNN library
#
# Based on FindFFTW.cmake:
#   Copyright (c) 2015, Wenzel Jakob
#   https://github.com/wjakob/layerlab/blob/master/cmake/FindFFTW.cmake, commit 4d58bfdc28891b4f9373dfe46239dda5a0b561c6
#   Copyright (c) 2017, Patrick Bos
#   https://github.com/egpbos/findFFTW/blob/master/FindFFTW.cmake
#
# Usage:
#   find_package(MKLDNN [REQUIRED] [QUIET])
#
# It sets the following variables:
#   MKLDNN_FOUND                  ... true if mkl-dnn is found on the system
#   MKLDNN_INCLUDE_DIR            ... mkl-dnn schemas directory paths (ttf validation templates)
#   MKLDNN_LIBRARY              ... 
#
# The following variables will be checked by the function
#   MKLDNN_USE_STATIC_LIBS        ... if true, only static libraries are found, otherwise both static and shared.
#   MKLDNN_ROOT                   ... if set, the libraries are exclusively searched
#                                   under this path
#
include(Utils)

if (NOT MKLDNN_ROOT AND DEFINED ENV{MKLDNNDIR})
    set(MKLDNN_ROOT $ENV{MKLDNNDIR})
endif ()

# Check if we can use PkgConfig
find_package(PkgConfig)

#Determine from PKG
if (PKG_CONFIG_FOUND AND NOT MKLDNN_ROOT)
    pkg_check_modules(PKG_MKLDNN QUIET "MKLDNN")
endif ()

#Check whether to search static or dynamic libs
set(CMAKE_FIND_LIBRARY_SUFFIXES_SAV ${CMAKE_FIND_LIBRARY_SUFFIXES})

if (${MKLDNN_USE_STATIC_LIBS})
    set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_STATIC_LIBRARY_SUFFIX})
else ()
    set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES_SAV})
endif ()

if (MKLDNN_ROOT)
    #find includes
    find_path(MKLDNN_INCLUDE_DIR
            NAMES "mkl-dnn" "mkldnn"
            PATHS ${MKLDNN_ROOT}
            PATH_SUFFIXES "include"
            NO_DEFAULT_PATH
            )
    find_library(
            MKLDNN_LIB
            NAMES "mkl-dnn" "mkldnn"
            PATHS ${MKLDNN_ROOT}
            PATH_SUFFIXES "lib" "lib64"
            NO_DEFAULT_PATH
    )

else ()
    find_path(MKLDNN_INCLUDE_DIR
            NAMES "mkl-dnn"
            PATHS ${PKG_MKLDNN_INCLUDE_DIR} ${INCLUDE_INSTALL_DIR}
            PATH_SUFFIXES "include"
            )
    find_library(
            MKLDNN_LIB
            NAMES "mkl-dnn" "mkldnn"
            PATHS ${MKLDNN_ROOT}
            PATH_SUFFIXES "lib" "lib64"
            "lib/x86_64-linux-gnu"
    )
endif (MKLDNN_ROOT)

message(STATUS ${MKLDNN_LIBRARY})
message(STATUS ${MKLDNN_INCLUDE_DIR})

add_library(MKLDNN INTERFACE IMPORTED)
set_target_properties(MKLDNN
        PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${MKLDNN_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "${MKLDNN_LIBRARY}"
        )

set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES_SAV})

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(MKLDNN
        REQUIRED_VARS MKLDNN_INCLUDE_DIR
        HANDLE_COMPONENTS
        )

mark_as_advanced(
        MKLDNN_LIBRARY
        MKLDNN_INCLUDE_DIR
)
