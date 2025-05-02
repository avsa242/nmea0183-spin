{
----------------------------------------------------------------------------------------------------
    Filename:       NMEA0183-Demo_Parse.spin
    Description:    Simple demo that uses the NMEA0183 object
        to parse sentences read from a compatible serial-connected
        GPS module and displays the data on the terminal.
    Author:         Jesse Burt
    Started:        Sep 8, 2019
    Updated:        May 2, 2025
    Copyright (c) 2025 - See end of file for terms of use.
----------------------------------------------------------------------------------------------------
}

CON

    _clkmode    = xtal1+pll16x
    _xinfreq    = 5_000_000

' -- User-modifiable constants
    SER_BAUD    = 115_200

    GPS_TXD     = 24
    GPS_RXD     = 25

    GPS_BAUD    = 9600
' --

OBJ

    ser:    "com.serial.terminal.ansi"
    gps:    "com.serial.terminal.ansi"
    nmea:   "protocol.navigation.nmea0183"
    time:   "time"


VAR

    byte _sentence[nmea.SENTENCE_MAX_LEN]

PUB main()

    setup()
    ser.clear()

    nmea.init(@_sentence)                       ' tell NMEA0183 object where the sentence data is
    repeat
        read_sentence()                         ' read a sentence into the buffer
        ifnot ( nmea.sentence_good() )          ' if the checksum is bad, skip it
            next

        ser.pos_xy(0, 3)
        ser.str(@_sentence)
        ser.clear_line()
        ser.printf(@"\n\r\n\rTotal received\tGGA: %5d GSA: %5d RMC: %5d VTG: %5d GSV: %5d\n\r", ...
                    nmea._total_gga, ...
                    nmea._total_gsa, ...
                    nmea._total_rmc, ...
                    nmea._total_vtg, ...
                    nmea._total_gsv )
        ser.printf(@"Bad checksum: %5d\n\r", nmea._total_bad)

        { parse each sentence }
        case nmea.sentence_id()
            nmea.SNTID_GGA:
                nmea.parse_gga()
            nmea.SNTID_GSA:
                nmea.parse_gsa()
            nmea.SNTID_GSV:
                nmea.parse_gsv()
            nmea.SNTID_RMC:
                nmea.parse_rmc()
            nmea.SNTID_VTG:
                nmea.parse_vtg()

        { display the parsed data }
        ser.printf(@"Latitude: %02.2d\302\260 %02.2d.%04.4dmin %c\n\r", ...
                    nmea.lat_deg(), ...
                    nmea.lat_minutes_whole(), ...
                    nmea.lat_minutes_part(), ...
                    nmea.north_south() )

        ser.printf(@"Longitude: %02.2d\302\260 %02.2d.%04.4dmin %c\n\r", ...
                    nmea.long_deg(), ...
                    nmea.long_minutes_whole(), ...
                    nmea.long_minutes_part(), ...
                    nmea.east_west() )

        ser.str(@"Position fix: ")
        case nmea.fix()
            0:
                ser.fgcolor(ser.RED|ser.BRIGHT)
                ser.strln(@"No data yet")
            1:
                ser.fgcolor(ser.RED)
                ser.strln(@"No fix     ")
            2:
                ser.fgcolor(ser.BLUE)
                ser.strln(@"2D fix     ")
            3:
                ser.fgcolor(ser.GREEN)
                ser.strln(@"3D fix     ")
        ser.fgcolor(ser.GREY)

        ser.printf(@"HDOP: %2.2d.%02.2d\n\r", (nmea.hdop() / 100), (nmea.hdop() // 100) )
        ser.printf(@"PDOP: %2.2d.%02.2d\n\r", (nmea.pdop() / 100), (nmea.pdop() // 100) )
        ser.printf(@"VDOP: %2.2d.%02.2d\n\r", (nmea.vdop() / 100), (nmea.vdop() // 100) )

        ser.printf(@"Date: %02.2d/%02.2d/%02.2d\n\r",   nmea.month(), ...
                                                        nmea.date(), ...
                                                        nmea.year() )

        ser.printf(@"Time: %02.2d:%02.2d:%02.2d\n\r",   nmea.hours(), ...
                                                        nmea.minutes(), ...
                                                        nmea.seconds() )

        ser.printf(@"Course (true): %03.3d.%02.2d\302\260\n\r", ...
                    (nmea.course_true() / 100), ...
                    (nmea.course_true() // 100) )
        ser.printf(@"Course (magnetic): %d\302\260    \n\r", nmea.course_magnetic() )

        ser.printf(@"Speed: %d.%02.2dkts\n\r",  (nmea.speed_kts() / 100), ...
                                                (nmea.speed_kts // 100) )

        ser.printf(@"Speed: %dkm/h    \n\r", nmea.speed_kmh() )


PUB read_sentence()

    repeat until ( gps.getchar() == nmea.SENTSTART )
    gps.gets(@_sentence)                    ' read sentence data (ASCII)


PUB setup()

    ser.start(SER_BAUD)
    time.msleep(30)
    ser.clear()
    ser.strln(@"Serial terminal started")
    gps.startrxtx(GPS_TXD, GPS_RXD, %0000, GPS_BAUD)
    ser.strln(@"GPS serial started")


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

