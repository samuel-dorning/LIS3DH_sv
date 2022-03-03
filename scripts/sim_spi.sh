#!/bin/bash
QUIET=0
CMD=""
while getopts "q" opt; do
	case ${opt} in
			q )
				QUIET=1
			  ;;
	esac
done
~/intelFPGA_lite/20.1/modelsim_ase/bin/vlog ./rtl/tb_spi.sv ./rtl/spi.sv
if [ $QUIET -eq 1 ]
then
	CMD="~/intelFPGA_lite/20.1/modelsim_ase/bin/vsim -do \"vsim work.tb_spi -t ns; add wave *; run -all; quit\" -quiet -c"
else
	CMD="~/intelFPGA_lite/20.1/modelsim_ase/bin/vsim -do \"vsim work.tb_spi -t ns; add wave *; add wave tb_spi/u0/*; run -all\""
fi
eval $CMD
