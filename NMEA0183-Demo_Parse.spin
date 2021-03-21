{
    --------------------------------------------
    Filename: NMEA0183-Demo_Parse.spin
    Author: Jesse Burt
    Description: Simple demo that uses the NMEA0183 object
        to parse sentences read from a compatible 9600bps-connected
        GPS module and displays the data on the terminal.
    Copyright (c) 2021
    Started Sep 8, 2019
    Updated Mar 21, 2021
    See end of file for terms of use.
    --------------------------------------------
}

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

' -- User-modifiable constants
    LED         = cfg#LED1
    SER_BAUD    = 115_200

    GPS_TXD     = 18
    GPS_RXD     = 17
    GPS_BAUD    = 9600
' --

OBJ

    cfg     : "core.con.boardcfg.flip"
    ser     : "com.serial.terminal.ansi"
    gps     : "com.serial.terminal"
    time    : "time"
    int     : "string.integer"
    nmea    : "protocol.navigation.nmea0183"

VAR

    byte _sentence[nmea#SENTNC_MAX_LEN]

PUB Main{} | gps_rx, idx, talk_id, sent_id, allow

    setup{}

    nmea.sentenceptr(@_sentence)                ' tell NMEA0183 object where
                                                '   the raw sentence data is

    allow := nmea#SNTID_RMC
    repeat
        ' clear out sentence buffer
        bytefill(@_sentence, 0, nmea#SENTNC_MAX_LEN)
        idx := 0
        repeat until gps.charin{} == "$"        ' start of sentence
        repeat
            gps_rx := gps.charin{}              ' read sentence data (ASCII)
            _sentence[idx++] := gps_rx
        until gps_rx == ser#CR                  ' end of sentence
        idx := 0

        talk_id := nmea.talkerid{}
        sent_id := nmea.sentenceid{}

        case sent_id
            0, allow:                           ' if not the chosen sentence
            other:                              ' type (or if 0), then skip it
                next

        ser.str(string("Sentence: "))
        repeat                                  ' display raw sentence
            ser.char(_sentence[idx])
        until _sentence[++idx] == ser#CR
        ser.clearline{}
        ser.newline{}

        case sent_id
            nmea#SNTID_VTG:

            nmea#SNTID_GGA:
                display_gga{}
            nmea#SNTID_GSA:

            nmea#SNTID_RMC:
                display_rmc{}
            nmea#SNTID_GSV:

            other:
                ser.str(string("Talker ID: "))
                ser.char(talk_id.byte[0])
                ser.char(talk_id.byte[1])
                ser.newline{}

                ser.str(string("Sentence ID: "))
                ser.char(sent_id.byte[0])
                ser.char(sent_id.byte[1])
                ser.char(sent_id.byte[2])
                ser.char(" ")
                ser.hex(sent_id, 6)

                ser.newline{}

        ser.str(string("Checksum: "))
        ser.hex(nmea.checksum{}, 2)
        if nmea.checksum{} == nmea.genchecksum{}
            ser.strln(string(" (GOOD)"))
        else
            ser.str(string(" (BAD - got "))
            ser.hex(nmea.genchecksum{}, 2)
            ser.strln(string(")"))

        ser.newline{}

PUB Display_GGA{}

    ser.str(string("Latitude: "))
    ser.str(int.deczeroed(nmea.latitude{}, 8))
    ser.str(string("    Longitude: "))
    ser.strln(int.deczeroed(nmea.longitude{}, 9))
    ser.newline{}

PUB Display_RMC{}

    ser.str(string("Latitude: "))
    ser.str(int.deczeroed(nmea.latitude{}, 8))
    ser.str(string("    Longitude: "))
    ser.strln(int.deczeroed(nmea.longitude{}, 9))
    ser.newline{}

PUB Setup{}

    ser.start(SER_BAUD)
    time.msleep(30)
    ser.clear{}
    ser.strln(string("Serial terminal started"))
    gps.startrxtx(GPS_TXD, GPS_RXD, %0000, GPS_BAUD)
    gps.strln(string("GPS serial started"))

DAT
{
    --------------------------------------------------------------------------------------------------------
    TERMS OF USE: MIT License

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
    associated documentation files (the "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
    following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial
    portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
    LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    --------------------------------------------------------------------------------------------------------
}
