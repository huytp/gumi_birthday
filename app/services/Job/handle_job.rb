module Job
  class HandleJob
    def self.birthdaythisyear day_of_birth
      day_month = day_of_birth.to_s.slice(4...day_of_birth.to_s.size)
      birthday = Date.parse(Time.zone.now.year.to_s + day_month) 
      birthday
    end 
  end
end
