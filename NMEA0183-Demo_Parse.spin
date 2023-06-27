{
    --------------------------------------------
    Filename: NMEA0183-Demo_Parse.spin
    Author: Jesse Burt
    Description: Demo of the NMEA0183 library
        * Parsed sentence output
        * Logged raw sentences
    Copyright (c) 2023
    Started Sep 8, 2019
    Updated Jun 27, 2023
    See end of file for terms of use.
    --------------------------------------------
}

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

' -- User-defined constants
    SER_BAUD    = 115_200

    GPS_TXD     = 8
    GPS_RXD     = 9
    GPS_BAUD    = 9600
' --

OBJ

    cfg:    "boardcfg.flip"
    ser:    "com.serial.terminal.ansi"
    time:   "time"
    nmea:   "protocol.navigation.nmea0183"
    gps:    "com.serial.terminal"

PUB main() | x, y

    setup()

    x := 0
    y := 3
    ser.text_win(@"Sentence log", x, y, LOG_W, LOG_H, ser.GREY, ser.BLACK, ser.WHITE)

    repeat
        read_sentence()
        ifnot ( nmea.sentence_good() )
            next

        { display the GPS sentences in a scrolled window }
        msg_scroll_up(@_sentence, x, y)

        ser.printf4(@"\n\r\n\rTotal received\tGGA: %5d GSA: %5d RMC: %5d VTG: %5d\n\r", ...
                    nmea._total_gga, ...
                    nmea._total_gsa, ...
                    nmea._total_rmc, ...
                    nmea._total_vtg )
        ser.printf1(@"Bad checksum: %5d\n\r", nmea._total_bad)

        { parse each sentence }
        case nmea.sentence_id()
            nmea#SNTID_GGA:
                nmea.parse_gga()
            nmea#SNTID_GSA:
                nmea.parse_gsa()
            nmea#SNTID_GSV:
            nmea#SNTID_RMC:
                nmea.parse_rmc()
            nmea#SNTID_VTG:
                nmea.parse_vtg()

        { display the parsed data }
        ser.pos_xy(0, y+10)
        ser.printf4(@"Latitude: %02.2d\302\260 %02.2d.%04.4dmin %c\n\r", ...
                    nmea.lat_deg(), ...
                    nmea.lat_minutes_whole(), ...
                    nmea.lat_minutes_part(), ...
                    nmea.north_south() )

        ser.printf4(@"Longitude: %02.2d\302\260 %02.2d.%04.4dmin %c\n\r", ...
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

        ser.printf2(@"HDOP: %2.2d.%02.2d\n\r", (nmea.hdop() / 100), (nmea.hdop() // 100) )
        ser.printf2(@"PDOP: %2.2d.%02.2d\n\r", (nmea.pdop() / 100), (nmea.pdop() // 100) )
        ser.printf2(@"VDOP: %2.2d.%02.2d\n\r", (nmea.vdop() / 100), (nmea.vdop() // 100) )

        ser.printf3(@"Date: %02.2d/%02.2d/%02.2d\n\r",  nmea.month(), ...
                                                        nmea.date(), ...
                                                        nmea.year() )

        ser.printf3(@"Time: %02.2d:%02.2d:%02.2d\n\r",  nmea.hours(), ...
                                                        nmea.minutes(), ...
                                                        nmea.seconds() )

        ser.printf2(@"Course (true): %03.3d.%02.2d\302\260\n\r", ...
                    (nmea.course_true() / 100), ...
                    (nmea.course_true() // 100) )

        ser.printf1(@"Course (magnetic): %d\302\260    \n\r", nmea.course_magnetic() )

        ser.printf2(@"Speed: %d.%02.2dkts\n\r", (nmea.speed_kts() / 100), ...
                                                (nmea.speed_kts // 100) )

        ser.printf1(@"Speed: %dkm/h    \n\r", nmea.speed_kmh() )

CON

    WIDTH       = 104                           ' terminal width
    HEIGHT      = 44                            ' height
    LINEWIDTH   = 90                            ' window (inner) width
    LINES       = 5                             ' height

    LASTLINE    = LINES-1
    BTM         = LINEWIDTH*LASTLINE
    SCRLBYTES   = BTM-1
    LOGBUFFSZ   = LINEWIDTH * LINES

    LOG_W       = LINEWIDTH+2
    LOG_H       = LINES+2

    TOP         = 0
    LINE1       = TOP+LINEWIDTH
    LINE2       = LINE1+LINEWIDTH
    LINE3       = LINE2+LINEWIDTH

VAR byte _logbuff[LOGBUFFSZ], _msg[LINEWIDTH]

PUB msg_scroll_up(ptr_msg, x, y) | ln, ins_left, ins_top
' Scroll a message buffer up one line and add new message to the bottom row
    ins_left := x+1
    ins_top := y+1

    ' scroll lines from bottom line up
    bytemove(@_logbuff[TOP], @_logbuff[LINE1], SCRLBYTES)
    ' move the new message into the bottom line
    bytemove(@_logbuff[BTM], ptr_msg, LINEWIDTH)
    ' now display them
    repeat ln from 0 to LASTLINE
        ser.pos_xy(ins_left, ins_top+ln)
        ser.puts(@_logbuff[LINEWIDTH*ln])

VAR byte _sentence[nmea.SENTENCE_MAX_LEN]
PUB read_sentence()

    repeat until ( gps.getchar() == nmea#SENTSTART )
    gps.gets(@_sentence)                    ' read sentence data (ASCII)

PUB setup()

    ser.start(SER_BAUD)
    time.msleep(30)
    ser.clear()
    ser.strln(@"Serial terminal started")

    if ( gps.init(GPS_TXD, GPS_RXD, 0, GPS_BAUD) )
        ser.strln(@"PA1010D driver started (UART)")
    else
        ser.strln(@"PA1010D driver failed to start - halting")
        repeat

    { point the nmea0183 object to the location of the sentence }
    nmea.ptr_sentence( @_sentence )

DAT
{
Copyright 2023 Jesse Burt

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

