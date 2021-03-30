{
    --------------------------------------------
    Filename: protocol.navigation.nmea0183.spin
    Author: Jesse Burt
    Description: Library of functions for parsing
        NMEA-0183 sentences
    Copyright (c) 2021
    Started Sep 7, 2019
    Updated Mar 30, 2021
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

' GGA field indices

    GGA_TALKID      = 0
    GGA_ZTIME       = 1
    GGA_LAT         = 2
    GGA_NS          = 3
    GGA_LONG        = 4
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
    RMC_COGT        = 8
    RMC_ZDATE       = 9
    RMC_MAGVAR      = 10
    RMC_MAGVAR_EW   = 11
    RMC_MODE        = 12
    RMC_CHKSUM      = 13

' VTG field indices
    VTG_TALKID      = 0
    VTG_COGT        = 1
    VTG_REFT        = 2
    VTG_COGM        = 3
    VTG_REFM        = 4
    VTG_SPD_KTS     = 5
    VTG_SPDUNITKTS  = 6
    VTG_SPD_KMH     = 7
    VTG_SPDUNITKMH  = 8
    VTG_MODE        = 9
    VTG_CHKSUM      = 10

' GSA field indices
    GSA_TALKID      = 0
    GSA_MODE1       = 1
    GSA_MODE2       = 2
    GSA_SATCHAN1    = 3
    GSA_SATCHAN2    = 4
    GSA_SATCHAN3    = 5
    GSA_SATCHAN4    = 6
    GSA_SATCHAN5    = 7
    GSA_SATCHAN6    = 8
    GSA_SATCHAN7    = 9
    GSA_SATCHAN8    = 10
    GSA_SATCHAN9    = 11
    GSA_SATCHAN10   = 12
    GSA_SATCHAN11   = 13
    GSA_SATCHAN12   = 14
    GSA_PDOP        = 15
    GSA_HDOP        = 16
    GSA_VDOP        = 17


    CRCMARKER       = "*"

    DEC             = 10
    HEX             = 16

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

    return int.strtobase(@tmp, HEX)

PUB CourseMagnetic{}: c
' Course over ground (magnetic)
'   Returns: hundredths of a degree
    if sentenceid{} == SNTID_VTG
        c := str.getfield(_ptr_sntnc, VTG_COGM, ",")
        str.stripchar(c, ".")
        return int.strtobase(c, DEC)

PUB CourseTrue{}: c
' Course over ground (true)
'   Returns: hundredths of a degree
    case sentenceid{}
        SNTID_VTG:
            c := str.getfield(_ptr_sntnc, VTG_COGT, ",")
            str.stripchar(c, ".")
            return int.strtobase(c, DEC)
        SNTID_RMC:
            c := str.getfield(_ptr_sntnc, RMC_COGT, ",")
            str.stripchar(c, ".")
            return int.strtobase(c, DEC)

PUB Date{}: d | tmp
' Get current date/day of month
    if sentenceid{} == SNTID_RMC
        tmp := str.getfield(_ptr_sntnc, RMC_ZDATE, ",")
        str.left(@d, tmp, 2)
        return int.strtobase(@d, DEC)

PUB EastWest{}: ew | tmp
' Indicates East/West of Prime Meridian
'   Returns: E or W (ASCII)
    case sentenceid{}
        SNTID_GGA:
            tmp := str.getfield(_ptr_sntnc, GGA_EW, ",")
        SNTID_RMC:
            tmp := str.getfield(_ptr_sntnc, RMC_EW, ",")

    str.copy(@ew, tmp)

PUB Fix{}: f
' Indicates position fix
'   Returns:
'       1 - no fix
'       2 - 2D fix
'       3 - 3D fix
    if sentenceid{} == SNTID_GSA
        f := str.getfield(_ptr_sntnc, GSA_MODE2, ",")
        return int.strtobase(f, DEC)

PUB FullDate{}: d
' Full date (day, month, year)
'   Returns: integer (ddmmyy)
    if sentenceid{} == SNTID_RMC
        d := str.getfield(_ptr_sntnc, RMC_ZDATE, ",")
        return int.strtobase(d, DEC)

PUB GenChecksum{}: cksum | idx
' Calculate checksum of a sentence
'   Returns: Calculated 8-bit checksum of sentence
    cksum := idx := 0

    repeat
        cksum ^= byte[_ptr_sntnc][idx]
    while byte[_ptr_sntnc][++idx] <> CRCMARKER

    return cksum & $FF

PUB HDOP{}: h | tmp
' Horizontal dilution of precision
'   Returns: DOP (hundredths)
    if sentenceid{} == SNTID_GSA
        tmp := str.getfield(_ptr_sntnc, GSA_HDOP, ",")
        str.stripchar(tmp, ".")
        return int.strtobase(tmp, DEC)

PUB Hours{}: h
' Return: last read hours (u8)
    return (timeofday{} / 10_000)

PUB Latitude{}: lat | tmp
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
    case sentenceid
        SNTID_GGA:
            tmp := str.getfield(_ptr_sntnc, GGA_LAT, ",")
            str.stripchar(tmp, ".")
        SNTID_RMC:
            tmp := str.getfield(_ptr_sntnc, RMC_LAT, ",")
            str.stripchar(tmp, ".")
    return int.strtobase(tmp, DEC)

PUB Longitude{}: lon | tmp
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
    case sentenceid
        SNTID_GGA:
            tmp := str.getfield(_ptr_sntnc, GGA_LONG, ",")
            str.stripchar(tmp, ".")
        SNTID_RMC:
            tmp := str.getfield(_ptr_sntnc, RMC_LONG, ",")
            str.stripchar(tmp, ".")
    return int.strtobase(tmp, DEC)

PUB Minutes{}: m
' Return last read minutes (u8)
    return ((timeofday{} // 10_000) / 100)

PUB Month{}: m | tmp
' Get current month
    if sentenceid{} == SNTID_RMC
        tmp := str.getfield(_ptr_sntnc, RMC_ZDATE, ",")
        str.mid(@m, tmp, 2, 2)
        return int.strtobase(@m, DEC)

PUB NorthSouth{}: ns | tmp
' Indicates North/South of equator
'   Returns: N/S (ASCII)
    case sentenceid{}
        SNTID_GGA:
            tmp := str.getfield(_ptr_sntnc, GGA_NS, ",")
        SNTID_RMC:
            tmp := str.getfield(_ptr_sntnc, RMC_NS, ",")
    str.copy(@ns, tmp)

PUB PDOP{}: p | tmp
' Position dilution of precision
'   Returns: DOP (hundredths)
    if sentenceid{} == SNTID_GSA
        tmp := str.getfield(_ptr_sntnc, GSA_PDOP, ",")
        str.stripchar(tmp, ".")
        return int.strtobase(tmp, DEC)

PUB Seconds{}: s
' Return last read seconds (u8)
    return (timeofday{} // 100)

PUB SentencePtr(ptr_sntnc)
' Set pointer to NMEA0183 sentence data
'   Valid values: $0004..$7fae
'   Any other value returns the current setting
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

PUB SpeedKnots{}: spd
' Speed over ground, in hundredths of a knot
'   (e.g., 361 == 3.61kts)
    case sentenceid{}
        SNTID_VTG:
            spd := str.getfield(_ptr_sntnc, VTG_SPD_KTS, ",")
            str.stripchar(spd, ".")
            return int.strtobase(spd, DEC)
        SNTID_RMC:
            spd := str.getfield(_ptr_sntnc, RMC_SOG, ",")
            str.stripchar(spd, ".")
            return int.strtobase(spd, DEC)

PUB SpeedKmh{}: spd
' Speed over ground, in hundredths of a knot
'   (e.g., 361 == 3.61kts)
    if sentenceid{} == SNTID_VTG
        spd := str.getfield(_ptr_sntnc, VTG_SPD_KMH, ",")
        str.stripchar(spd, ".")
        return int.strtobase(spd, DEC)

PUB TalkerID{}: tid
' Extract Talker ID from a sentence
'   Returns:
'       2-byte talker ID (ASCII)
    return word[_ptr_sntnc][TID_ST]

PUB TimeOfDay{}: tod | ztime, tmp[2]
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
    return int.strtobase(@tmp, DEC)             ' conv. string to long

PUB VDOP{}: v | tmp
' Vertical dilution of precision
'   Returns: DOP (hundredths)
    if sentenceid{} == SNTID_GSA
        tmp := str.getfield(_ptr_sntnc, GSA_VDOP, ",")
        str.stripchar(tmp, ".")
        return int.strtobase(tmp, DEC)

PUB Year{}: y | tmp
' Get current year
    if sentenceid{} == SNTID_RMC
        tmp := str.getfield(_ptr_sntnc, RMC_ZDATE, ",")
        str.right(@y, tmp, 2)
        return int.strtobase(@y, DEC)

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
