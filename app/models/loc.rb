class LOC < ApplicationRecord
  validates_presence_of :lha, :dec, :ho, :lat, :lon

  before_save do
    self.dec_lha = parse_coordinate(lha)
    self.dec_dec = parse_coordinate(dec)
    self.dec_ho  = parse_coordinate(ho)
    self.dec_lat = parse_coordinate(lat)
    self.dec_lon = parse_coordinate(lon)

    if dec_lat.negative?
      self.dec_lat = -1 * dec_lat
      self.dec_dec = -1 * dec_dec
    end
  end

  def plot
    {
      intercept: intercept,
      azimuth: zn
    }
  end

  def sheet
    {
      lha: dec_lha.to_f,
      lat: dec_lat.to_f,
      dec: dec_dec.to_f,
      hc: hc,
      hc_deg: hc_deg,
      z: azimuth_angle,
      a: intercept,
      zn: zn
    }
  end

  private

  def rad(deg)
    deg * Math::PI / 180
  end

  def deg(rad)
    rad * 180 / Math::PI
  end

  def hc
    a = Math.cos(rad(dec_lha)) * Math.cos(rad(dec_lat)) * Math.cos(rad(dec_dec))
    b = Math.sin(rad(dec_lat)) * Math.sin(rad(dec_dec))
    c = a + b
    deg(Math.asin(c)).to_d.round(5).to_f
  rescue Math::DomainError
    raise 'There was a problem calculating Hc. Check your sight data.'
  end

  def hc_deg
    d = hc.to_i
    m = ((hc - d) * 60).round(1)
    "#{d} #{m}"
  end

  def z
    a = Math.sin(rad(dec_dec)) - (Math.sin(rad(dec_lat)) * Math.sin(rad(hc)))
    b = Math.cos(rad(dec_lat)) * Math.cos(rad(hc))
    deg(Math.acos(a / b))
  rescue Math::DomainError
    raise 'There was a problem calculating Z. Check your sight data.'
  end

  def zn
    azimuth.round % 360
  end

  def azimuth_angle
    azimuth_quadrant[0] + " #{z.to_f.round(5)} " + azimuth_quadrant[1]
  end

  def azimuth
    return (360 - z) if azimuth_quadrant == 'NW'
    return z         if azimuth_quadrant == 'NE'
    return (180 + z) if azimuth_quadrant == 'SW'
    return (180 - z) if azimuth_quadrant == 'SE'
  end

  def parse_coordinate(string)
    degrees, minutes, symbol = string.delete('°\'"').split(' ')

    dec_degrees = (degrees.to_i + minutes.to_d / 60)

    if symbol.in? %w[S E]
      dec_degrees * -1
    else
      dec_degrees
    end
  end

  def azimuth_quadrant
    return 'NW' if  dec_lat.positive? && dec_lha < 180
    return 'NW' if  dec_lat.positive? && dec_lha > 180
    return 'NW' if !dec_lat.positive? && dec_lha < 180
    return 'NW' if !dec_lat.positive? && dec_lha > 180
  end

  def intercept
    a = (dec_ho - hc).round(1)
    d = a.positive? ? 'T' : 'A'

    "#{a.abs} #{d}"
  end
end
