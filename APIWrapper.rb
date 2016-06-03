require './APIRouter'
require './APIHelper'
require './Printer'
require './Instrument'
require './File'

class APIWrapper
  def self.heat(printer, temp, instrument)
    RestClient.post(APIRouter.heat(printer, instrument),  APIHelper.heat(temp, instrument),  :content_type => :json, :accept => :json  ){ |response, request, result, &block|
      case response.code
        when 204
          puts "Success"

        when 409
          puts "Printer is Busy"
        when 400
          puts "Invalid"
      end
    }
  end


  def self.liveTemp(printer)
    puts "Live Temp :"

    while 1
      temp =  APIWrapper.getTemp(printer) + "\r"
      print temp
      $stdout.flush
      sleep 1
    end
  end


  def self.getTemp(printer)
    RestClient.get(APIRouter.printer_info(printer)){ |response, request, result, &block|
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

  def self.getFiles(printer)
    RestClient.get(APIRouter.files_info(printer)){ |response|
      case response.code
        when 200
          json = JSON.parse(response)
          puts json
          for file in json["files"]
            printer.files.push(OctoFile.new(:name => file["name"] || "Unavailable",
                                :size => file["size"] || "Unavailable",
                                :date => file["date"] || "Unavailable",
                                :origin => file["origin"] || "Unavailable",
                                :download_url => file["refs"] ? file["refs"]["download"] : "Unavailable",
                                :print_time => file["gcodeAnalysis"] ? file["gcodeAnalysis"]["estimatedPrintTime"] : "Unavailable",
                                :filament_lenght => file["gcodeAnalysis"] ? file["gcodeAnalysis"]["filament"]["tool0"]["length"] : "Unavailable",
                                :filament_volume => file["gcodeAnalysis"] ? file["gcodeAnalysis"]["filament"]["tool0"]["volume"] : "Unavailable",
                                :print_fail =>  file["prints"] ? file["prints"]["failure"] : "Unavailable",
                                :print_success => file["prints"] ? file["prints"]["success"] : "Unavailable"))
          end

        when 409
          puts "Failure"
      end
    }
  end

  def self.uploadFile(printer, file)
    RestClient.post APIRouter.upload_file(printer), :myfile => File.new('/Users/syky/Desktop/OCLAW.gcode', 'rb')
    # RestClient.post(APIRouter.upload_file(printer),
    #                 :name_of_file_param => File.new(file))
  end

  def self.deleteFile(printer, file)
    RestClient.delete APIRouter.delete_file(printer, file) { |response|
      puts response.code
      json = JSON.parse(response)
      puts json
    }
  end

end