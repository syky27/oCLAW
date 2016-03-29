require 'rubygems'
require 'optparse'
require 'base64'
require 'socket'
require 'timeout'
require 'net/http'
require 'net/ping'
require 'rest_client'
require 'json'
require 'mixlib/cli'
require 'terminal-table'
require 'resolv'
require 'io/console'

require  './APIHelper'
require './APIRouter'
require './Printer'
require './APIWrapper'
require './Instrument'
require './File'

class OCLAW
  @printers = []
  @files = []
  def list()
    @printers = Array.new
    for i in discover
        url =  APIRouter.printer_info i
        puts url
        RestClient.get(url){ |response, request, result, &block|
          case response.code
            when 200
              json = JSON.parse(response)
              printer_ip = request.url[/#{"http://"}(.*?)#{"/api"}/m, 1]
              printer_state = json["state"]["text"]
              printer_temp_bed = json["temperature"]["bed"]["actual"].to_s + ' => ' + json["temperature"]["bed"]["target"].to_s
              printer_temp_nozzle = json["temperature"]["tool0"]["actual"].to_s + ' => ' + json["temperature"]["tool0"]["target"].to_s
              begin
                printer_hostname = Resolv.getname printer_ip
              rescue Resolv::ResolvError
                printer_hostname = "Not Resolved"
              end
                @printers.push(Printer.new(printer_hostname, printer_ip , printer_state, printer_temp_bed, printer_temp_nozzle))

            when 423
              raise SomeCustomExceptionIfYouWant
            when 409
              @printers.push(Printer(printer_hostname, printer_ip, "Conflict", "No Printers", "maybe?"))
            when 401
              @printers.push(Printer(printer_hostname,  printer_ip, "IVALID", "API", "KEY"))
          end
        }
    end
    printTable
  end

  def printTable
    rows = Array.new
    counter = 0
    for printer in @printers
      rows << printer.getRow.unshift(counter.to_s)
      counter += 1
    end

    table = Terminal::Table.new :title => "Available Printers", :headings => ['ID','Hostname','IP', 'State', 'Temp Bed', 'Temp Nozzle'], :rows => rows
    puts table
  end

  def heat
    list
    puts "Select printer by ID"
    printer = STDIN.gets.chomp
    puts "What would you like to heat?\n(1) Nozzle\n(2) Bed"
    instrument = STDIN.gets.chomp
    puts "Enter Temperature"
    temp = STDIN.gets.chomp

    if instrument == "1"
      APIWrapper.heat(@printers[printer.to_i], temp, NOZZLE)
    elsif instrument.to_s == "2"
      APIWrapper.heat(@printers[printer.to_i], temp, BED)
    else
      puts "Ivalid option... Starting over"
      return heat
    end
  end

  def list_files
    list
    puts 'Select printer by ID'
    printer = STDIN.gets.chomp

    @files = APIWrapper.getFiles(@printers[printer.to_i])

    rows = []
    counter = 0
    for file in @files
      rows << file.getRow.unshift(counter.to_s)
      counter += 1
    end

    table = Terminal::Table.new :title => "Available Files", :headings => ['ID','Filename','Size', 'Date', 'Origin', 'Print Time', 'Filament Lenght', 'Filament Volume', 'Failure', 'Success'], :rows => rows
    puts table

  end

  def discover
    count = 0
    arr = []
    my_local_ip_address =  my_first_private_ipv4
    puts my_local_ip_address
    255.times do |i|
      arr[i] = Thread.new {
        begin
          ip_address = my_local_ip_address.to_s + "." + i.to_s
          Timeout::timeout(3) { Thread.current["socket"] = TCPSocket.new(ip_address, 80) }
          Thread.current["state"] = "OK"
          Thread.current["address"] = ip_address
        rescue SocketError
          Thread.current["state"] = "SOCKETERROR"
        rescue Timeout::Error
          Thread.current["state"] = "Error"
        rescue Errno::ECONNREFUSED
          Thread.current["state"] = "ECONNREFUSED"
        rescue Errno::EHOSTUNREACH
          Thread.current["state"] = "EHOSTUNREACH"
        rescue Errno::EACCES
          Thread.current["state"] = "EACCES"
        rescue Errno::EHOSTDOWN
          Thread.current["state"] = "EHOSTDOWN"
        end
        count += 1

      }
    end

    ips_with_open_port = Array.new
    for a in arr
      a.join
      if a["address"]
        ips_with_open_port.push(a["address"])
      else
        arr.delete(a)
      end
    end
    puts "available ips \n" + ips_with_open_port.to_s
    return ips_with_open_port
  end

  def my_first_private_ipv4
    return Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address.split('.')[0,3].join('.')
  end

  end

command = ARGV[0]

case command
  when "list"
    oclaw = OCLAW.new()
    oclaw.list

  when "heat"
    oclaw = OCLAW.new()
    oclaw.heat

  when "discover"
    oclaw = OCLAW.new()
    oclaw.discover

  when "files"
    oclaw = OCLAW.new()
    oclaw.list_files

  else
    puts "Invalid option"
end


