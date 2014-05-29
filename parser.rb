require 'optparse'
require 'base64'
require 'socket'
require 'net/http'
require 'rest_client'

my_ip = Socket::getaddrinfo(Socket.gethostname,"echo",Socket::AF_INET)[0][3]
printer_ip = my_ip[0.. (my_ip.rindex('.'))]+ARGV[0]
puts my_ip + " - My IP address"
puts printer_ip + " - Printer's IP address"  

File.open(ARGV[1], 'r') do|gcode|
	encoded_gcode =  Base64.encode64(gcode.read)
end

puts url = "http://" + printer_ip + ":5000/api/state?apikey=r3pr4pfit" 
puts upload_url = "http://" + printer_ip + ":5000/api/load?apikey=r3pr4pfit" 
u = "http://172.16.60.123:5000/ajax/gcodefiles/upload"
uri = URI(url)
puts uri


RestClient.post u, :gcode_file => File.new(ARGV[1], 'r', :select => "true") 


#RestClient.post(u, File.new(ARGV[1]))
# puts printer_state = Net::HTTP.get(uri) # => String

# http://172.16.60.123:5000/ajax/gcodefiles/upload


# http://localhost:5000/api/state?apikey=PUT_YOUR_API_KEY_HERE



