# nmea0183-spin
---------------

This is a P8X32A/Propeller library object for parsing NMEA-0183 sentences

## Salient features

* Sentence ID parsing (GGA, GSA, GSV, RMC, VTG)
* Talker ID parsing (L, N, P)
* Sentence checksum verification

## Requirements

* Any source of NMEA-0183 sentences (including, but not limited to a GPS receiver)
* Buffer of (typ.) 81 bytes in length containing the sentence to be parsed

## Limitations

* Library is very early in development and may malfunction, or outright fail to build

## TODO

- [ ] Implement method to extract time from RMC and GGA sentences
- [ ] Implement demo that uses the debug.emulator.rtc.spin in conjunction with a GPS receiver to set and display the time
- [ ] Implement method to convert lat/lon to MGRS
