# Define All unittests here, for larger projects, tests can be split into separate CMAKE files

# Load the Catch2 Package, which is used for all unittests
find_package(Catch2 REQUIRED)
include(CTest)
include(Catch)

# Set the source directory for test files
set(TEST_SOURCE_DIR "${CMAKE_SOURCE_DIR}/bench/cpp/src")


# Build the Catch header main function into a library
add_library(vl_catch_main "bench/cpp/src/verilatorCatchMain.cpp")
add_library(catch_main "bench/cpp/src/catchMain.cpp")
add_library(tcp "${TEST_SOURCE_DIR}/tcp/TCPServer.cpp")

######################################################
## Tests related to virtual Classes etc
######################################################
add_executable(test_simulators
    "${TEST_SOURCE_DIR}/testVirtualUart.cpp"
    )

# Link it to the VLCatch Main library
target_link_libraries(test_simulators PUBLIC vl_catch_main)

# use the verilator uartTx and Rx modules for testing
verilate(test_simulators SOURCES "${RTL}/uart_tx.v"
    TRACE 
    INCLUDE_DIRS ${RTL}
    VERILATOR_ARGS "-GCYCLES_PER_BIT=8"
    )

verilate(test_simulators SOURCES "${RTL}/uart_rx.v"
    TRACE 
    INCLUDE_DIRS ${RTL}
    VERILATOR_ARGS "-GCYCLES_PER_BIT=8"
    )

set(TEST_TAGS "[uart-tb]")

foreach(tag ${TEST_TAGS})
    catch_discover_tests(test_simulators
        TEST_SPEC "${tag}"
        TEST_PREFIX "${tag}-")
endforeach()

######################################################
## All Verilog Related Tests
######################################################

# Create new Target
add_executable(test_wb_uart
    "${TEST_SOURCE_DIR}/testEdgeDetector.cpp"
    "${TEST_SOURCE_DIR}/testCharDetector.cpp"
    "${TEST_SOURCE_DIR}/testFifo.cpp"
    "${TEST_SOURCE_DIR}/testLinefeed.cpp"
    "${TEST_SOURCE_DIR}/testUART.cpp"
    "${TEST_SOURCE_DIR}/testUARTRx.cpp"
    "${TEST_SOURCE_DIR}/testUARTTx.cpp"
)

# Verilate the required top level modules and linke to executable
verilate(test_wb_uart SOURCES "${RTL}/linefeed_detector.v" TRACE INCLUDE_DIRS ${RTL})
verilate(test_wb_uart SOURCES "${RTL}/uart_tx.v" TRACE INCLUDE_DIRS ${RTL} VERILATOR_ARGS "-GCYCLES_PER_BIT=8")
verilate(test_wb_uart SOURCES "${RTL}/uart_rx.v" TRACE INCLUDE_DIRS ${RTL} VERILATOR_ARGS "-GCYCLES_PER_BIT=8")
verilate(test_wb_uart SOURCES "${RTL}/linefeed_detector.v" TRACE INCLUDE_DIRS ${RTL} VERILATOR_ARGS)
verilate(test_wb_uart SOURCES "${RTL}/char_detector.v" TRACE INCLUDE_DIRS ${RTL} VERILATOR_ARGS "-GSEARCH_KEY=8'h0D")
verilate(test_wb_uart SOURCES "${RTL}/fifo.v" TRACE INCLUDE_DIRS ${RTL} VERILATOR_ARGS "-GFIFO_DEPTH=3")
verilate(test_wb_uart SOURCES "${RTL}/edge_detector.v" TRACE INCLUDE_DIRS ${RTL})
verilate(test_wb_uart SOURCES "${RTL}/wb_uart.v" TRACE INCLUDE_DIRS ${RTL} VERILATOR_ARGS "-GCYCLES_PER_BIT=8")

# Other library links
target_link_libraries(test_wb_uart PUBLIC vl_catch_main) # Catch main function -- speeds up compiling
target_link_libraries(test_wb_uart PUBLIC tcp) # link the TCP library so the test bench works


# Have Catch find and register tests based on tags
set(TEST_TAGS "[fifo]"
    "[linefeed]"
    "[uart-tx]"
    "[uart-rx]"
    "[uart-top]"
    "[edge-detect]"
    "[char-detect]")

foreach(tag ${TEST_TAGS})
    catch_discover_tests(test_wb_uart
        TEST_SPEC "${tag}"
        TEST_PREFIX "${tag}-")
endforeach()

######################################################
## Tests for Example Modules
######################################################
# Create new Target
add_executable(test_example_cores
    "${TEST_SOURCE_DIR}/testEcho.cpp"
)

# generate verilator libraries
set(EXAMPLE_MODULE_DIR "${CMAKE_SOURCE_DIR}/bench/verilog")
verilate(test_example_cores SOURCES "${EXAMPLE_MODULE_DIR}/uart_echo.v" TRACE INCLUDE_DIRS ${RTL} VERILATOR_ARGS "-GCYCLES_PER_BIT=12")

target_link_libraries(test_example_cores PUBLIC vl_catch_main) # Catch main function -- speeds up compiling

# register tests with the "example" prefix
catch_discover_tests(test_example_cores
        TEST_SPEC "[examples]"
        TEST_PREFIX "[examples]-")