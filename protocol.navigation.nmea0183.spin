{
    --------------------------------------------
    Filename: protocol.navigation.nmea0183.spin
    Author: Jesse Burt
    Description: Library of functions for parsing
        NMEA-0183 sentences
    Copyright (c) 2019
    Started Sep 7, 2019
    Updated Sep 8, 2019
    See end of file for terms of use.
    --------------------------------------------
}

CON

    SENTENCE_MAX_LEN    = 81

' NMEA-0183 Sentence ID types
    SENTENCE_ID_GGA     = 1
    SENTENCE_ID_GSA     = 2
    SENTENCE_ID_GSV     = 3
    SENTENCE_ID_RMC     = 4
    SENTENCE_ID_VTG     = 5

OBJ

    int     : "string.integer"

VAR

PUB Checksum(msg_ptr) | idx, tmp
' Extract Checksum from a sentence
'   Returns: Checksum contained in sentence at msg_ptr
    idx := 0
    repeat while byte[msg_ptr][++idx] <> "*"
    tmp.byte[0] := byte[msg_ptr][++idx]
    tmp.byte[1] := byte[msg_ptr][++idx]
    tmp.word[1] := $0000

    result := int.StrToBase (@tmp, 16)

PUB Latitude(msg_ptr) | idx, tmp[3]
' Extract latitude from a sentence
'   Returns: Latitude in degrees and minutes packed into long
'   Example:
'       40056475
'        | |   |
'        | |   Minutes (part)
'        | Minutes (whole)
'        Degrees
'       -----------------------
'       40 deg, 05.6475 minutes
    repeat idx from 17 to 20
        tmp.byte[idx-17] := byte[msg_ptr][idx]
    repeat idx from 22 to 25
        tmp.byte[idx-17] := byte[msg_ptr][idx]

    return int.StrToBase (@tmp, 10)

PUB Longitude(msg_ptr) | idx, tmp[3]
' Extract latitude from a sentence
'   Returns: Latitude in degrees and minutes packed into long
'   Example:
'       074114014
'         | |   |
'         | |   Minutes (part)
'         | Minutes (whole)
'         Degrees
'       -----------------------
'       074 deg, 11.4014 minutes
    repeat idx from 29 to 33
        tmp.byte[idx-29] := byte[msg_ptr][idx]
    repeat idx from 35 to 38
        tmp.byte[idx-30] := byte[msg_ptr][idx]

    return int.StrToBase (@tmp, 10)

PUB SentenceID(msg_ptr) | idx, tmp
' Extract Sentence ID from a sentence
'   Returns: Integer corresponding to ID found in lookdown table if found, or 0 if no match
    tmp := $00_00_00_00
    repeat idx from 2 to 4
        tmp.byte[idx-2] := byte[msg_ptr][idx]
    tmp.byte[3] := 0

    if strcomp(@tmp, string("GGA"))
        result := SENTENCE_ID_GGA
    elseif strcomp(@tmp, string("GSA"))
        result := SENTENCE_ID_GSA
    elseif strcomp(@tmp, string("GSV"))
        result := SENTENCE_ID_GSV
    elseif strcomp(@tmp, string("RMC"))
        result := SENTENCE_ID_RMC
    elseif strcomp(@tmp, string("VTG"))
        result := SENTENCE_ID_VTG
    else
        result := FALSE

PUB TalkerID(msg_ptr)
' Extract Talker ID from a sentence
'   Returns: Integer corresponding to ID found in lookdown table if found, or 0 if no match
    return lookdown(byte[msg_ptr][1]: "L", "N", "P")

PUB Verify(msg_ptr) | idx
' Calculate checksum of a sentence
'   Returns: Calculated 8-bit checksum of sentence
    result := idx := 0

    repeat
        result ^= byte[msg_ptr][idx]
    while byte[msg_ptr][++idx] <> "*"

    return result & $FF


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
