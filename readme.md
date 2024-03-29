# Apple II (another) MATRIX

A basic program to display a MATRIX like screen.
It is written in assembly language only (Merlin).

## Credits

* strongly inspired by : NEIL KANDALGAONKAR <neilk@neilk.net>
* https://github.com/neilk/apple-ii-matrix
* Pseudo random numbers  : David Empson - "Random number generator" 
* https://www.apple2.org.za/gswv/a2zine/GS.WorldView/v1999/Nov/Articles.and.Reviews/Apple2RandomNumberGenerator.htm
* Robert C Moore -  "Random Bytes" (The Sourceror's Apprentice, Volume 1 Number 4 - April 1989)
* https://brutaldeluxe.fr/documentation/thesourcerorsapprentice.html

## Features

* Works with ProDOS 8, it should work on DOS 3.3 (not tested with DOS 3.3 nor on GS)
* The program turns on 40 col. mode.
* Use the space bar to toggle between slow and fast mode. The fast mode disable wait loops.
* Use escape key to exit
* Use any other key to pause/unpause

## Requirements to compile and run

Here is my configuration:

* Visual Studio Code with 2 extensions :

-> [Merlin32 : 6502 code hightliting](https://marketplace.visualstudio.com/items?itemName=olivier-guinart.merlin32)

-> [Code-runner :  running batch file with right-clic.](https://marketplace.visualstudio.com/items?itemName=formulahendry.code-runner)

* [Merlin32 cross compiler](https://brutaldeluxe.fr/products/crossdevtools/merlin)

* [Applewin : Apple IIe emulator](https://github.com/AppleWin/AppleWin)

* [Applecommander ; disk image utility](https://applecommander.sourceforge.net)

* [Ciderpress ; disk image utility](https://a2ciderpress.com)

Note :
DoMerlin.bat puts all things together. It needs a path to Merlin32 directory, to Applewin, and to Applecommander.
DoMerlin.bat is to be placed in project directory.
It compile source (*.s) with Merlin32, copy 6502 binary to a disk image (containg ProDOS), and launch Applewin with this disk in S1,D1.

mA2.s is ready to be compiled on a genuine Apple II, with Merlin 8.
It can be imported in a disk image using Ciderpress, then used on an Apple II (c in my case).
I use [Floppy emu](www.bigmessowires.com/floppy-emu) wich is really great, congratulation to Big Mess O'Wire !!!!
See "Merlin32 to apple II Merlin 8.txt" to know how to convert a Merin32 source to a Merlin 8 compatible source.

## Todo

* End display with "THE MATRIX" (or something else ending with IX!!) in the center.
* Port it on HGR
