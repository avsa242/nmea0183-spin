{
    --------------------------------------------
    Filename: protocol.navigation.nmea0183.spin
    Author: Jesse Burt
    Description: Library of functions for parsing
        NMEA-0183 sentences
    Copyright (c) 2021
    Started Sep 7, 2019
    Updated Mar 24, 2021
    See end of file for terms of use.
    --------------------------------------------
}

CON

    SENTNC_MAX_LEN  = 81

' NMEA-0183 Sentence ID types
    SNTID_VTG       = $475456
    SNTID_GGA       = $414747
    SNTID_GSA       = $415347
    SNTID_RMC       = $434D52
    SNTID_GSV       = $565347

' Datum indices (byte offsets from sentence start)
    TID_ST          = 0
    TID_END         = 1
    SID_ST          = 2
    SID_END         = 4
    TIME_ST         = 6
    TIME_END        = 11
    GGA_LATDEG_ST   = 17
    GGA_LATDEG_END  = 20
    GGA_LATMINP_ST  = 22
    GGA_LATMINP_END = 25
    GGA_LONGDEG_ST  = 29
    GGA_LONGDEG_END = 33
    GGA_LONGMINP_ST = 35
    GGA_LONGMINP_END= 38

' GGA field indices

    GGA_TALKID      = 0
    GGA_ZTIME       = 1
    GGA_LAT         = 2
    GGA_NS          = 3
    GGA_LON         = 4
    GGA_EW          = 5
    GGA_GPSQUAL     = 6
    GGA_SATSUSED    = 7
    GGA_HDOP        = 8
    GGA_ALT         = 9
    GGA_ALTUNITS    = 10
    GGA_GEOID_SEP   = 11
    GGA_GEOID_UNITS = 12
    GGA_DIFFCORR_AGE= 13
    GGA_DGPS_SID    = 14
    GGA_CHKSUM      = 15

' RMC field indices
    RMC_TALKID      = 0
    RMC_ZTIME       = 1
    RMC_STATUS      = 2
    RMC_LAT         = 3
    RMC_NS          = 4
    RMC_LONG        = 5
    RMC_EW          = 6
    RMC_SOG         = 7
    RMC_COG         = 8
    RMC_ZDATE       = 9
    RMC_MAGVAR      = 10
    RMC_MAGVAR_EW   = 11
    RMC_MODE        = 12
    RMC_CHKSUM      = 13

    RMC_LATDEG_ST   = 19
    RMC_LATDEG_END  = 21
    RMC_LATMINP_ST  = 24
    RMC_LATMINP_END = 27
    RMC_LONGDEG_ST  = 31
    RMC_LONGDEG_END = 35
    RMC_LONGMINP_ST = 37
    RMC_LONGMINP_END= 40

    CRCMARKER       = "*"

OBJ

    int : "string.integer"
    str : "string"

VAR

    long _ptr_sntnc

PUB Checksum{}: rd_ck | idx, tmp
' Extract Checksum from a sentence
'   Returns: Checksum contained in sentence at _ptr_sntnc
    idx := 0
    repeat until byte[_ptr_sntnc][++idx] == CRCMARKER
    tmp.byte[0] := byte[_ptr_sntnc][++idx]
    tmp.byte[1] := byte[_ptr_sntnc][++idx]
    tmp.word[1] := 0

    return int.strtobase(@tmp, 16)

PUB GenChecksum{}: cks_valid | idx
' Calculate checksum of a sentence
'   Returns: Calculated 8-bit checksum of sentence
    cks_valid := idx := 0

    repeat
        cks_valid ^= byte[_ptr_sntnc][idx]
    while byte[_ptr_sntnc][++idx] <> "*"

    return cks_valid & $FF

PUB Hours{}: h
' Return: last read hours (u8)
    return (timeofday{} / 10_000)

PUB Latitude{}: lat | idx, outidx, tmp[3], deg_st, deg_end, min_st, min_end
' Extract latitude from a sentence
'   Returns: Latitude in degrees and minutes packed into long
'   Example:
'       40 05 6475
'        |  |    |
'        |  |    Minutes (part)
'        |  Minutes (whole)
'        Degrees
'       -----------------------
'       40 deg, 05.6475 minutes
    outidx := 0
    case sentenceid
        SNTID_GGA:
            deg_st := GGA_LATDEG_ST
            deg_end := GGA_LATDEG_END
            min_st := GGA_LATMINP_ST
            min_end := GGA_LATMINP_END
        SNTID_RMC:
            deg_st := RMC_LATDEG_ST
            deg_end := RMC_LATDEG_END
            min_st := RMC_LATMINP_ST
            min_end := RMC_LATMINP_END

    repeat idx from deg_st to deg_end
        tmp.byte[outidx++] := byte[_ptr_sntnc][idx]
    repeat idx from min_st to min_end
        tmp.byte[outidx++] := byte[_ptr_sntnc][idx]

    return int.strtobase(@tmp, 10)

PUB Longitude{}: lon | idx, outidx, tmp[3], deg_st, deg_end, min_st, min_end
' Extract longitude from a sentence
'   Returns: Longitude in degrees and minutes packed into long
'   Example:
'       074 11 4014
'         |  |    |
'         |  |    Minutes (part)
'         |  Minutes (whole)
'         Degrees
'       -----------------------
'       074 deg, 11.4014 minutes
    outidx := 0
    case sentenceid
        SNTID_GGA:
            deg_st := GGA_LONGDEG_ST
            deg_end := GGA_LONGDEG_END
            min_st := GGA_LONGMINP_ST
            min_end := GGA_LONGMINP_END
        SNTID_RMC:
            deg_st := RMC_LONGDEG_ST
            deg_end := RMC_LONGDEG_END
            min_st := RMC_LONGMINP_ST
            min_end := RMC_LONGMINP_END

    repeat idx from deg_st to deg_end
        tmp.byte[outidx++] := byte[_ptr_sntnc][idx]
    repeat idx from min_st to min_end
        tmp.byte[outidx++] := byte[_ptr_sntnc][idx]

    return int.strtobase(@tmp, 10)

PUB Minutes{}: m
' Return last read minutes (u8)
    return ((timeofday{} // 10_000) / 100)

PUB Seconds{}: s
' Return last read seconds (u8)
    return (timeofday{} // 100)

PUB SentencePtr(ptr_sntnc)
' Set pointer to NMEA0183 sentence data
    case ptr_sntnc
        $0004..$7fae:
            _ptr_sntnc := ptr_sntnc
        other:
            return _ptr_sntnc

PUB SentenceID{}: sid | idx
' Extract Sentence ID from a sentence
'   Returns: 3-byte sentence ID (ASCII)
    repeat idx from SID_ST to SID_END
        sid.byte[idx-SID_ST] := byte[_ptr_sntnc][idx]

PUB TalkerID{}: tid
' Extract Talker ID from a sentence
'   Returns:
'       2-byte talker ID (ASCII)
    return word[_ptr_sntnc][TID_ST]

PUB TimeOfDay{}: tod | idx, ztime, tmp[2]
' Extract time of day from a sentence
'   Returns: Time, in hours, minutes, seconds packed into long
'   Example:
'       23 16 50
'        |  |  |
'        |  | Seconds
'        |  Minutes
'        Hours (Zulu)
'       -----------------------
'       23h, 16m, 50s (23:16:50)
    ' GGA and RMC sentences both provide UTC/Zulu time in the same field
    ztime := str.getfield(_ptr_sntnc, RMC_ZTIME, ",")
    str.left(@tmp, ztime, 6)
    return int.strtobase(@tmp, 10)              ' conv. string to long

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
