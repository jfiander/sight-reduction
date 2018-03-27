# Sight Reduction

This is a simple applicaiton for reducing celestial sights.

## Example Usage

```ruby
loc = LOC.create do |l|
  l.lha = '334 7.4'
  l.dec = '16 41.3 S'
  l.ho  = '36 53.4'
  l.lat = '29 17.2 N'
  l.lon = '35 16.2 W'
end

loc.plot # { intercept: "0.8 A", azimuth: 212 }

loc.sheet # { lha: 334.12333, lat: 29.28667, dec: -16.68833, hc: 37.67679, hc_deg: "37 40.6", z: "N 148.11624 W", a: "0.8 A", zn: 212 }
```
