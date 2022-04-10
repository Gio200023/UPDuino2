# UPDuino2

## Overview

UPDuino is a microcontroller made of Himax HM01B0 camera module and iCE40 ultraplus family FPGA.
![168838047](https://user-images.githubusercontent.com/75630696/161726892-f62a8bcd-0d60-4915-b50a-c620269e3d4e.png)

UPDuino integrated circuit was designed by LatticeSemi company, now it has passed under TinyVision.ai. 

Here you can find the datasheet of the FPGA: [iCE40 UltraPlus family datasheet](https://github.com/Gio200023/UPDuino2/blob/main/FPGA-DS-02008-2-0-iCE40-UltraPlus-Family-Data-Sheet.pdf)
Here you can find the datasheet of the UPDuino shield:[Himax HM01B0 Upduino Shield](https://github.com/Gio200023/UPDuino2/blob/main/FPGA-UG-02081-1-0-Himax-HM01B0-UPduino-Shield.pdf)

## Compile and Program projects

To compile your projects you have 2 options:
    
    • Lattice Radiant Software & Lattice Radiant Programmer
    
    • Apio

> Design resource examples from LatticeSemi won't build with apio tool because they use proprietary compiler
 
<hr>

# Lattice Radiant Sfotware && Programmer

Compatible OS: Windows, Linux

You can use Radiant Software to write, synthesize, compile and create bitstream file for your project. 
Once done that you can upload the .bin file into the Programmer Software. Here you have to select spi mode to upload it and set up the settings for spi transfer. 
Here you can find some help: [Radiant Software && Programmer Guide](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwib_-r01vz2AhUrMuwKHbhDBt0QFnoECAkQAQ&url=https%3A%2F%2Fwww.latticesemi.com%2Fview_document%3Fdocument_id%3D53415&usg=AOvVaw1L9MUlzzXXryP3fbcs7Z17)

In iCE40  UltraPlus Hand Gesture Detection folder there are reference design to build, compile and upload the project on UPDuino.
Same thing in human presence detection folder.

<hr>

# Apio

Installation and building phase with Apio tool

## Install prerequisites

> IMPORTANT: you need pip3 installed  

````
pip3 install -U apio
````

Once installed make sure to activate drivers (FTDI/Serial) & install all packages

````
apio drivers --ftdi-enable #FTDI

apio drivers --serial-enable #Serial

apio install --all
````


## Setting project environment
Apio support some boards, you can list them with:

````
apio boards --list
````

To initiate a project folder type:

````
apio init --board BOARDNAME 
````


## Build & Upload
First you need to check your verilog code using Icarus Verilog

````
apio verify
````

apio offers a suite named GTKWave which can simulate the test bench

````
apio sim
````

Finally we can build our code and upload on the fpga

````
apio build

apio upload
````


## Examples 
> (update 2/14/22) I have upload 3 examples to check you configuration.

Just clone the repository and try to build and upload the files inside

## Documentation

[Apio](https://apiodoc.readthedocs.io/en/stable/index.html)
