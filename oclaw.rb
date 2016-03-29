# RestClient.post( upload_url, :file => File.new(ARGV[1], 'r'), :select => "true", :apikey => "r3pr4pfit" )
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

class APIRouter
  def self.heat_bed(ip)
    return appendAPIKey("http://#{ip}/api/printer/bed")
  end

  def self.heat_nozzle(ip)
    return appendAPIKey("http://#{ip}/api/printer/tool")
  end

  def self.appendAPIKey(url)
    return url + '?apikey=' + ENV['OCLAW_API_KEY'].to_s
  end
end

class APIHelper

  def self.heat_nozzle(temp)
   return {:command => "target", :targets => { :tool0 => temp.to_i, :tool1 => temp.to_i, :tool2 => temp.to_i, :tool3 => temp.to_i, }}.to_json
  end

  def self.heat_bed(temp)
    return {:command => "target", :target => temp.to_i}.to_json
  end

end

class Printer
  @hostname
  @ip
  @state
  @temp_bed
  @temp_nozzle

  def initialize(hostname, ip, state, temp_bed, temp_nozzle)
    @hostname = hostname
    @ip = ip
    @state = state
    @temp_bed = temp_bed
    @temp_nozzle = temp_nozzle

  end

  public def getRow
    return [@hostname, @ip, @state, @temp_bed, @temp_nozzle]
  end

  public def getIP
    return @ip.to_s
  end

end

class OCLAW
  @printers = []

  def list(order)
    @printers = Array.new
    for i in discover
        url =  'http://' + i.to_s + '/api/printer?apikey='
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
                printer_hostname = "Unknown"
              end
                @printers.push(Printer.new(printer_hostname, printer_ip , printer_state, printer_temp_bed, printer_temp_nozzle))

            when 423
              raise SomeCustomExceptionIfYouWant
            when 409
              @printers.push(Printer(printer_hostname, "Offline", printer_state, printer_temp_bed, printer_temp_nozzle))
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
    list true
    puts "Select printer by ID"
    printer = STDIN.gets.chomp
    puts "What would you like to heat?\n(1) Nozzle\n(2) Bed"
    instrument = STDIN.gets.chomp
    puts "Enter Temperature"
    temperature = STDIN.gets.chomp

    if instrument == "1"
      puts APIRouter.heat_nozzle(@printers[printer.to_i].getIP)
      RestClient.post(APIRouter.heat_nozzle(@printers[printer.to_i].getIP),  APIHelper.heat_nozzle(temperature),  :content_type => :json, :accept => :json  ){ |response, request, result, &block|
        case response.code
          when 204
            puts "SUCCESS - Printing live temp change :"

            while 1
              temp =  getTemp(@printers[printer.to_i].getIP) + "\r"
              print temp
              $stdout.flush
              sleep 1
            end

          when 409
            puts "Printer is Busy"
          when 400
            puts "Invalid"
        end
      }
    elsif instrument.to_s == "2"
      puts APIRouter.heat_bed(@printers[printer.to_i].getIP)
      RestClient.post(APIRouter.heat_bed(@printers[printer.to_i].getIP) ,  APIHelper.heat_bed(temperature),  :content_type => :json, :accept => :json  ){ |response, request, result, &block|
        case response.code
          when 204
            puts "SUCCESS - Printing live temp change :"

            while 1
              temp =  getTemp(@printers[printer.to_i].getIP) + "\r"
              print temp
              $stdout.flush
              sleep 1
            end

          when 409
            puts "Printer is Busy"
          when 400
            puts "Invalid"
        end
      }
    else
      puts "Ivalid option... Starting over"
      return heat
    end



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
          Thread.current["state"] = "KO"
        rescue Timeout::Error
          Thread.current["state"] = "KO"
        rescue Errno::ECONNREFUSED
          Thread.current["state"] = "KO"
        rescue Errno::EHOSTUNREACH
          Thread.current["state"] = "KO"
        rescue Errno::EACCES
          Thread.current["state"] = "KO"
        rescue Errno::EHOSTDOWN
          Thread.current["state"] = "KO"
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

  def getTemp(printer_ip)
    RestClient.get('http://' + printer_ip + '/api/printer?apikey=' ){ |response, request, result, &block|
      case response.code
        when 200
          json = JSON.parse(response)
          printer_temp_bed = json["temperature"]["bed"]["actual"].to_s + ' => ' + json["temperature"]["bed"]["target"].to_s
          printer_temp_nozzle = json["temperature"]["tool0"]["actual"].to_s + ' => ' + json["temperature"]["tool0"]["target"].to_s
          return "Temp Bed : " + printer_temp_bed.to_s + " Temp Nozzle " + printer_temp_nozzle.to_s
        when 409
          puts "Failure"
      end
    }

  end


  def my_first_private_ipv4
    return Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address.split('.')[0,3].join('.')
  end

  end

command = ARGV[0]

case command
  when "list"
    oclaw = OCLAW.new()
    oclaw.list false

  when "heat"
    oclaw = OCLAW.new()
    oclaw.heat

  when "discover"
    oclaw = OCLAW.new()
    oclaw.discover
  when "betterList"
    oclaw = OCLAW.new()
    oclaw.betterList
  else
    puts "Invalid option"
end


