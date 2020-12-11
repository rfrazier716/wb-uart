######################################################
## Simple TCPServer on port 8080 that echos command
######################################################

# Create new Target
add_executable(helloUart
    "bench/cpp/src/examples/helloUart.cpp"
)

# verilate the top level module
verilate(helloUart SOURCES "bench/verilog/hello_uart.v" TRACE INCLUDE_DIRS ${RTL} 
    VERILATOR_ARGS "-GCYCLES_PER_BIT=8" "-GCOUNTER_VALUE=100"
    )