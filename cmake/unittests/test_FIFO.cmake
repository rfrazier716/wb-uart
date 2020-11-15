# Create new Target
add_executable(test_FIFO
    "bench/cpp/src/verilatorCatchMain.cpp"
    "bench/cpp/src/testFifo.cpp"
    ${VERILATED}
    ${VERILATED_TRACE}
)

# Link the Verilator code generation as a dependency of the target
if(${REBUILD_VERILATOR})
    add_dependencies(test_FIFO FIFO_vl)
endif()

target_link_libraries(test_FIFO 
    "${CMAKE_SOURCE_DIR}/verilator/obj_dir/fifo/Vfifo__ALL.a"
) # Link to the Verilator Generated static library

add_test(
    NAME    FIFO_FUNC
    COMMAND test_FIFO
    )

