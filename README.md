# nmea0183-spin
---------------

This is a P8X32A/Propeller library object for parsing NMEA-0183 sentences

## Salient features

* GPS Sentence ID parsing (GGA, GSA, GSV, RMC, VTG)
* Talker ID parsing (L, N, P)
* Sentence checksum verification
* GGA, RMC: Position parsing (extract latitude as degrees minutes DDMMMMMM, longitude DDDMMMMMM - in whole or in part)
* GSA: Position fix status, dilution of precision status (HDOP, VDOP, PDOP)
* GGA, RMC: Time and date parsing (extract time from a sentence as any of: HHMMSS, HH, MM, SS)
* VTG, RMC: Speed over ground (knots), VTG: km/h
* VTG: Course over ground (magnetic)
* VTG, RMC: Course over ground (true)
* AIS sentence parsing (VDM - preliminary, very limited)


## Requirements

* Any source of NMEA-0183 sentences (including, but not limited to a GPS receiver)
* Buffer of (typ.) 83 bytes in length containing the sentence to be parsed


## Compiler Compatibility

| Processor | Language | Compiler               | Backend      | Status                |
|-----------|----------|------------------------|--------------|-----------------------|
| P1        | SPIN1    | FlexSpin (6.1.1)       | Bytecode     | OK                    |
| P1        | SPIN1    | FlexSpin (6.1.1)       | Native/PASM  | OK                    |
| P2        | SPIN2    | FlexSpin (6.1.1)       | NuCode       | OK                    |
| P2        | SPIN2    | FlexSpin (6.1.1)       | Native/PASM2 | OK                    |

(other versions or toolchains not listed are __not supported__, and _may or may not_ work)


## Hardware compatibility

* Tested with UART-connected GPS receivers


## Limitations

* Library is very early in development and may malfunction, or outright fail to build

