module_name="hello_uart"
obj_dir="obj_dir/$module_name"
mkdir -p $obj_dir
verilator -Wall -cc "../bench/verilog/$module_name.v" -I"../rtl" -GCYCLES_PER_BIT=8 -GCOUNTER_VALUE=100 -trace --no-trace-params --Mdir $obj_dir
cd $obj_dir
make -f "V$module_name.mk"