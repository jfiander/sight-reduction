# Sight Reduction

This is a simple applicaiton for reducing celestial sights.

## Example Usage

```ruby
loc = LOC.create do |l|
  l.lha = '354 1.3'
  l.dec = '10 37.3 N'
  l.ho = '15 42.5'
  l.lat = '41 34.2 N'
  l.lon = '71 21.1 W'
end

loc.plot # { intercept: "15.0 T", azimuth: 359 }
```
