class APIRouter
  def self.printer_info(ip)
    return appendAPIKey("http://#{ip}/api/printer")
  end

  def self.heat_bed(ip)
    return appendAPIKey("http://#{ip}/api/printer/bed")
  end

  def self.heat(ip, instrument)
    return appendAPIKey("http://#{ip}/api/printer/#{instrument}")
  end

  def self.heat_nozzle(ip)
    return appendAPIKey("http://#{ip}/api/printer/tool")
  end

  def self.appendAPIKey(url)
    return url + '?apikey=' + ENV['OCLAW_API_KEY'].to_s
  end
end