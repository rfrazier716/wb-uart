cmake_minimum_required (VERSION 3.10)
project ("wb-uart")

# Uncomment to build Test files
SET(ENABLE_TESTS TRUE)

# set to cpp 11 standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Define Necessary Verilator Core Files

# Find the Verilator Package and add necessary Definitions
find_package(verilator HINTS $ENV{VERILATOR_ROOT})
set(VERILATOR_INCLUDE  "/usr/share/verilator/include")
set(RTL "${CMAKE_SOURCE_DIR}/rtl")

# Add the Verilator Include path to the include search directory
include_directories(
    "${VERILATOR_INCLUDE}"                      # verilator core files
    "${CMAKE_SOURCE_DIR}/bench/cpp")            # include directory for testbench

# build examples
INCLUDE("cmake/examples.cmake")


IF(${ENABLE_TESTS})
    enable_testing()
    INCLUDE("cmake/tests.cmake")
ENDIF()