Mainframe for the HP-41 calculator
===================================

This project is the core operating system of he HP-41 calculator.
It can be used to recreate various historical versions from source
code.

In addition it is used my for future development of the mainframe
code. The `dev-newt` branch contains my variant of this operating
system for the HP-41CL (NEWT). This version corrects various old
standing bugs, adds speed annotations for the NEWT and also the much
larger Extended Memory feature that can be used to convert RAM pages 4
and up to working Extended Memory.

There are some few modules around that copied the code for these entry
points and if you are the maintainer of these, please consider adding
a variant that uses the official entry points in the HP-41CX and
HP-41CL. Feel free to get in touch with me to discuss this.

The tools used to build this project is
[Calypsi tool chain for the Nut](https://www.calypsi.cc/).
