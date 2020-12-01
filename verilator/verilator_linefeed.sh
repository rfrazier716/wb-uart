module_name="linefeed_detector"
obj_dir="obj_dir/$module_name"
mkdir -p $obj_dir
verilator -Wall -cc "../rtl/$module_name.v" -I"../rtl" -trace --no-trace-params --Mdir $obj_dir
cd $obj_dir
make -f "V$module_name.mk"