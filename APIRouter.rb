class APIRouter
  def self.appendAPIKey(url)
    return url + '?apikey=' + ENV['OCLAW_API_KEY'].to_s
  end

  def self.printer_info(ip)
    return appendAPIKey("http://#{ip}/api/printer")
  end

  def self.heat(ip, instrument)
    return appendAPIKey("http://#{ip}/api/printer/#{instrument}")
  end

  def self.files_info(ip)
    return appendAPIKey("http://#{ip}/api/files")
  end
end