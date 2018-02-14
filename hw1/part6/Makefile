# Makefile to run verilog simulations
#
# Targets:
#    "make compile"             compiles only
#    "make run"                 runs only
#    "make viewer"              starts waveform viewer
#    "make run_interactive"     starts simulation/debugging environment
#    "make run_interactive_2"   starts simulation/debugging environment
#    "make clean"               deletes temporary files and dirs
#
# Notes for ncverilog:
#
# Notes for vcs:
#  -Mdir     Temporary file space; can give a big speedup
#  -Mupdate  Incremental compile
#  -PP       Enables vcs to work with vcd+ files
#  -R        Run executable after compiling and linking
#  -RI       Bring up interactive GUI after compiling and linking
#  -RPP      Run post-processing mode; starts virsim
#
# A few notes on writing a Makefile
#  - Make sure commands are preceded by a "tab"; spaces will not work!
#  - You may also add dependencies so that a command will execute only
#    if the dependency has been updated more recently than the target
#    (name the target with the same name as the output of the command(s)).
#  - Use a "-n" flag to see what make will use without running the
#    command(s).  Ex: "make -n clean"
#
# 2005/02/03  Added verilog (verilog XL) targets
# 2005/01/20  Added ncverilog targets
# 2004/03/09  Added $(NAME_TOP) variable
# 2004/02/03  Added cleanall target
# 2004/01/22  Updated
# 2003/05/27  Added "-l" logfiles
# 2003/05/12  Improved and now works for standalone sims and viewer
# 2003/04/18  Set up for homework 2


#----- Useful variables
NAME_TOP	:= tbench
USERNAME	:= $(shell whoami)
DIR_TMP		:= /tmp/$(USERNAME)verilog


#----- Targets, ncverilog
# Use this to compile without running simulation
compile:
	ncverilog -c        -l $(NAME_TOP).log -f $(NAME_TOP).vf

# Run simulation
run:
	ncverilog +access+r -l $(NAME_TOP).log -f $(NAME_TOP).vf

# Start viewer
viewer:
	simvision &

# ncverilog help, command line
help:
	ncverilog -h | less -Mq

#----- Targets, verilog-XL
# Use this to compile without running simulation
compile_xl:
	verilog -c        -l $(NAME_TOP).log -f $(NAME_TOP).vf

# Run simulation
run_xl:
	verilog +access+r -l $(NAME_TOP).log -f $(NAME_TOP).vf

#----- Cleanup
# Delete temporary files
clean:
	rm -f  simv
	rm -rf simv.daidir
	rm -f  vcs.key
	rm -rf $(DIR_TMP)
	rm -rf INCA_libs/

cleanall: clean
	rm -f  $(NAME_TOP).log
	rm -f  $(NAME_TOP).dsn
	rm -f  $(NAME_TOP).trn
	rm -f  $(NAME_TOP).vpd


#----- Targets, vcs  (apparently broken)
# Use this to compile without running simulation
compile_vcs:
	vcs -Mdir=$(DIR_TMP) -Mupdate -PP -C +v2k -f $(NAME_TOP).vf

# Use these two targets to run vcs separately from viewer
run_vcs:
	vcs -Mdir=$(DIR_TMP) -Mupdate -PP -R -f $(NAME_TOP).vf \
	-l $(NAME_TOP).log

viewer_vcs:
	vcs -RPP &

# Use this to run and view waveform in an integrated environment
run_interactive_vcs:
	vcs -RI +v2k -f $(NAME_TOP).vf -l $(NAME_TOP).log &

run_interactive_2_vcs:
	vcs -RI +v2k -Mupdate -f $(NAME_TOP).vf -l $(NAME_TOP).log &

# VCS help
help_vcs:
	vcs -help | less -Mq

