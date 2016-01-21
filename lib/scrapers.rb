require "scrapers/ontario_farm_fresh"
require "scrapers/bc_farmers_market"

module Scraper
	def self.run(scraper_name)
		case scraper_name
		when "ontariofarmfresh"
			farms = Scrapers::OntarioFarmFresh.run()
			return farms
		when "bcfarmersmarket"
			farms = Scrapers::BCFarmersMarket.run()
			return farms
		else
			puts "No such scraper"
		end
	end
end
