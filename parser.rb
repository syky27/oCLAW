require 'optparse'
require 'base64'
require 'socket'
require 'net/http'


my_ip = Socket::getaddrinfo(Socket.gethostname,"echo",Socket::AF_INET)[0][3]
printer_ip = my_ip[0.. (my_ip.rindex('.'))]+ARGV[0]
puts my_ip + " - My IP address"
puts printer_ip + " - Printer's IP address"  

File.open(ARGV[1], 'r') do|gcode|
	encoded_gcode =  Base64.encode64(gcode.read)
end

puts uri = "http://" + printer_ip + ":5000/api/state?apikey=r3pr4pfit" 
better_uri = URI(uri)
puts better_uri

# uri = URI('http://example.com/index.html?count=10')
puts Net::HTTP.get(better_uri) # => String


# http://localhost:5000/api/state?apikey=PUT_YOUR_API_KEY_HERE



