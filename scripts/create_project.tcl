# get the directory where this script resides
set thisDir [file dirname [info script]]

set vivado_dir ..
set local_dir .
set ip_dir $vivado_dir/ip
set xdc_dir $vivado_dir/xdc

# Set the project name
set proj_name "top"

# Create project
create_project $proj_name $local_dir/$proj_name -part xc7z010clg400-1

# Set project properties
set obj [get_projects $proj_name]
set_property "board_part" "digilentinc.com:zybo-z7-10:part0:1.0" $obj
set_property "simulator_language" "Mixed" $obj
set_property "target_language" "Verilog" $obj

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# setup up custom ip repository location
set_property ip_repo_paths "$ip_dir" [current_fileset]
update_ip_catalog


# Source the bd.tcl file to create the bd with custom ip module
# first get the major.minor version of the tool - and source
# the bd creation script that corresponds to the current tool version
set currVer [join [lrange [split [version -short] "."] 0 1] "."]
puts "Current Version $currVer"
if {$currVer eq "2018.2"} {
	# Create block design
	source $thisDir/bd_pynq_mb.tcl
} else {
   # this script will only work with 2016.3, everything else will fail
}

add_files -norecurse $xdc_dir/top.xdc

make_wrapper -files [get_files $local_dir/bd/system/system.bd] -top
add_files -norecurse $local_dir/bd/system/hdl/system_wrapper.v

puts "INFO: Project created:${proj_name}"
