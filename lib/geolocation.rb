require 'csv'
require 'open-uri'
require 'uri'
require 'json'

module Geolocation
	class Geolocator
		def self.get_geo(address_string)
			farm_address = {}
			data = JSON.load(open(URI.escape("https://maps.googleapis.com/maps/api/geocode/json?address="+address_string)))
			data["results"][0]["address_components"].each do |component|
				type = component["types"][0]
				if ["street_number", "route", "locality", "administrative_area_level_2", "administrative_area_level_1", "country", "postal_code", "postal_code_prefix"].include? type
					farm_address[type] = component["long_name"]
				end
			end
			farm_address["formatted_address"] = data["results"][0]["formatted_address"]
			farm_address["lat"] = data["results"][0]["geometry"]["location"]["lat"]
			farm_address["lng"] = data["results"][0]["geometry"]["location"]["lng"]
			return farm_address
		end
		def self.run(file)
			counter = 0
			farms = []
			CSV.foreach(file) do |row|
				if counter != 0
					farms[counter-1] = {}
					farm = farms[counter-1]
					farm["name"] = row[0]
					address_string = row[1] + ", " + row[2]  + ", Ontario, Canada"
					data = JSON.load(open(URI.escape("https://maps.googleapis.com/maps/api/geocode/json?address="+address_string)))
					data["results"][0]["address_components"].each do |component|
						type = component["types"][0]
						if ["street_number", "route", "locality", "administrative_area_level_2", "administrative_area_level_1", "country", "postal_code", "postal_code_prefix"].include? type
							farm[type] = component["long_name"]
						end
					end
					farm["formatted_address"] = data["results"][0]["formatted_address"]
					farm["lat"] = data["results"][0]["geometry"]["location"]["lat"]
					farm["lng"] = data["results"][0]["geometry"]["location"]["lng"]
					puts 'Completed '+farm["name"]
				end
				counter = counter+1
			end
			write_farms(file.split("_")[0]+"_GEO."+file.split(".")[1], farms)
		end
		def self.write_farms(file, farms)
			CSV.open(file, "wb") do |csv|
				csv << [
					"name",
					"formatted_address",
					"street_number",
					"route",
					"locality",
					"administrative_area_level_2",
					"administrative_area_level_1",
					"country",
					"postal_code_prefix",
					"postal_code",
					"lat",
					"lng",
				]
				farms.each do |farm|
					csv << [
						farm["name"],
						farm["formatted_address"],
						farm["street_number"],
						farm["route"],
						farm["locality"],
						farm["administrative_area_level_2"],
						farm["administrative_area_level_1"],
						farm["country"],
						farm["postal_code_prefix"],
						farm["postal_code"],
						farm["lat"],
						farm["lng"]
					]
				end
			end
		end
	end
end

