######################################################
## Simple TCPServer on port 8080 that echos command
######################################################

# Create new Target
add_executable(helloUart
    "bench/cpp/src/examples/helloUart.cpp"
    ${VERILATED}
    ${VERILATED_TRACE}
)

# link to the verilator library
set(VL_HELLO_UART "${VL_OBJECT_DIR}/hello_uart/Vhello_uart__ALL.a")
target_link_libraries(helloUart ${VL_HELLO_UART})