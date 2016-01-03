require "nokogiri"
require "net/http"
require 'open-uri'

module Scrapers
	class OntarioFarmFresh
		def run()
			links = collect_links()
			farms = []
			links.each do |link|
				farms.push(scrape_farm(link))
				puts 'Completed '+link
			end
			return farms
		end
		def collect_links()
			url = URI.parse('http://ontariofarmfresh.com/find-a-farm/#results')
			params = {
				'search_zip' => '',
				'search_radius' => '',
				'search_name' => '',
				'search_products' => '',
				'search_grown' => '',
				'search_pyo' => '',
				'search_features' => '',
				'search_limit' => '1000',
			}
			resp, data = Net::HTTP.post_form(url, params)
			doc = Nokogiri::HTML(resp.body)
			links = []
			doc.css('.searchresult-farm-name a').each do |a|
				links.push(a['href'])
			end
			return links
		end
		def scrape_farm(link)
			doc = Nokogiri::HTML(open(link))
			doc_body = doc.css('#main #content')[0]
			farm = {}
			farm['name'] = doc_body.css('.elocator_address h1')[0].content.strip
			farm['street'] = doc_body.css('.elocator_address h2')[0].content.strip
			begin
				farm['city'] = doc_body.css('.elocator_address h2')[1].content.split(', ')[0].strip
				farm['province'] = doc_body.css('.elocator_address h2')[1].content.split(',')[1].strip
				farm['country'] = doc_body.css('.elocator_address h2')[1].content.split(',')[2].strip
			rescue Exception => e
				farm['address_dump'] = doc_body.css('.elocator_address h2')[1].content.strip
			end
			farm['postal_code'] = doc_body.css('.elocator_address h2')[2].content.strip
			begin
				farm['phone'] = doc_body.css('.elocator_address p')[0].content.sub!('Phone:', '').strip
				farm['hours'] = doc_body.css('.elocator_address p')[1].content.sub!('Hours:', '').strip
			rescue Exception => e
			end
			begin
				farm['link'] = doc_body.css('.elocator_address h2 a')[0]['href']
			rescue Exception => e
			end
			begin
				farm['products'] = doc_body.css('.elocator_public_div .el_product_div span')[0].content.strip
				farm['products_grown'] = doc_body.css('.elocator_public_div .el_product_div span')[1].content.strip
				farm['products_pick'] = doc_body.css('.elocator_public_div .el_product_div span')[2].content.strip
			rescue Exception => e
			end
			return farm
		end
		private :collect_links, :scrape_farm
	end
end