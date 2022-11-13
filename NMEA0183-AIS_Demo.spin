{
    --------------------------------------------
    Filename: NMEA0183-AIS_Demo.spin
    Author: Jesse Burt
    Description: Simple demo that uses the NMEA0183 object
        to parse AIS sentences.
    Copyright (c) 2022
    Started Jul 7, 2022
    Updated Nov 13, 2022
    See end of file for terms of use.
    --------------------------------------------
}

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

' -- User-modifiable constants
    LED         = cfg#LED1
    SER_BAUD    = 115_200
' --

OBJ

    cfg     : "boardcfg.flip"
    ser     : "com.serial.terminal.ansi"
    time    : "time"
    nmea    : "protocol.navigation.nmea0183"

DAT
    { copy AIS sentence here }
    _sentence byte "!AIVDM,1,1,,A,177l?m9000`:Pk`<i`kh0lSd00R;,0*30"

    byte ser#CR, ser#LF, 0

PUB main{}

    setup{}

    nmea.ptr_sentence(@_sentence)               ' tell NMEA0183 object where the sentence data is

    if (byte[@_sentence][0] := nmea#AIS_START)
        ser.pos_xy(0, 3)
        ' show the raw sentence
        ser.printf1(string("Sentence: %s"), @_sentence)
        ser.clear_line{}
        ser.newline{}
        display_vdm{}
    repeat

PUB display_vdm{}

    ser.printf1(@"Total sentences in message: %d\n\r", nmea.ais_msg_len{})
    ser.printf1(@"Sentence number: %d\n\r", nmea.ais_sentence_nr{})
    ser.printf1(@"Sequential message ID: %s\n\r", nmea.ais_seq_msg_id{})
    ser.printf1(@"AIS channel: %c\n\r", nmea.ais_channel{})
    ser.printf1(@"AIS message: %s\n\r", nmea.ais_message{})
    ser.printf1(@"AIS message fill bits: %d\n\r", nmea.ais_fillbits{})

PUB setup{}

    ser.start(SER_BAUD)
    time.msleep(30)
    ser.clear{}
    ser.strln(string("Serial terminal started"))

DAT
{
Copyright 2022 Jesse Burt

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}
