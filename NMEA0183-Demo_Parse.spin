{
    --------------------------------------------
    Filename: NMEA0183-Demo_Parse.spin
    Author: Jesse Burt
    Description: Simple demo that uses the NMEA0183 object
        to parse sentences read from a compatible serial-connected
        GPS module and displays the data on the terminal.
    Copyright (c) 2022
    Started Sep 8, 2019
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

    GPS_TXD     = 1
    GPS_RXD     = 2
    GPS_BAUD    = 9600
' --

OBJ

    cfg     : "boardcfg.flip"
    ser     : "com.serial.terminal.ansi"
    gps     : "com.serial.terminal"
    time    : "time"
    nmea    : "protocol.navigation.nmea0183"

VAR

    byte _sentence[nmea#SENTNC_MAX_LEN]

PUB main{} | allowed

    setup{}

    nmea.ptr_sentence(@_sentence)               ' tell NMEA0183 object where the sentence data is

    { sentence type to display:
        SNTID_VTG, SNTID_GGA, SNTID_GSA, SNTID_RMC, SNTID_GSV }
    allowed := nmea#SNTID_RMC

    repeat
        ' clear out sentence buffer
        bytefill(@_sentence, 0, nmea#SENTNC_MAX_LEN)

        repeat until (gps.getchar{} == nmea#SENTSTART)
        gps.gets(@_sentence)                    ' read sentence data (ASCII)

        if (nmea.sentence_id{} == allowed)
            ser.pos_xy(0, 3)
            ' show the raw sentence
            ser.printf1(string("Sentence: %s"), @_sentence)
            ser.clear_line{}
            ser.newline{}
            case nmea.sentence_id{}             ' now extract and print data
                nmea#SNTID_VTG:                 '   pertinent to each sentence
                    display_vtg{}
                nmea#SNTID_GGA:
                    display_gga{}
                nmea#SNTID_GSA:
                    display_gsa{}
                nmea#SNTID_RMC:
                    display_rmc{}
                nmea#SNTID_GSV:
                    display_gsv{}
        else
            next

PUB display_gga{}

    disp_pos{}
    ser.printf1(string("Time: %d\n\r"), nmea.time_of_day{})

PUB display_gsa{} | fix_stat

    case nmea.fix{}
        1:
            fix_stat := string("No fix")
        2:
            fix_stat := string("2D fix")
        3:
            fix_stat := string("3D fix")

    ser.printf1(string("Position fix: %s\n\r"), fix_stat)
    ser.printf1(string("HDOP: %d   \n\r"), nmea.hdop{})
    ser.printf1(string("PDOP: %d   \n\r"), nmea.pdop{})
    ser.printf1(string("VDOP: %d   \n\r"), nmea.vdop{})

PUB display_gsv{}

PUB display_rmc{}

    disp_pos{}
    ser.printf3(string("Date: %02.2d/%02.2d/%02.2d\n\r"), nmea.month{}, nmea.date{}, nmea.year{})

    ser.printf3(string("Time: %02.2d:%02.2d:%02.2d\n\r"), nmea.hours{}, nmea.minutes{}, {
}                                                         nmea.seconds{})

    ser.printf2(string("Course (true): %03.3d.%02.2d\n\r"), (nmea.course_true{} / 100), {
}                                                           (nmea.course_true{} // 100))

    ser.printf2(string("Speed: %d.%02.2dkts\n\r"), (nmea.speed_kts{} / 100), {
}                                                  (nmea.speed_kts // 100))

PUB display_vtg{}

    ser.printf1(string("Course (true): %d    \n\r"), nmea.course_true{})
    ser.printf1(string("Course (magnetic): %d    \n\r"), nmea.course_magnetic{})
    ser.printf1(string("Speed: %dkts    \n\r"), nmea.speed_kts{})
    ser.printf1(string("Speed: %dkm/h    \n\r"), nmea.speed_kmh{})

PRI disp_pos{}
' Display position
    ser.printf4(string("Latitude: %02.2ddeg %02.2d.%04.4dmin %c\n\r"), nmea.lat_deg{}, {
}                                                                      nmea.lat_minutes_whole{}, {
}                                                                      nmea.lat_minutes_part{}, {
}                                                                      nmea.north_south{})

    ser.printf4(string("Longitude: %02.2ddeg %02.2d.%04.4dmin %c\n\r"), nmea.long_deg{}, {
}                                                                       nmea.long_minutes_whole{},{
}                                                                       nmea.long_minutes_part{}, {
}                                                                       nmea.east_west{})

PUB setup{}

    ser.start(SER_BAUD)
    time.msleep(30)
    ser.clear{}
    ser.strln(string("Serial terminal started"))
    gps.startrxtx(GPS_TXD, GPS_RXD, %0000, GPS_BAUD)
    ser.strln(string("GPS serial started"))

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

