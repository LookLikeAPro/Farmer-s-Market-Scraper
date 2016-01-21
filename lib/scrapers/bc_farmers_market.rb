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
				farms.push(scrape_farm(link))
				puts "Completed "+ link
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
			address_dump = doc.css('#venodr-location .location-description')[0].content.strip
			farm["hours"] = doc.css(".market-timings")[0].content.strip.sub("Hours of operation:", "")
			farm["description"] = doc.css(".vendor-description")[0].content.strip
			farm["phone"] = doc.css(".vendor-phone")[0].content.strip.sub("Phone:", '')
			farm["email"] = doc.css(".vendor-email")[0].content.strip.sub("Email:", '')
			products_string = ""
			doc.css(".vendor-products ul")[0].children.each do |item|
				products_string += item.content.strip + ", "
			end
			farm["products"] = products_string
			address_dict = Geolocation::Geolocator.get_geo(address_dump + ", BC, Canada")
			farm = farm.merge(address_dict)

			# farm['street'] = doc_body.css('.elocator_address h2')[0].content.strip
			# begin
			# 	farm['city'] = doc_body.css('.elocator_address h2')[1].content.split(', ')[0].strip
			# 	farm['province'] = doc_body.css('.elocator_address h2')[1].content.split(',')[1].strip
			# 	farm['country'] = doc_body.css('.elocator_address h2')[1].content.split(',')[2].strip
			# rescue Exception => e
			# 	farm['address_dump'] = doc_body.css('.elocator_address h2')[1].content.strip
			# end
			# farm['postal_code'] = doc_body.css('.elocator_address h2')[2].content.strip
			# begin
			# 	farm['phone'] = doc_body.css('.elocator_address p')[0].content.sub!('Phone:', '').strip
			# 	farm['hours'] = doc_body.css('.elocator_address p')[1].content.sub!('Hours:', '').strip
			# rescue Exception => e
			# end
			# begin
			# 	farm['link'] = doc_body.css('.elocator_address h2 a')[0]['href']
			# rescue Exception => e
			# end
			# begin
			# 	farm['products'] = doc_body.css('.elocator_public_div .el_product_div span')[0].content.strip
			# 	farm['products_grown'] = doc_body.css('.elocator_public_div .el_product_div span')[1].content.strip
			# 	farm['products_pick'] = doc_body.css('.elocator_public_div .el_product_div span')[2].content.strip
			# rescue Exception => e
			# end
			return farm
		end
		private_class_method :collect_links, :scrape_farm
	end
end