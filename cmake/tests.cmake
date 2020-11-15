set(TEST_DIR "${CMAKE_CURRENT_LIST_DIR}/unittests")
message("Building UnitTests in ${TEST_DIR}")
#Individual Unittests included below
#-------------------------------------------------
include("${TEST_DIR}/test_UARTTx.cmake")
include("${TEST_DIR}/test_FIFO.cmake")