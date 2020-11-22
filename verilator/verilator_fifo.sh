module_name="fifo"
obj_dir="obj_dir/$module_name"
mkdir -p $obj_dir
verilator -Wall -cc "../rtl/$module_name.v" -trace --no-trace-params -GFIFO_DEPTH=3 --Mdir $obj_dir
cd $obj_dir
make -f "V$module_name.mk"