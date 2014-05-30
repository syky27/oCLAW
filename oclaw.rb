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
    @location = printer['printer']['location']
    @apikey = printer['printer']['apikey']

  end

  def info
    puts 'Name      ' + @name
    puts 'ApiKey    ' + @apikey
    puts 'URL       ' + @url
    puts 'PORT      ' + @port.to_s
    puts 'select    ' + @select
    puts 'print     ' + @print
    puts 'location  ' + @location
  end

  def getName
    @name
  end

  def getURL
    @url
  end

  def getPort
    @port
  end

  def getSelect
    @select
  end

  def getPrint
    @print
  end

  def getLocation
    @location
  end

  def getAPI
    @apikey
  end

end


class OCAW
  def initialize
    @printers = Array.new
    loadConfig('.config.json')
  end

  def loadConfig(config)
    File.open(config) do|config|
      parsed = JSON.parse(config.read)
      parsed["printers"].each do |printer|
      @printers.push( Printer.new(printer))
      end
    end
  end

  def uploadFile(file, printer)
    @printers.each  do  |p|
      if  p.getName() == printer
        upload_url = "http://" + p.getURL().to_s + ":"+ p.getPort().to_s + "/api/files/" + p.getLocation().to_s
        begin
          response =  RestClient.post( upload_url, :file => File.new(file, 'r'), :select => p.getSelect().to_s, :apikey => p.getAPI().to_s )
          response = JSON.parse(response)
        rescue
          abort("File does not exists")
        end
        if response["done"] == true
          sleep(50)
          filename = file[ (file.rindex('/')) .. file.length]
          puts info_url = "http://" + p.getURL().to_s + ":"+ p.getPort().to_s + "/api/files/"  + p.getLocation().to_s  + filename.to_s + "?apikey=" + p.getAPI().to_s
          info = RestClient.get(info_url)
          puts info
          puts info = JSON.parse(info, )
          puts info["gcodeAnalysis"] => "estimatedPrintTime"


          puts 'SUCCESS => File ' + file + ' successfully uploaded to printer ' + printer + ' on ' + p.getLocation().to_s + ' storage.'
        else
          puts 'FAILURE => File ' + file + ' Not uploaded !!!'

        end
      end
    end
  end

  def deleteFile(file, printer)
    @printers.each do |p|
      if p.getName() == printer
        begin
          delete_url = "http://" + p.getURL().to_s + ":"+ p.getPort().to_s + "/api/files/"  + p.getLocation().to_s  + "/" + file.to_s + "?apikey=" + p.getAPI().to_s
          RestClient.delete(delete_url)
        rescue
          abort("FAILURE => File not found !!!")
        end
        puts 'SUCCESS => File deleted'

      end
    end
  end



end








  program = OCAW.new()
  #program.uploadFile(ARGV[1],ARGV[0])
  program.uploadFile("/Users/syky/Desktop/test02.gcode", "work")
  # program.deleteFile("test02.gcode", "work")


