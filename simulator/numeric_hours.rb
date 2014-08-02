class Numeric
  def seconds
    self
  end
  def minutes
    60 * self.seconds
  end
  def hours
    60 * self.minutes
  end
  def inches
    self
  end
  def feet
    12 * self.inches
  end
  def miles
    5280 * self.feet
  end
end
