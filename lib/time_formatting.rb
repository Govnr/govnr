module TimeFormatting
	def self.convert_to_seconds(value,unit)
		case unit.downcase
		when 'seconds'
			num = 1
		when 'minutes'
			num = 60
		when 'hours'
			num = 3600
		when 'days'
			num = 86400
		end
		return value * num
	end
end