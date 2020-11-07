# Create new Target
add_executable(test_UARTTx
    "bench/cpp/src/verilatorCatchMain.cpp"
    "bench/cpp/src/testUARTTx.cpp"
    ${VERILATED}
    ${VERILATED_TRACE}
)

# Link the Verilator code generation as a dependency of the target
if(${REBUILD_VERILATOR})
    add_dependencies(test_UARTTx UART_TX_vl)
endif()

target_link_libraries(test_UARTTx 
    "${CMAKE_SOURCE_DIR}/verilator/obj_dir/uart_tx/Vuart_tx__ALL.a"
) # Link to the Verilator Generated static library

add_test(
    NAME    UARTTX_FUNC
    COMMAND test_UARTTx
    )

