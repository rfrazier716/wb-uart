if(${REBUILD_VERILATOR})
    add_custom_target(UART_TX_vl ALL
        COMMAND sh verilator_uart_tx.sh
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/verilator/"
        )
ENDIF()