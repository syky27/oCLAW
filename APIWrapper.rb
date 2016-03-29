require './APIRouter'
require './APIHelper'
require './Printer'
require './Instrument'
require './File'

class APIWrapper
  def self.heat(printer, temp, instrument)
    RestClient.post(APIRouter.heat(printer.getIP, instrument),  APIHelper.heat(temp, instrument),  :content_type => :json, :accept => :json  ){ |response, request, result, &block|
      case response.code
        when 204
          puts "SUCCESS - Printing live temp change :"

          while 1
            temp =  APIWrapper.getTemp(printer) + "\r"
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
  end

  def self.getTemp(printer)
    RestClient.get(APIRouter.printer_info(printer.getIP)){ |response, request, result, &block|
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
    files = []
    RestClient.get(APIRouter.files_info(printer.getIP)){ |response|
      case response.code
        when 200
          json = JSON.parse(response)
          for file in json["files"]
            files.push(OctoFile.new(:name => file["name"],
                                :size => file["size"],
                                :date => file["date"],
                                :origin => file["origin"],
                                :download_url => file["refs"]["download"],
                                :print_time => file["gcodeAnalysis"]["estimatedPrintTime"],
                                :filament_lenght => file["gcodeAnalysis"]["filament"]["length"],
                                :filament_volume => file["gcodeAnalysis"]["filament"]["volume"],
                                :print_fail => file["prints"]["failure"],
                                :print_success => file["prints"]["success"]))
          end
          return files

        when 409
          puts "Failure"
      end
    }
  end

end