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
      intercept: "#{intercept.round(1)} #{intercept_dir}",
      azimuth: zn
    }
  end

  def sheet
    {
      lha: dec_lha.to_f,
      lat: dec_lat.to_f,
      dec: dec_dec.to_f,
      hc: hc.to_d.round(5).to_f,
      z: azimuth_angle,
      a: "#{intercept.round(1)} #{intercept_dir}",
      zn: zn
    }
  end

  def hc
    a = Math.cos(dec_lha) * Math.cos(dec_lat) + Math.cos(dec_dec)
    b = Math.sin(dec_lat) * Math.sin(dec_dec)
    Math.asin(a + b)
  rescue Math::DomainError
    raise 'There was a problem calculating Hc. Check your sight data.'
  end

  def z
    a = Math.sin(dec_dec) - (Math.sin(dec_lat) * Math.sin(hc))
    b = Math.cos(dec_lat) * Math.cos(hc)
    Math.acos(a / b)
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

  private

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
    dec_ho - hc
  end

  def intercept_dir
    intercept.positive? ? 'T' : 'A'
  end
end
