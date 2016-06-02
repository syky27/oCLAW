class Printer
  @@all_printers = Array.new
  attr_accessor :ip, :api_key, :hostname, :state, :temp_bed, :temp_nozzle, :files

  def initialize(options = {})
    self.ip = options[:ip] || ''
    self.api_key = options[:api_key] || ''
    self.hostname = options[:hostname] || ''
    self.state =  options[:state] || ''
    self.temp_bed = options[:temp_bed] || 0
    self.temp_nozzle = options[:temp_nozzle] || 0
    self.files = Array.new
    @@all_printers << self
  end

  public def update(options = {})
    self.hostname = options[:hostname] || self.hostname
    self.state =  options[:state] || self.state
    self.temp_bed = options[:temp_bed] || self.temp_bed
    self.temp_nozzle = options[:temp_nozzle] || self.temp_nozzle
  end

  def self.all_instances
    @@all_printers
  end

  # def all_files
  #   @@files
  # end

  public def getRow
    return [self.hostname, self.ip, self.state, self.temp_bed, self.temp_nozzle]
  end

  public def getIP
    return self.ip.to_s
  end
end
