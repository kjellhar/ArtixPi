
# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

variable script_file
set script_file "build_project.tcl"

set orig_proj_dir "[file normalize "$origin_dir/work"]"

# Create project
create_project top ./work -part xc7a200tfbg484-1

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [get_projects top]
set_property "board_part" "" $obj
set_property "compxlib.activehdl_compiled_library_dir" "$proj_dir/top.cache/compile_simlib/activehdl" $obj
set_property "compxlib.funcsim" "1" $obj
set_property "compxlib.ies_compiled_library_dir" "$proj_dir/top.cache/compile_simlib/ies" $obj
set_property "compxlib.modelsim_compiled_library_dir" "$proj_dir/top.cache/compile_simlib/modelsim" $obj
set_property "compxlib.overwrite_libs" "0" $obj
set_property "compxlib.questa_compiled_library_dir" "$proj_dir/top.cache/compile_simlib/questa" $obj
set_property "compxlib.riviera_compiled_library_dir" "$proj_dir/top.cache/compile_simlib/riviera" $obj
set_property "compxlib.timesim" "1" $obj
set_property "compxlib.vcs_compiled_library_dir" "$proj_dir/top.cache/compile_simlib/vcs" $obj
set_property "compxlib.xsim_compiled_library_dir" "" $obj
set_property "corecontainer.enable" "0" $obj
set_property "default_lib" "xil_defaultlib" $obj
set_property "enable_optional_runs_sta" "0" $obj
set_property "generate_ip_upgrade_log" "0" $obj
set_property "ip_cache_permissions" "" $obj
set_property "ip_output_repo" "" $obj
set_property "managed_ip" "0" $obj
set_property "part" "xc7a200tfbg484-1" $obj
set_property "pr_flow" "0" $obj
set_property "sim.ip.auto_export_scripts" "1" $obj
set_property "sim.use_ip_compiled_libs" "0" $obj
set_property "simulator_language" "Mixed" $obj
set_property "source_mgmt_mode" "All" $obj
set_property "target_language" "VHDL" $obj
set_property "target_simulator" "XSim" $obj
set_property "xpm_libraries" "XPM_CDC" $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
set files [list \
 "[file normalize "$origin_dir/src/hdl/top.vhd"]"\
 "[file normalize "$origin_dir/src/hdl/ocore/spi_slave.vhd"]"\
 "[file normalize "$origin_dir/src/ip/clk_wiz_0/clk_wiz_0.xci"]"\
]
add_files -norecurse -fileset $obj $files

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]
set files [list \
 "[file normalize "$origin_dir/src/xdc/artixpi_io.xdc"]"\
 "[file normalize "$origin_dir/src/xdc/artixpi_config_spi.xdc"]"\
]
add_files -norecurse -fileset $obj $files

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
# Empty (no sources present)




puts "INFO: Project created:top"
