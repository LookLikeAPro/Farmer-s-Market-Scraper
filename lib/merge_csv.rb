module MergeCsv
	def self.run(product_path, csv_1_path, csv_2_path)
		csv_1 = CSV.read(csv_1_path, headers: true)
		csv_2 = CSV.read(csv_2_path, headers: true)
		# merge(csv_1, csv_2)
		File.open(product_path, 'w') { |file| file.write(merge(csv_1, csv_2)) }
	end

	def self.merge(csv_1, csv_2)
		headers = (csv_1.headers + csv_2.headers).uniq
		hash_array = [csv_1, csv_2].flat_map &method(:csv_to_hash_array)

		CSV.generate do |merged_csv|
			merged_csv << headers

			hash_array.each do |row|
				merged_csv << row.values_at(*headers)
			end
		end
	end

	def self.csv_to_hash_array(csv)
		csv.to_a[1..-1].map do |row|
			Hash[csv.headers.zip(row)]
		end
	end
end
