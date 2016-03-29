class Printer
  @hostname
  @ip
  @state
  @temp_bed
  @temp_nozzle

  def initialize(hostname, ip, state, temp_bed, temp_nozzle)
    @hostname = hostname
    @ip = ip
    @state = state
    @temp_bed = temp_bed
    @temp_nozzle = temp_nozzle

  end

  public def getRow
    return [@hostname, @ip, @state, @temp_bed, @temp_nozzle]
  end

  public def getIP
    return @ip.to_s
  end

end