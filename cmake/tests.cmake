# Define All unittests here, for larger projects, tests can be split into separate CMAKE files

set(TEST_DIR "${CMAKE_CURRENT_LIST_DIR}/unittests")
message("Building UnitTests in ${TEST_DIR}")

######################################################
## Build the Catch header main function into a library
######################################################
# this is for speed increase with compiling
add_library(catch_main "bench/cpp/src/verilatorCatchMain.cpp")

######################################################
## Testing the Linefeed Detector Block
######################################################

# Create new Target
add_executable(test_linefeed
    "bench/cpp/src/testLinefeed.cpp"
    ${VERILATED}
    ${VERILATED_TRACE}
)

# Add a dependency to the verilator generated libraries
add_dependencies(test_linefeed vl_libs)

# Link to the Verilator Generated static library
target_link_libraries(test_linefeed ${VL_LINEFEED}) 
target_link_libraries(test_linefeed catch_main)

######################################################
## Testing that the Edge Detector Block is Functional
######################################################

# Create new Target
add_executable(testEdgeDetector
    "bench/cpp/src/testEdgeDetector.cpp"
    ${VERILATED}
    ${VERILATED_TRACE}
)

# Add a dependency to the verilator generated libraries
add_dependencies(testEdgeDetector vl_libs)

# Link to the Verilator Generated static library
target_link_libraries(testEdgeDetector ${VL_EDGE_DETECT}) 
target_link_libraries(testEdgeDetector catch_main)

# Register a test to this target
add_test(EDGE_DETECT_FUNCTIONAL testEdgeDetector)

######################################################
## Testing that the UART Transmit Block is Functional
######################################################

# Create new Target
add_executable(test_UARTTx
    "bench/cpp/src/verilatorCatchMain.cpp"
    "bench/cpp/src/testUARTTx.cpp"
    ${VERILATED}
    ${VERILATED_TRACE}
)

# Add a dependency to the verilator generated libraries
add_dependencies(test_UARTTx vl_libs)

# Link to the Verilator Generated static library
target_link_libraries(test_UARTTx ${VL_UART_TX}) 

# Register a test to this target
add_test(UARTTX_FUNC test_UARTTx)

######################################################
## Testing that the UART Receive Block is Functional
######################################################

# Create new Target
add_executable(test_uart_receive
    "bench/cpp/src/verilatorCatchMain.cpp"
    "bench/cpp/src/testUARTRx.cpp"
    ${VERILATED}
    ${VERILATED_TRACE}
)

# Add a dependency to the verilator generated libraries
add_dependencies(test_uart_receive vl_libs)

# Link to the Verilator Generated static library
target_link_libraries(test_uart_receive ${VL_UART_RX}) 

# Register a test to this target
add_test(UARTRX_FUNC test_uart_receive)


######################################################
## Testing that the FIFO Block is Functional
######################################################

# Create new Target
add_executable(test_FIFO
    "bench/cpp/src/verilatorCatchMain.cpp"
    "bench/cpp/src/testFifo.cpp"
    ${VERILATED}
    ${VERILATED_TRACE}
)

# Add a dependency to the verilator generated libraries
add_dependencies(test_FIFO vl_libs)

# Link to the Verilator Generated static library
target_link_libraries(test_FIFO ${VL_FIFO}) 

# Register a test to this target
add_test(FIFO_FUNC test_FIFO)

######################################################
## Testing that the top level block is functional
######################################################

# Create new Target
add_executable(test_WB_UART
    "bench/cpp/src/verilatorCatchMain.cpp"
    "bench/cpp/src/testUART.cpp"
    "bench/cpp/src/tcp/TCPServer.cpp"
    ${VERILATED}
    ${VERILATED_TRACE}
)

# Add a dependency to the verilator generated libraries
add_dependencies(test_WB_UART vl_libs)

# Link to the Verilator Generated static library
target_link_libraries(test_WB_UART ${VL_WB_UART}) 

# Register a test to this target
add_test(MODULE_FUNC test_WB_UART)