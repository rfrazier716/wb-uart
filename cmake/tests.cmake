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
    "${TEST_SOURCE_DIR}/VirtualUart.cpp")

target_link_libraries(test_simulators catch_main)

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
    "${TEST_SOURCE_DIR}/testFifo.cpp"
    "${TEST_SOURCE_DIR}/testLinefeed.cpp"
    "${TEST_SOURCE_DIR}/testUART.cpp"
    "${TEST_SOURCE_DIR}/testUARTRx.cpp"
    "${TEST_SOURCE_DIR}/testUARTTx.cpp"
    ${VERILATED}
    ${VERILATED_TRACE}
)

# Add a dependency to the verilator generated libraries
add_dependencies(test_wb_uart vl_libs)

# Link to the Verilator Generated static libraries
target_link_libraries(test_wb_uart ${VL_LINEFEED}) 
target_link_libraries(test_wb_uart ${VL_UART_TX})
target_link_libraries(test_wb_uart ${VL_UART_RX})
target_link_libraries(test_wb_uart ${VL_FIFO})
target_link_libraries(test_wb_uart ${VL_EDGE_DETECT})
target_link_libraries(test_wb_uart ${VL_LINEFEED})
target_link_libraries(test_wb_uart ${VL_WB_UART})

# Other library links
target_link_libraries(test_wb_uart vl_catch_main) # Catch main function -- speeds up compiling
target_link_libraries(test_wb_uart tcp) # link the TCP library so the test bench works


######################################################
## Have Catch find and register tests based on tags
######################################################

set(TEST_TAGS "[fifo]"
    "[linefeed]"
    "[uart-tx]"
    "[uart-rx]"
    "[uart-top]"
    "[edge-detect]")

foreach(tag ${TEST_TAGS})
    catch_discover_tests(test_wb_uart
        TEST_SPEC "${tag}"
        TEST_PREFIX "${tag}-")
endforeach()