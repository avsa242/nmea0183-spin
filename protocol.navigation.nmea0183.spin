{
    --------------------------------------------
    Filename: protocol.navigation.nmea0183.spin
    Author: Jesse Burt
    Description: Library of functions for parsing
        NMEA-0183 sentences
    Copyright (c) 2022
    Started Sep 7, 2019
    Updated Nov 26, 2022
    See end of file for terms of use.
    --------------------------------------------
}

CON

' Sentence max length, plus one byte for a 0/NUL string terminator
    SENTNC_MAX_LEN  = 83

' NMEA-0183 Sentence ID types
    SNTID_VTG       = $475456
    SNTID_GGA       = $414747
    SNTID_GSA       = $415347
    SNTID_RMC       = $434D52
    SNTID_GSV       = $565347

    { AIS }
    SNTID_VDM       = $4D4456
    SNTID_VDO       = $4F4456

' Talker ID, Sentence ID positions
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


    SENTSTART       = "$"
    AIS_START       = "!"
    CRCMARKER       = "*"

    DEC             = 10
    HEX             = 16

OBJ

    str : "string"

VAR

    long _ptr_sntnc

PUB ais_channel{}: c
' AIS channel
    bytemove(@c, str.getfield(_ptr_sntnc, 4, ","), 1)

PUB ais_fillbits{}: f
' Number of message fill bits
    return str.atoi(str.getfield(_ptr_sntnc, 6, ","))

PUB ais_message{}: m
' Encapsulated message (ITU-R M.1371)
    return str.getfield(_ptr_sntnc, 5, ",")

PUB ais_msg_len{}: c
' Total number of AIS sentences needed to transfer the message
    return str.atoi(str.getfield(_ptr_sntnc, 1, ","))

PUB ais_seq_msg_id{}: s
' AIS sequential message identifier (0..9)
    return str.getfield(_ptr_sntnc, 3, ",")

PUB ais_sentence_nr{}: s
' AIS sentence number (1..9)
    return str.atoi(str.getfield(_ptr_sntnc, 2, ","))

PUB checksum{}: rd_ck | idx, tmp
' Extract Checksum from a sentence
'   Returns: Checksum contained in sentence at _ptr_sntnc
    idx := 0
    repeat until byte[_ptr_sntnc][++idx] == CRCMARKER
    tmp.byte[0] := byte[_ptr_sntnc][++idx]
    tmp.byte[1] := byte[_ptr_sntnc][++idx]
    tmp.word[1] := 0

    return str.atoib(@tmp, str#IHEX)

PUB course_magnetic{}: c
' Course over ground (magnetic)
'   Returns: hundredths of a degree
    if (sentence_id{} == SNTID_VTG)
        c := str.getfield(_ptr_sntnc, VTG_COGM, ",")
        str.stripchar(c, ".")
        return str.atoi(c)

PUB course_true{}: c
' Course over ground (true)
'   Returns: hundredths of a degree
    case sentence_id{}
        SNTID_VTG:
            c := str.getfield(_ptr_sntnc, VTG_COGT, ",")
            str.stripchar(c, ".")
            return str.atoi(c)
        SNTID_RMC:
            c := str.getfield(_ptr_sntnc, RMC_COGT, ",")
            str.stripchar(c, ".")
            return str.atoi(c)

PUB date{}: d
' Get current date/day of month
    return ((full_date{} // 10_000) / 100)

PUB east_west{}: ew | tmp
' Indicates East/West of Prime Meridian
'   Returns: E or W (ASCII)
    case sentence_id{}
        SNTID_GGA:
            tmp := str.getfield(_ptr_sntnc, GGA_EW, ",")
        SNTID_RMC:
            tmp := str.getfield(_ptr_sntnc, RMC_EW, ",")

    str.copy(@ew, tmp)

PUB fix{}: f
' Indicates position fix
'   Returns:
'       1 - no fix
'       2 - 2D fix
'       3 - 3D fix
    if (sentence_id{} == SNTID_GSA)
        return str.atoi(str.getfield(_ptr_sntnc, GSA_MODE2, ","))

PUB full_date{}: d
' Full date (day, month, year)
'   Returns: integer (ddmmyy)
    if (sentence_id{} == SNTID_RMC)
        return str.atoi(str.getfield(_ptr_sntnc, RMC_ZDATE, ","))

PUB gen_checksum{}: cksum | idx
' Calculate checksum of a sentence
'   Returns: Calculated 8-bit checksum of sentence
    cksum := idx := 0

    repeat
        cksum ^= byte[_ptr_sntnc][idx]
    while byte[_ptr_sntnc][++idx] <> CRCMARKER

    return (cksum & $FF)

PUB hdop{}: h | tmp
' Horizontal dilution of precision
'   Returns: DOP (hundredths)
    if (sentence_id{} == SNTID_GSA)
        tmp := str.getfield(_ptr_sntnc, GSA_HDOP, ",")
        str.stripchar(tmp, ".")
        return str.atoi(tmp)

PUB hours{}: h
' Return: last read hours (u8)
    return (time_of_day{} / 10_000)

PUB latitude{}: lat | tmp
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
    case sentence_id
        SNTID_GGA:
            tmp := str.getfield(_ptr_sntnc, GGA_LAT, ",")
            str.stripchar(tmp, ".")
        SNTID_RMC:
            tmp := str.getfield(_ptr_sntnc, RMC_LAT, ",")
            str.stripchar(tmp, ".")
    return str.atoi(tmp)

PUB lat_deg{}: d
' Extract degrees from latitude
    return (latitude{} / 1_000_000)

PUB lat_minutes{}: m
' Extract minutes (whole and part) from latitude
    return (latitude{} // 1_000_000)

PUB lat_minutes_part{}: m
' Extract minutes (part) from latitude
    return (lat_minutes{} // 10_000)

PUB lat_minutes_whole{}: m
' Extract minutes (whole) from latitude
    return (lat_minutes{} / 10_000)

PUB longitude{}: lon | tmp
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
    case sentence_id
        SNTID_GGA:
            tmp := str.getfield(_ptr_sntnc, GGA_LONG, ",")
            str.stripchar(tmp, ".")
        SNTID_RMC:
            tmp := str.getfield(_ptr_sntnc, RMC_LONG, ",")
            str.stripchar(tmp, ".")
    return str.atoi(tmp)

PUB long_deg{}: d
' Extract degrees from longitude
    return (longitude{} / 1_000_000)

PUB long_minutes{}: m
' Extract minutes (whole and part) from longitude
    return (longitude{} // 1_000_000)

PUB long_minutes_part{}: m
' Extract minutes (part) from longitude
    return (long_minutes{} // 10_000)

PUB long_minutes_whole{}: m
' Extract minutes (whole) from longitude
    return (long_minutes{} / 10_000)

PUB minutes{}: m
' Return last read minutes (u8)
    return ((time_of_day{} // 10_000) / 100)

PUB month{}: m
' Get current month
    return (full_date{} / 10_000)

PUB north_south{}: ns | tmp
' Indicates North/South of equator
'   Returns: N/S (ASCII)
    case sentence_id{}
        SNTID_GGA:
            tmp := str.getfield(_ptr_sntnc, GGA_NS, ",")
        SNTID_RMC:
            tmp := str.getfield(_ptr_sntnc, RMC_NS, ",")
    str.copy(@ns, tmp)

PUB pdop{}: p | tmp
' Position dilution of precision
'   Returns: DOP (hundredths)
    if (sentence_id{} == SNTID_GSA)
        tmp := str.getfield(_ptr_sntnc, GSA_PDOP, ",")
        str.stripchar(tmp, ".")
        return str.atoi(tmp)

PUB ptr_sentence(ptr_sntnc)
' Set pointer to NMEA0183 sentence data
'   Valid values: $0004..$7fae
'   Any other value returns the current setting
    case ptr_sntnc
        $0004..$7fae:
            _ptr_sntnc := ptr_sntnc
        other:
            return _ptr_sntnc

PUB seconds{}: s
' Return last read seconds (u8)
    return (time_of_day{} // 100)

PUB sentence_id{}: sid | idx
' Extract Sentence ID from a sentence
'   Returns: 3-byte sentence ID (ASCII)
    repeat idx from SID_ST to SID_END
        sid.byte[idx-SID_ST] := byte[_ptr_sntnc][idx]

PUB speed_kts{}: spd
' Speed over ground, in hundredths of a knot
'   (e.g., 361 == 3.61kts)
    case sentence_id{}
        SNTID_VTG:
            spd := str.getfield(_ptr_sntnc, VTG_SPD_KTS, ",")
            str.stripchar(spd, ".")
            return str.atoi(spd)
        SNTID_RMC:
            spd := str.getfield(_ptr_sntnc, RMC_SOG, ",")
            str.stripchar(spd, ".")
            return str.atoi(spd)

PUB speed_kmh{}: spd
' Speed over ground, in hundredths of a kmh
'   (e.g., 361 == 3.61kts)
    if (sentence_id{} == SNTID_VTG)
        spd := str.getfield(_ptr_sntnc, VTG_SPD_KMH, ",")
        str.stripchar(spd, ".")
        return str.atoi(spd)

PUB talker_id{}: tid
' Extract Talker ID from a sentence
'   Returns:
'       2-byte talker ID (ASCII)
    return word[_ptr_sntnc][TID_ST]

PUB time_of_day{}: tod | tmp
' Extract time of day (UTC/Zulu) from a sentence
'   Returns: Time, in hours, minutes, seconds packed into long
'   Example:
'       23 16 50
'        |  |  |
'        |  | Seconds
'        |  Minutes
'        Hours (Zulu)
'       -----------------------
'       23h, 16m, 50s (23:16:50)
' NOTE: This method returns valid data for both GGA and RMC sentence types
    tmp := str.getfield(_ptr_sntnc, RMC_ZTIME, ",")
    return str.atoi(tmp)

PUB vdop{}: v | tmp, tmp2[4]
' Vertical dilution of precision
'   Returns: DOP (hundredths)
    bytefill(@tmp, 0, 5)
    if (sentence_id{} == SNTID_GSA)
        tmp := str.getfield(_ptr_sntnc, GSA_VDOP, ",")
        bytemove(@tmp2, tmp, strsize(tmp))      ' XXX temp hack to fix mem
        tmp2 := str.getfield(@tmp2, 0, "*")      '   corruption
        str.stripchar(tmp2, ".")
        return str.atoi(tmp2)

PUB year{}: y
' Get current year
    return (full_date{} // 100)

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

