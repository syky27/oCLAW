class APIRouter
  def self.appendAPIKey(url, api_key)
    return url + '?apikey=' + api_key
  end

  def self.printer_info(printer)
    return appendAPIKey("http://#{printer.getIP}/api/printer", printer.api_key)
  end

  def self.heat(printer, instrument)
    return appendAPIKey("http://#{printer.getIP}/api/printer/#{instrument}", printer.api_key)
  end

  def self.files_info(printer)
    return appendAPIKey("http://#{printer.getIP}/api/files", printer.api_key)
  end
end