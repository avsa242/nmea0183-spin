# nmea0183-spin
---------------

This is a P8X32A/Propeller library object for parsing NMEA-0183 sentences

## Salient features

* Sentence ID parsing (GGA, GSA, GSV, RMC, VTG)
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

## Limitations

* Library is very early in development and may malfunction, or outright fail to build

## TODO

- [x] Implement method to extract time from RMC and GGA sentences
- [x] Improve parser: de-tokenize sentences using the "," as a reference, rather than hardcoded positions
- [ ] Implement demo that uses the debug.emulator.rtc.spin in conjunction with a GPS receiver to set and display the time
- [ ] Implement method to convert lat/lon to MGRS
- [ ] Handle other message types (e.g., AIS-related)
