# RestClient.post( upload_url, :file => File.new(ARGV[1], 'r'), :select => "true", :apikey => "r3pr4pfit" )
require 'rubygems'
require 'optparse'
require 'base64'
require 'socket'
require 'net/http'
require 'rest_client'
require 'json'


class Printer
  def initialize(printer)
    @name = printer['printer']['name']
    @url  = printer['printer']['url']
    @port = printer['printer']['port']
    @select = printer['printer']['select']
    @print = printer['printer']['print']

  end

  def info
    puts 'Name    ' + @name
    puts 'URL     ' + @url
    puts 'PORT    ' + @port.to_s
    puts 'select  ' + @select
    puts 'print   ' + @print
  end
end


class OCAW
  def initialize
    @printers = Array.new
    loadConfig('.config.json')
    @printers.at(0).info
  end

  def loadConfig(config)
    File.open(config) do|config|
      parsed = JSON.parse(config.read)
      parsed["printers"].each do |printer|
        # puts conf["port"]
        puts printer
        @printers.push( Printer.new(printer))

      end
    end
  end
end


# my_ip = Socket::getaddrinfo(Socket.gethostname,"echo",Socket::AF_INET)[0][3]
# printer_ip = my_ip[0.. (my_ip.rindex('.'))]+ARGV[0]
# puts my_ip + " - My IP address"
# puts printer_ip + " - Printer's IP address"  

# File.open(ARGV[1], 'r') do|gcode|
# 	encoded_gcode =  Base64.encode64(gcode.read)
# end

# puts url = "http://" + printer_ip + ":5000/api/state?apikey=r3pr4pfit" 
# puts upload_url = "http://" + printer_ip + ":5000/api/files/local"
# u = "http://172.16.60.123:5000/ajax/gcodefiles/upload"
# u = "http://172.16.60.123:5000/api/files/local"
# uri = URI(url)
# puts uri

def initDefaultsFromConfig()
	File.open(".config.json") do|config|
		parsed = JSON.parse(config.read)
			parsed["config"].each do |conf|
				# puts conf["port"]
				p conf
			end
		end
	end


def upload_file(url, file, select, apikey)
	RestClient.post( url, :file => File.new(file, 'r'), :select => select, :apikey => apikey )
end




  OCAW.new()


#initDefaultsFromConfig()
#RestClient.post(u, File.new(ARGV[1]))
# puts printer_state = Net::HTTP.get(uri) # => String
# http://172.16.60.123:5000/ajax/gcodefiles/upload
# http://localhost:5000/api/state?apikey=PUT_YOUR_API_KEY_HERE



