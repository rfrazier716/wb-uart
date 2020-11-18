# This file regenerates the Verilator library files by creating custom commands that generated the outputed files
# and a custom target that depends on those output files
# For any source file that depends on these libraries you must use put ADD_DEPENDENCIES(TARGET vl_libs) in order to ensure they're built before the target is

if(${REBUILD_VERILATOR})

    add_custom_command(OUTPUT ${VL_UART_TX}
        COMMAND sh verilator_uart_tx.sh
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/verilator/"
    )

    add_custom_command(OUTPUT ${VL_FIFO}
        COMMAND sh verilator_fifo.sh
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/verilator/"
    )
    
endif()

add_custom_target(vl_libs ALL
    COMMAND echo -e "Checking Verilator Libraries Exist"
    DEPENDS
        ${VL_UART_TX}
        ${VL_FIFO}
)