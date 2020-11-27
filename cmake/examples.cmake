######################################################
## Simple TCPServer on port 8080 that echos command
######################################################

# Create new Target
add_executable(echoServer
    "bench/cpp/src/echoServer.cpp"
    "bench/cpp/src/tcp/TCPServer.cpp"
)