module_name="wb_uart"
obj_dir="obj_dir/$module_name"
mkdir -p $obj_dir
verilator -cc "../rtl/$module_name.v" -I"../rtl" -trace --no-trace-params -GCYCLES_PER_BIT=8 --Mdir $obj_dir
cd $obj_dir
make -f "V$module_name.mk"