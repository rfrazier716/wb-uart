cmake_minimum_required (VERSION 3.10)
project ("wb-uart")

# User Defined Variables
#-----------------------------------------------
# Uncomment below line to rebuild/make all verilator code, otherwise will not regenerate from verilog
SET(REBUILD_VERILATOR TRUE) 

# Uncomment to build Test files
SET(ENABLE_TESTS TRUE)


# Do Not Edit Below This Line
#-----------------------------------------------
# set to cpp 11 standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Define Necessary Verilator Core Files
set(VERILATOR_INCLUDE  "/usr/share/verilator/include")
set(VERILATED "${VERILATOR_INCLUDE}/verilated.cpp")
set(VERILATED_TRACE "${VERILATOR_INCLUDE}/verilated_vcd_c.cpp")
set(VL_OBJECT_DIR "${CMAKE_SOURCE_DIR}/verilator/obj_dir")

# Add the Verilator Include path to the include search directory
include_directories(
    "${VERILATOR_INCLUDE}"                      # verilator core files
    "${CMAKE_SOURCE_DIR}/verilator/obj_dir"     # generated verilator code
    "${CMAKE_SOURCE_DIR}/bench/cpp")            # include directory for testbench

## Generates the verilator object files needed to run simulations and tests
set(VL_UART_TX "${VL_OBJECT_DIR}/uart_tx/Vuart_tx__ALL.a")
set(VL_FIFO "${VL_OBJECT_DIR}/fifo/Vfifo__ALL.a")

# build the Verilator files
INCLUDE("cmake/verilator_build.cmake")


IF(${ENABLE_TESTS})
    enable_testing()
    INCLUDE("cmake/tests.cmake")
ENDIF()