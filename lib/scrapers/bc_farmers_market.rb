require "nokogiri"
require "open-uri"
require "geolocation"

module Scrapers
	class BCFarmersMarket
		SITE = "http://markets.bcfarmersmarket.org"
		def self.run()
			links = collect_links()
			puts "Done collecting links"
			farms = []
			links.each do |link|
				puts "Scraping "+ link
				farms.push(scrape_farm(link))
			end
			return farms
		end
		def self.collect_links()
			links = []
			for i in 0..13
				url = URI.parse(BCFarmersMarket::SITE+"/market-search?location=&page=#{i}")
				doc = Nokogiri::HTML(open(url))
				doc.css(".market-name").each do |div|
					links.push(div.css("a")[0]["href"])
				end
				puts "Done collecting link page #{i}"
			end
			return links
		end
		def self.scrape_farm(link)
			doc = Nokogiri::HTML(open(BCFarmersMarket::SITE+link))
			farm = {}
			farm["name"] = doc.css(".vendor-title h1")[0].content.strip
			begin
				farm["hours"] = doc.css(".market-timings")[0].content.strip.sub("Hours of operation:", "")
			rescue Exception => e
			end
			farm["description"] = doc.css(".vendor-description")[0].content.strip
			farm["phone"] = doc.css(".vendor-phone")[0].content.strip.sub("Phone:", '')
			farm["email"] = doc.css(".vendor-email")[0].content.strip.sub("Email:", '')
			begin
				farm["website"] = doc.css(".vendor-website a")[0].content.strip
			rescue Exception => e
			end
			products_string = ""
			doc.css(".vendor-products ul")[0].children.each do |item|
				products_string += item.content.strip + ", "
			end
			farm["products"] = products_string
			begin
				address_dump = doc.css('#venodr-location p')[0].content.strip
				address_dict = Geolocation::Geolocator.get_geo(address_dump + ", Canada")
				farm = farm.merge(address_dict)
			rescue Exception => e
			end
			return farm
		end
		private_class_method :collect_links, :scrape_farm
	end
end