# UPDuino2

Setting up the toolchain to upload code on an iCE family fpgas using Apio

## Install prerequisites

IMPORTANT: you need pip3 installed  

'''bash
pip3 install -U apio
'''

Once installed make sure to activate drivers (FTDI/Serial) & install all packages

'''bash
apio drivers --ftdi-enable #FTDI

apio drivers --serial-enable #Serial

apio install --all
'''

## Setting project environment
Apio support some boards, you can list them with:

'''bash
apio boards --list
'''

To initiate a project folder type:

'''bash
apio init --board BOARDNAME 
'''

## Build & Upload
First you need to check your verilog code using Icarus Verilog

'''bash
apio verify
'''

apio offers a suite named GTKWave which can simulate the test bench

'''bash
apio sim
'''

Finally we can build our code and upload on the fpga

'''bash
apio build

apio upload
'''

## Examples 
(update 2/14/22) I have upload 3 examples to check you configuration.

Just clone the repository and try to build and upload the files inside
