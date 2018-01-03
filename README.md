# Digital_Clock
A digital clock that counts down from 24:00:00 to 00:00:00, when it reaches 00:00:00 an alarm sounds and the displays start flashing, to reset the clock you press a button that only works at this state, you can also press a button to decrease the minutes on the clock in a fast way during the countdown. To simulate this digital clock open the proteus file and add the .hex file to the PIC and set it to 4Mhz, also add the .bin file to the 27C256 EPROM to get it working properly

Components used:

*16F84A PIC

*27C256 EPROM

*BCD to 7 segment decoder

*7 segment displays

Note: there exists a component that can do the same thing the 27C256 EPROM does, and it is called 74185, its function is to convert a 6 bit binary number to its BCD equivalent
