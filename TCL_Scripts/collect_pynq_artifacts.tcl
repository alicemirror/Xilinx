set project_path [get_property directory [current_project]]
set project_file [file rootname $project_path]
set __project [current_project]
set hw_dir [file dirname [get_files *.hwh]]
set hwhandoff [glob [file join $hw_dir *.hwh]]
set bitstream [glob [file join $project_path $__project.runs impl_1 *.bit]]

#gather in the .prj directory
file copy -force $hwhandoff $project_file.hwh
file copy -force $bitstream $project_file.bit


