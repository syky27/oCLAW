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
  @files = []
  def list()

    initFromConfig

    for printer in Printer.all_instances
        url =  APIRouter.printer_info(printer)
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
                printer.update(hostname: printer_hostname, state: printer_state, temp_bed: printer_temp_bed, temp_nozzle: printer_temp_nozzle)
            break
            when 423
              raise SomeCustomExceptionIfYouWant
              break
            when 409
              printer.update hostname: "Not Resolved", state: "NO PRINTER"
              break
            when 401
              printer.update hostname: "Not Resolved", state: "API KEY FAIL"
              break
          end
        }
    end
    printTable
  end

  def printTable
    rows = Array.new
    counter = 0
    for printer in Printer.all_instances
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
      APIWrapper.heat(Printer.all_instances[printer.to_i], temp, NOZZLE)
    elsif instrument.to_s == "2"
      APIWrapper.heat(Printer.all_instances[printer.to_i], temp, BED)
    else
      puts "Ivalid option... Starting over"
      return heat
    end
  end

  def list_files
    list
    puts 'Select printer by ID'
    printer = STDIN.gets.chomp.to_i
    if printer > Printer.all_instances.count
      puts "Invalid ID"
      return list_files
    end
    APIWrapper.getFiles(Printer.all_instances[printer])

    rows = []
    counter = 0
    for file in Printer.all_instances[printer].files
      rows << file.getRow.unshift(counter.to_s)
      counter += 1
    end
    table = Terminal::Table.new :title => "Available Files", :headings => ['ID','Filename','Size', 'Date', 'Origin', 'Print Time', 'Filament Lenght', 'Filament Volume', 'Failure', 'Success'], :rows => rows
    puts table

  end

  def file_options
    puts 'Select File Action\n(P) Print\n(U) Upload\n(D) Delete\n(Q) Quit'
    action = STDIN.gets.chomp
    case action.to_s.upcase
      when 'P'
        puts 'print'
      when 'U'
        puts 'upload'

    end


  end

  def initFromConfig
    File.open('/Users/syky/.oclaw.config') do |f|
      f.each_line do |line|
        tuple = line.to_s.strip.split(' ')
        Printer.new ip: tuple[0], api_key: tuple[1]
      end
    end
  end

  def discover
    count = 0
    arr = []
    my_local_ip_address =  my_first_private_ipv4
    255.times do |i|
      arr[i] = Thread.new {
        begin
          ip_address = my_local_ip_address.to_s + "." + i.to_s
          Timeout::timeout(30) { Thread.current["socket"] = TCPSocket.new(ip_address, 80) }
          Thread.current["state"] = "OK"
          Thread.current["address"] = ip_address
          Thread.current["socket"].close
        rescue SocketError
          Thread.current["state"] = "SOCKETERROR"
          socket = Thread.current["socket"]
        rescue Timeout::Error
          Thread.current["state"] = "TIMEOUT"
          socket = Thread.current["socket"]
        rescue Errno::ECONNREFUSED
          Thread.current["state"] = "ECONNREFUSED"
          socket = Thread.current["socket"]
        rescue Errno::EHOSTUNREACH
          Thread.current["state"] = "EHOSTUNREACH"
          socket = Thread.current["socket"]
        rescue Errno::EACCES
          Thread.current["state"] = "EACCES"
          socket = Thread.current["socket"]
        rescue Errno::EHOSTDOWN
          Thread.current["state"] = "EHOSTDOWN"
          socket = Thread.current["socket"]
        rescue Errno::EMFILE
          Thread.current["state"] = "EMFILE"
          socket = Thread.current["socket"]
        end
        count += 1

      }
    end

    ips_with_open_port = Array.new
    for a in arr
      a.join
      puts a["state"]
      if a["address"]
        print a["address"]
        ips_with_open_port.push(a["address"])
      else
        arr.delete(a)
      end
    end
    puts "available ips \n" + ips_with_open_port.to_s
    # return ['192.168.99.100']
    return ips_with_open_port
  end

  def my_first_private_ipv4
    return Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address.split('.')[0,3].join('.')
  end

  end

command = ARGV[0]

case command
  when "list"
    OCLAW.new().list
    
  when "heat"
    OCLAW.new().heat

  when "discover"
    OCLAW.new().discover

  when "files"
    OCLAW.new().list_files

  when "status"
    OCLAW.new().file

  else
    puts "Invalid option"
end


