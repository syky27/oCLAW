# RestClient.post( upload_url, :file => File.new(ARGV[1], 'r'), :select => "true", :apikey => "r3pr4pfit" )
require 'rubygems'
require 'optparse'
require 'base64'
require 'socket'
require 'net/http'
require 'net/ping'
require 'rest_client'
require 'json'
require 'mixlib/cli'
require 'terminal-table'
require 'resolv'

class OCLAW

  def list(*order)

    rows = []
    p Socket.ip_address_list

    # my_local_ip_address = p my_first_private_ipv4.ip_address.split('.')[0,3].join('.')
    my_local_ip_address = '172.16.61'
    for i in 204..204
        url =  'http://' + my_local_ip_address.to_s + '.' + i.to_s + '/api/printer?apikey='
        RestClient.get('http://' + my_local_ip_address.to_s + '.' + i.to_s + '/api/printer?apikey='){ |response, request, result, &block|
          case response.code
            when 200
              json = JSON.parse(response)
              printer_ip = request.url[/#{"http://"}(.*?)#{"/api"}/m, 1]
              printer_state = json["state"]["text"]
              printer_temp_bed = json["temperature"]["bed"]["actual"].to_s + ' => ' + json["temperature"]["bed"]["target"].to_s
              printer_temp_nozzle = json["temperature"]["tool0"]["actual"].to_s + ' => ' + json["temperature"]["tool0"]["target"].to_s
              # printer_hostname = Resolv.getname printer_ip
              if order
                rows << [0,0,printer_ip, printer_state, printer_temp_bed, printer_temp_nozzle ]
              else
                rows << [0,printer_ip, printer_state, printer_temp_bed, printer_temp_nozzle ]
              end

              response
            when 423
              raise SomeCustomExceptionIfYouWant
          end
        }

        if order
          table = Terminal::Table.new :title => "Available Printers", :headings => ['ID','Hostname','IP', 'State', 'Temp Bed', 'Temp Nozzle'], :rows => rows
        else
          table = Terminal::Table.new :title => "Available Printers", :headings => ['Hostname','IP', 'State', 'Temp Bed', 'Temp Nozzle'], :rows => rows
        end

        puts table
    end
  end

  def heat
    list(1)
  end


  def my_first_private_ipv4
    return Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
  end

  end


command = ARGV[0]

case command
  when "list"
    oclaw = OCLAW.new()
    oclaw.list(nil)

  when "heat"
    oclaw = OCLAW.new()
    oclaw.heat

  else
    puts "Invalid option"
end


