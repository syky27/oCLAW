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


class OCLAW
  @printers = []

  def list(order)
    rows = []
    threads = []
    counter = 0
    @printers = Array.new
    for i in discover
      url =  'http://' + i.to_s + '/api/printer?apikey='

      threads[counter] = Thread.new {
        RestClient.get(url){ |response, request, result, &block|
          case response.code
            when 200
              json = JSON.parse(response)
              printer_ip = request.url[/#{"http://"}(.*?)#{"/api"}/m, 1]
              printer_state = json["state"]["text"]
              printer_temp_bed = json["temperature"]["bed"]["actual"].to_s + ' => ' + json["temperature"]["bed"]["target"].to_s
              printer_temp_nozzle = json["temperature"]["tool0"]["actual"].to_s + ' => ' + json["temperature"]["tool0"]["target"].to_s
              # printer_hostname = Resolv.getname printer_ip
              @printers.push(printer_ip)
              if order
                Thread.current["row"] = [0,0,printer_ip, printer_state, printer_temp_bed, printer_temp_nozzle ]
              else
                Thread.current["row"] = [0,printer_ip, printer_state, printer_temp_bed, printer_temp_nozzle ]
              end

              response
            when 423
              raise SomeCustomExceptionIfYouWant
            when 409
              if order
                Thread.current["row"] = [0,0,"Printer", "not", "operational", "409"]
              else
                Thread.current["row"] = [0,"Printer", "not", "operational", "409"]
              end
          end
        }
      }

      counter += 1
    end

    for thread in threads
      thread.join
      rows << thread["row"]
    end

    if order == true
      table = Terminal::Table.new :title => "Available Printers", :headings => ['ID','Hostname','IP', 'State', 'Temp Bed', 'Temp Nozzle'], :rows => rows
    else
      table = Terminal::Table.new :title => "Available Printers", :headings => ['Hostname','IP', 'State', 'Temp Bed', 'Temp Nozzle'], :rows => rows
    end

    puts table
  end

  def heat
    list true
    puts "Select printer by ID"
    printer = STDIN.gets.chomp
    puts "What would you like to heat?\n(1) Nozzle\n(2) Bed"
    instrument = STDIN.gets.chomp
    if instrument.to_s == "1"
      instrument == "tool0"
    elsif instrument.to_s == "2"
      instrument = "bed"
    else
      puts "Ivalid option... Starting over"
      return heat
    end
    puts "Enter Temperature"
    temperature = STDIN.gets.chomp

    RestClient.post('http://172.16.61.204/api/printer/' + instrument.to_s + '?apikey=',  {:command => "target", :target => temperature.to_i}.to_json,  :content_type => :json, :accept => :json  ){ |response, request, result, &block|
    case response.code
      when 204
        puts "Success\nPrinting temp change"

        while 1
          puts getTemp(1)
          sleep 1
        end

      when 409
        puts "Printer is Busy"
      when 400
        puts "Invalid"
    end
    }
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

      }end

    ips_with_open_port = Array.new
    for a in arr
      a.join
      puts a["state"]
      if a["address"]
        ips_with_open_port.push(a["address"])
      else
        arr.delete(a)
      end
    end
    return ips_with_open_port

  end

  def getTemp(printer_ip)
    RestClient.get('http://172.16.61.204/api/printer?apikey=' ){ |response, request, result, &block|
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


