mul:
	rm -rf xsim.dir/ *.log *.pb *.jou *.wdb *.vcd
	xvlog -f ./include.rtl.list.xsim ./tb/mul_tb.v
	xelab -top mul_tb -snapshot mul_tb_elab
	xsim mul_tb_elab -R

clean:
	rm -rf xsim.dir/ *.log *.pb *.jou *.wdb *.vcd