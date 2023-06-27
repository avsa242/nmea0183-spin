{
    --------------------------------------------
    Filename: protocol.navigation.nmea0183.spin
    Author: Jesse Burt
    Description: Library of functions for parsing
        NMEA-0183 sentences
    Copyright (c) 2023
    Started Sep 7, 2019
    Updated Jun 27, 2023
    See end of file for terms of use.
    --------------------------------------------
}

CON

' Sentence max length, plus one byte for a 0/NUL string terminator
    SENTENCE_MAX_LEN= 83

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

OBJ

    str:    "string"

VAR

    long _ptr_sentence

    { position, course, speed }
    long _course_mag, _course_true
    long _east_west, _north_south
    long _vdop, _hdop, _pdop
    long _latitude, _lat_degs, _lat_mins, _lat_mins_w, _lat_mins_p
    long _longitude, _long_degs, _long_mins, _long_mins_w, _long_mins_p
    long _speed_kts, _speed_kmh

    { date, time }
    long _date
    long _ztime

    { count of messages received }
    long _total_gga, _total_gsa, _total_gsv, _total_rmc, _total_vtg
    long _total_bad

    byte _fix

    { time parts }
    byte _secs, _mins, _hours
    byte _wkdays, _days, _months, _years


    { AIS }
    long _ais_channel, _ais_fillbits, _ais_message, _ais_msg_len, _ais_seq_msg_id, _ais_sent_nr
    long _total_vdm

PUB ais_channel(): c
' AIS channel
    return _ais_channel

PUB ais_fillbits(): f
' Number of message fill bits
    return _ais_fillbits

PUB ais_message(): m
' Encapsulated message (ITU-R M.1371)
    return _ais_message

PUB ais_msg_len(): c
' Total number of AIS sentences needed to transfer the message
    return _ais_msg_len

PUB ais_seq_msg_id(): s
' AIS sequential message identifier (0..9)
    return _ais_seq_msg_id

PUB ais_sentence_nr(): s
' AIS sentence number (1..9)
    return _ais_sent_nr


PUB checksum(): rd_ck | idx, tmp
' Extract Checksum from a sentence
'   Returns: Checksum contained in sentence at _ptr_sentence
    idx := 0
    repeat until ( byte[_ptr_sentence][++idx] == CRCMARKER )
    tmp.byte[0] := byte[_ptr_sentence][++idx]
    tmp.byte[1] := byte[_ptr_sentence][++idx]
    tmp.word[1] := 0

    return str.atoib(@tmp, str#IHEX)

PUB course_magnetic(): c
' Course over ground (magnetic)
'   Returns: hundredths of a degree
    return _course_mag

PUB course_true(): c
' Course over ground (true)
'   Returns: hundredths of a degree
    return _course_true

PUB date(): d
' Get current date/day of month
    return _days

PUB east_west(): ew
' Indicates East/West of Prime Meridian
'   Returns: E or W (ASCII)
    return _east_west

PUB fix(): f
' Indicates position fix
'   Returns:
'       0 - no data yet
'       1 - no fix
'       2 - 2D fix
'       3 - 3D fix
    return _fix

PUB full_date(): d
' Full date (day, month, year)
'   Returns: integer (ddmmyy)
    return _date

PUB gen_checksum(): cksum | idx
' Calculate checksum of a sentence
'   Returns: Calculated 8-bit checksum of sentence
    cksum := idx := 0

    if ( byte[_ptr_sentence][0] == SENTSTART )     ' skip over the start of sentence marker;
        ++idx                                   '   it's not included in the checksum
    repeat
        cksum ^= byte[_ptr_sentence][idx]
    while ( byte[_ptr_sentence][++idx] <> CRCMARKER )

    return (cksum & $FF)

PUB hdop(): h
' Horizontal dilution of precision
'   Returns: DOP (hundredths)
    return _hdop

PUB hours(): h
' Return: last read hours (u8)
    return _hours

PUB extract_date_parts()
' Extract parts of last read date
    _years := (_date // 100)
    _months := (_date / 10_000)
    _days := ((_date // 10_000) / 100)

PUB extract_lat_parts()
' Extract components from last recorded latitude
    _lat_degs := (_latitude / 1_000_000)
    _lat_mins := (_latitude // 1_000_000)
    _lat_mins_p := (_lat_mins // 10_000)
    _lat_mins_w := (_lat_mins / 10_000)

PUB extract_long_parts()
' Extract components from last recorded longitude
    _long_degs := (_longitude / 1_000_000)
    _long_mins := (_longitude // 1_000_000)
    _long_mins_p := (_long_mins // 10_000)
    _long_mins_w := (_long_mins / 10_000)

PUB extract_time_parts()
' Extract parts of last read time
    _hours := (_ztime / 10_000)
    _mins := ((_ztime // 10_000) / 100)
    _secs := (_ztime // 100)

PUB latitude(): lat
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
    return _latitude

PUB lat_deg(): d
' Extract degrees from latitude
    return _lat_degs

PUB lat_minutes(): m
' Extract minutes (whole and part) from latitude
    return _lat_mins

PUB lat_minutes_part(): m
' Extract minutes (part) from latitude
    return _lat_mins_p

PUB lat_minutes_whole(): m
' Extract minutes (whole) from latitude
    return _lat_mins_w

PUB longitude(): lon
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
    return _longitude

PUB long_deg(): d
' Extract degrees from longitude
    return _long_degs

PUB long_minutes(): m
' Extract minutes (whole and part) from longitude
    return _long_mins

PUB long_minutes_part(): m
' Extract minutes (part) from longitude
    return _long_mins_p

PUB long_minutes_whole(): m
' Extract minutes (whole) from longitude
    return _long_mins_w

PUB minutes(): m
' Return last read minutes (u8)
    return _mins

PUB month(): m
' Get current month
    return _months

PUB north_south(): ns
' Indicates North/South of equator
'   Returns: N/S (ASCII)
    return _north_south

PUB parse_gga() | tmp
' Parse GGA (Time, position, and fix related data) sentence
    if ( sentence_id() == SNTID_GGA )
        _total_gga++
        tmp := str.getfield(_ptr_sentence, GGA_EW, ",")
        _east_west := byte[tmp]

        tmp := str.getfield(_ptr_sentence, GGA_LAT, ",")
        str.stripchar(tmp, ".")
        _latitude := str.atoi(tmp)
        extract_lat_parts()

        tmp := str.getfield(_ptr_sentence, GGA_LONG, ",")
        str.stripchar(tmp, ".")
        _longitude := str.atoi(tmp)
        extract_long_parts()

        tmp := str.getfield(_ptr_sentence, GGA_NS, ",")
        _north_south := byte[tmp]

        tmp := str.getfield(_ptr_sentence, RMC_ZTIME, ",")
        _ztime := str.atoi(tmp)
        extract_time_parts()

PUB parse_gsa() | tmp
' Parse GSA (GPS DOP and active satellites) sentence
    if ( sentence_id() == SNTID_GSA )
        _total_gsa++
        _fix := str.atoi(str.getfield(_ptr_sentence, GSA_MODE2, ","))

        tmp := str.getfield(_ptr_sentence, GSA_HDOP, ",")
        str.stripchar(tmp, ".")
        _hdop := str.atoi(tmp)

        tmp := str.getfield(_ptr_sentence, GSA_PDOP, ",")
        str.stripchar(tmp, ".")
        _pdop := str.atoi(tmp)

        tmp := str.getfield(_ptr_sentence, GSA_VDOP, ",")
        bytemove(tmp+(strsize(tmp)-3), 0, 3)    ' remove the checksum from the extracted string
        str.stripchar(tmp, ".")
        _vdop := str.atoi(tmp)

PUB parse_gsv() | tmp
' Parse GSV (Number of SVs in view, PRN, elevation, azimuth, and SNR) sentence
    if ( sentence_id() == SNTID_GSV )
        _total_gsv++

PUB parse_rmc() | tmp
' Parse RMC (Position, Velocity, and Time) sentence
    if ( sentence_id() == SNTID_RMC )
        _total_rmc++
        tmp := str.getfield(_ptr_sentence, RMC_COGT, ",")
        str.stripchar(tmp, ".")
        _course_true := str.atoi(tmp)

        tmp := str.getfield(_ptr_sentence, RMC_SOG, ",")
        str.stripchar(tmp, ".")
        _speed_kts := str.atoi(tmp)

        tmp := str.getfield(_ptr_sentence, RMC_EW, ",")
        str.copy(@_east_west, tmp)

        _date := str.atoi(str.getfield(_ptr_sentence, RMC_ZDATE, ","))
        extract_date_parts()

        tmp := str.getfield(_ptr_sentence, RMC_LAT, ",")
        str.stripchar(tmp, ".")
        _latitude :=  str.atoi(tmp)
        extract_lat_parts()

        tmp := str.getfield(_ptr_sentence, RMC_LONG, ",")
        str.stripchar(tmp, ".")
        _longitude := str.atoi(tmp)
        extract_long_parts()

        tmp := str.getfield(_ptr_sentence, RMC_NS, ",")
        str.copy(@_north_south, tmp)

        tmp := str.getfield(_ptr_sentence, RMC_ZTIME, ",")
        _ztime := str.atoi(tmp)
        extract_time_parts()

PUB parse_vdm() | tmp
' Parse received (from remote) AIS sentence
    if ( sentence_id() == SNTID_VDM )
        _total_vdm++
    bytemove(@_ais_channel, str.getfield(_ptr_sentence, 4, ","), 1)
    _ais_fillbits := str.atoi(str.getfield(_ptr_sentence, 6, ","))
    _ais_message := str.getfield(_ptr_sentence, 5, ",")
    _ais_msg_len := str.atoi(str.getfield(_ptr_sentence, 1, ","))
    _ais_seq_msg_id := str.getfield(_ptr_sentence, 3, ",")
    _ais_sent_nr := str.atoi(str.getfield(_ptr_sentence, 2, ","))

PUB parse_vtg() | tmp
' Parse VTG (Actual track made good and speed over ground) sentence
    if ( sentence_id() == SNTID_VTG )
        _total_vtg++
        tmp := str.getfield(_ptr_sentence, VTG_COGM, ",")
        str.stripchar(tmp, ".")
        _course_mag := str.atoi(tmp)

        tmp := str.getfield(_ptr_sentence, VTG_COGT, ",")
        str.stripchar(tmp, ".")
        _course_true := str.atoi(tmp)

        tmp := str.getfield(_ptr_sentence, VTG_SPD_KTS, ",")
        str.stripchar(tmp, ".")
        _speed_kts := str.atoi(tmp)

        tmp := str.getfield(_ptr_sentence, VTG_SPD_KMH, ",")
        str.stripchar(tmp, ".")
        _speed_kmh := str.atoi(tmp)

PUB pdop(): p
' Position dilution of precision
'   Returns: DOP (hundredths)
    return _pdop

PUB ptr_sentence(ptr_sntnc)
' Set pointer to NMEA0183 sentence data
'   Valid values: $0004..$7fae
'   Any other value returns the current setting
    case ptr_sntnc
        $0004..$7fae:
            _ptr_sentence := ptr_sntnc
        other:
            return _ptr_sentence

PUB seconds(): s
' Return last read seconds (u8)
    return _secs

PUB sentence_good(): t
' Verify last sentence recorded is valid (checksum good)
    t := ( checksum() == gen_checksum() )
    ifnot ( t )
        _total_bad++

PUB sentence_id(): sid | idx
' Extract Sentence ID from a sentence
'   Returns: 3-byte sentence ID (ASCII)
    repeat idx from SID_ST to SID_END
        sid.byte[idx-SID_ST] := byte[_ptr_sentence][idx]

PUB speed_kts(): spd
' Speed over ground, in hundredths of a knot
'   (e.g., 361 == 3.61kts)
    return _speed_kts

PUB speed_kmh(): spd
' Speed over ground, in hundredths of a kmh
'   (e.g., 361 == 3.61kts)
    return _speed_kmh

PUB talker_id(): tid
' Extract Talker ID from a sentence
'   Returns:
'       2-byte talker ID (ASCII)
    return word[_ptr_sentence][TID_ST]

PUB time_of_day(): tod
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
    return _ztime

PUB vdop(): v
' Vertical dilution of precision
'   Returns: DOP (hundredths)
    return _vdop

PUB year(): y
' Get current year
    return _years

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

