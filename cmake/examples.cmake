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

add_executable(TCPEcho
    "bench/cpp/src/examples/uartEcho.cpp"
)

# Link to the boost and PThread Library
target_link_libraries(TCPEcho PUBLIC
    ${Boost_LIBRARIES} 
    Threads::Threads
    )

# verilate the top level module
verilate(TCPEcho SOURCES "bench/verilog/hello_uart.v" TRACE INCLUDE_DIRS ${RTL} 
    VERILATOR_ARGS "-GCYCLES_PER_BIT=32" "-GCOUNTER_VALUE=100"
    )