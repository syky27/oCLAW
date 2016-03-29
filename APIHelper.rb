class APIHelper

  def self.heat_nozzle(temp)
    return {:command => "target", :targets => { :tool0 => temp.to_i, :tool1 => temp.to_i, :tool2 => temp.to_i, :tool3 => temp.to_i, }}.to_json
  end

  def self.heat_bed(temp)
    return {:command => "target", :target => temp.to_i}.to_json
  end

  def self.heat(temp, instrument)
    if instrument == BED
      return {:command => "target", :target => temp.to_i}.to_json
    else
      return {:command => "target", :targets => { :tool0 => temp.to_i, :tool1 => temp.to_i, :tool2 => temp.to_i, :tool3 => temp.to_i, }}.to_json
    end
  end

end
