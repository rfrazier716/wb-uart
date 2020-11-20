# Define All unittests here, for larger projects, tests can be split into separate CMAKE files

set(TEST_DIR "${CMAKE_CURRENT_LIST_DIR}/unittests")
message("Building UnitTests in ${TEST_DIR}")

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