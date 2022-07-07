# nmea0183-spin
---------------

This is a P8X32A/Propeller library object for parsing NMEA-0183 sentences

## Salient features

* GPS Sentence ID parsing (GGA, GSA, GSV, RMC, VTG)
* Talker ID parsing (L, N, P)
* Sentence checksum verification
* GGA, RMC: Position parsing (extract latitude as degrees minutes DDMMMMMM, longitude DDDMMMMMM)
* GSA: Position fix status, dilution of precision status
* GGA, RMC: Time and date parsing (extract time from a sentence as any of: HHMMSS, HH, MM, SS)
* VTG, RMC: Speed over ground (knots), VTG: kmh
* VTG: Course over ground (magnetic)
* VTG, RMC: Course over ground (true)

## Requirements

* Any source of NMEA-0183 sentences (including, but not limited to a GPS receiver)
* Buffer of (typ.) 81 bytes in length containing the sentence to be parsed

## Compiler Compatibility

| Processor | Language | Compiler               | Backend     | Status                |
|-----------|----------|------------------------|-------------|-----------------------|
| P1        | SPIN1    | FlexSpin (5.9.10-beta) | Bytecode    | OK                    |
| P1        | SPIN1    | FlexSpin (5.9.10-beta) | Native code | OK                    |
| P1        | SPIN1    | OpenSpin (1.00.81)     | Bytecode    | Untested (deprecated) |
| P2        | SPIN2    | FlexSpin (5.9.10-beta) | NuCode      | Untested              |
| P2        | SPIN2    | FlexSpin (5.9.10-beta) | Native code | Not yet implemented   |
| P1        | SPIN1    | Brad's Spin Tool (any) | Bytecode    | Unsupported           |
| P1, P2    | SPIN1, 2 | Propeller Tool (any)   | Bytecode    | Unsupported           |
| P1, P2    | SPIN1, 2 | PNut (any)             | Bytecode    | Unsupported           |

## Limitations

* Library is very early in development and may malfunction, or outright fail to build

