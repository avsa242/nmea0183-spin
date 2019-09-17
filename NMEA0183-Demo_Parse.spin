{
    --------------------------------------------
    Filename: NMEA0183-Demo_Parse.spin
    Author: Jesse Burt
    Description: Simple demo that uses the NMEA0183 object
        to parse sentences read from a compatible 9600bps-connected
        GPS module and displays the data on the terminal.

    Copyright (c) 2019
    Started Sep 8, 2019
    Updated Sep 8, 2019
    See end of file for terms of use.
    --------------------------------------------
}

CON

    _clkmode            = cfg#_clkmode
    _xinfreq            = cfg#_xinfreq

    SENTENCE_MAX_LEN    = 81

OBJ

    cfg     : "core.con.boardcfg.flip"
    ser     : "com.serial.terminal"
    gps     : "com.serial.terminal"
    time    : "time"
    nmea    : "protocol.navigation.nmea0183"

VAR

    byte _gps_cog, _ser_cog
    byte _sentence[SENTENCE_MAX_LEN]

PUB Main | gps_rx, idx, msg_count

    Setup
    ser.Clear
    msg_count := 0

    repeat
        idx := 0
        if msg_count > 10
            msg_count := 0
            ser.Clear
        repeat until gps.CharIn == "$"
        repeat
            gps_rx := gps.CharIn
            _sentence[idx++] := gps_rx
        until gps_rx == ser#NL
        idx := 0

        ser.Str (string("Sentence: "))
        repeat
            ser.Char (_sentence[idx])
        until _sentence[++idx] == 13
        ser.NewLine

        ser.Str (string("Talker ID: "))
        ser.Dec (nmea.TalkerID (@_sentence))
        ser.NewLine

        ser.Str (string("Sentence ID: "))
        ser.Dec (nmea.SentenceID (@_sentence))
        ser.NewLine

        ser.Str (string("Checksum: "))
        ser.Hex (nmea.Checksum (@_sentence), 2)
        if nmea.Checksum (@_sentence) == nmea.Verify (@_sentence)
            ser.Str (string(" (GOOD)", ser#NL))
        else
            ser.Str (string(" (BAD - got ", ser#NL))
            ser.Hex (nmea.Verify (@_sentence), 2)
            ser.Str (string(")", ser#NL))

        ser.NewLine

        bytefill(@_sentence, $00, SENTENCE_MAX_LEN)
        msg_count++

PUB Setup

    repeat until _ser_cog := ser.Start (115_200)
    ser.Clear
    ser.Str(string("Serial terminal started", ser#NL))
    repeat until _gps_cog := gps.StartRxTx (8, 9, %0000, 9600)
    gps.Str(string("GPS serial started", ser#NL))

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
