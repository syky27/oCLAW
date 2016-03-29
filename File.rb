class OctoFile
  attr_accessor :name, :filament_volume, :print_success, :origin, :download_url, :size, :date, :print_time, :print_fail, :filament_lenght

  def initialize(params = {})
    params.each { |key,value| instance_variable_set("@#{key}", value) }
  end

  public def getRow()
    return [@name , @size, @date, @origin, @print_time, @filament_lenght, @filament_volume, @print_fail, @print_success]
  end
end