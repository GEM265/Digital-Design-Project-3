## ALU Constraints File - No Clock Needed (Combinational Logic)

## Switches as inputs
# b[5:0] - Second operand (Switches 5-0)
set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports { b[5] }]; # Switch 5
set_property -dict { PACKAGE_PIN R17 IOSTANDARD LVCMOS33 } [get_ports { b[4] }]; # Switch 4
set_property -dict { PACKAGE_PIN R15 IOSTANDARD LVCMOS33 } [get_ports { b[3] }]; # Switch 3
set_property -dict { PACKAGE_PIN M13 IOSTANDARD LVCMOS33 } [get_ports { b[2] }]; # Switch 2
set_property -dict { PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports { b[1] }]; # Switch 1
set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports { b[0] }]; # Switch 0

# a[5:0] - First operand (Switches 11-6)
set_property -dict { PACKAGE_PIN T13 IOSTANDARD LVCMOS33 } [get_ports { a[5] }]; # Switch 11
set_property -dict { PACKAGE_PIN R16 IOSTANDARD LVCMOS33 } [get_ports { a[4] }]; # Switch 10
set_property -dict { PACKAGE_PIN U8  IOSTANDARD LVCMOS33 } [get_ports { a[3] }]; # Switch 9
set_property -dict { PACKAGE_PIN T8  IOSTANDARD LVCMOS33 } [get_ports { a[2] }]; # Switch 8
set_property -dict { PACKAGE_PIN R13 IOSTANDARD LVCMOS33 } [get_ports { a[1] }]; # Switch 7
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports { a[0] }]; # Switch 6

# sel[3:0] - Operation selector (Switches 15-12)
set_property -dict { PACKAGE_PIN V10 IOSTANDARD LVCMOS33 } [get_ports { sel[3] }]; # Switch 15
set_property -dict { PACKAGE_PIN U11 IOSTANDARD LVCMOS33 } [get_ports { sel[2] }]; # Switch 14
set_property -dict { PACKAGE_PIN U12 IOSTANDARD LVCMOS33 } [get_ports { sel[1] }]; # Switch 13
set_property -dict { PACKAGE_PIN H6  IOSTANDARD LVCMOS33 } [get_ports { sel[0] }]; # Switch 12

## Output LEDs r[5:0] - Result (LEDs 5-0)
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports { r[5] }]; # LED 5
set_property -dict { PACKAGE_PIN R18 IOSTANDARD LVCMOS33 } [get_ports { r[4] }]; # LED 4
set_property -dict { PACKAGE_PIN N14 IOSTANDARD LVCMOS33 } [get_ports { r[3] }]; # LED 3
set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS33 } [get_ports { r[2] }]; # LED 2
set_property -dict { PACKAGE_PIN K15 IOSTANDARD LVCMOS33 } [get_ports { r[1] }]; # LED 1
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports { r[0] }]; # LED 0