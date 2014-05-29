# RestClient.post( upload_url, :file => File.new(ARGV[1], 'r'), :select => "true", :apikey => "r3pr4pfit" )
require 'optparse'
require 'base64'
require 'socket'
require 'net/http'
require 'rest_client'
require 'json'

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
		p parsed["port"]
	end
end

def upload_file(url, file, select, apikey)
	RestClient.post( url, :file => File.new(file, 'r'), :select => select, :apikey => apikey )
end

initDefaultsFromConfig()



#RestClient.post(u, File.new(ARGV[1]))
# puts printer_state = Net::HTTP.get(uri) # => String

# http://172.16.60.123:5000/ajax/gcodefiles/upload


# http://localhost:5000/api/state?apikey=PUT_YOUR_API_KEY_HERE



