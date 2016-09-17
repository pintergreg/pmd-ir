#!/usr/bin/ruby
require 'sinatra'
require 'haml'
require 'csv'
require 'json'
require 'set'

set :haml, {:format => :html5 }


get '/pmd' do
	@data = readCSV "pmd.csv"
	
	haml :index
end


get '/pmd/source' do
	@file = params[:file]
	@file_content = file = File.open("/mnt/sdb5/OE-NIK/PhD/bosch/debrecen/framework/UniDeb/src/com/unideb/bosch/automatedcar/PowertrainSystem.java", "rb").read
	
	@data = readCSV "pmd.csv"
	data_min = @data.select { |key, value| key.to_s.match(/#{@file}/) }
	
	@json = @data.select { |key, value| key.to_s.match(/#{@file}/) }.to_json.to_s
	
	@lines = uniqeErrorLines data_min
	
	haml :source
end

# read the given CSV containing the PMD report
def readCSV pmdReportCSVFile
	file = File.open(pmdReportCSVFile, "rb")
	csv_contents = file.read
	keys = ["Problem","Package","File","Priority","Line","Description","Rule set","Rule"]
	return CSV.parse(csv_contents).map {|a| Hash[ keys.zip(a) ] }
end

def uniqeErrorLines data
	set = Set.new
	for row in data do
		set.add row["Line"].to_s
	end
	@lines = "";
	for e in set do
		@lines += e + ","
	end
	return @lines[0..-2]
end
