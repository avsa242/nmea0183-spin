{
    --------------------------------------------
    Filename: NMEA0183-AIS_Demo.spin
    Author: Jesse Burt
    Description: Simple demo that uses the NMEA0183 object
        to parse AIS sentences.
    Copyright (c) 2022
    Started Jul 7, 2022
    Updated Jul 7, 2022
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

    cfg     : "core.con.boardcfg.flip"
    ser     : "com.serial.terminal.ansi"
    time    : "time"
    nmea    : "protocol.navigation.nmea0183"

DAT
    { copy AIS sentence here }
    _sentence byte "!AIVDM,1,1,,A,177l?m9000`:Pk`<i`kh0lSd00R;,0*30"

    byte ser#CR, ser#LF, 0

PUB Main{}

    setup{}

    nmea.sentenceptr(@_sentence)                ' tell NMEA0183 object where
                                                '   the raw sentence data is

    if (byte[@_sentence][0] := nmea#AIS_START)
        ser.position(0, 3)
        ' show the raw sentence
        ser.printf1(string("Sentence: %s"), @_sentence)
        ser.clearline{}
        ser.newline{}
        display_vdm{}
    repeat

PUB Display_VDM{}

    ser.printf1(@"Total sentences in message: %d\n\r", nmea.ais_msglen{})
    ser.printf1(@"Sentence number: %d\n\r", nmea.ais_sntnumb{})
    ser.printf1(@"Sequential message ID: %s\n\r", nmea.ais_seqmsgid{})
    ser.printf1(@"AIS channel: %c\n\r", nmea.ais_channel{})
    ser.printf1(@"AIS message: %s\n\r", nmea.ais_message{})
    ser.printf1(@"AIS message fill bits: %d\n\r", nmea.ais_fillbits{})

PUB Setup{}

    ser.start(SER_BAUD)
    time.msleep(30)
    ser.clear{}
    ser.strln(string("Serial terminal started"))

DAT
{
TERMS OF USE: MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
}