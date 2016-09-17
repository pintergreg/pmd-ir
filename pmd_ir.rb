#!/usr/bin/ruby
require 'sinatra'
require 'haml'
require 'csv'
require 'json'
require 'set'

set :haml, {:format => :html5 } # az alapértelmezett Haml formátum az :xhtml


get '/pmd' do
	
	# read the CSV containing the event ids
	file = File.open("pmd.csv", "rb")
	csv_contents = file.read
	keys = ["Problem","Package","File","Priority","Line","Description","Rule set","Rule"]
	@data = CSV.parse(csv_contents).map {|a| Hash[ keys.zip(a) ] }
	
	haml :index
end


get '/pmd/source' do
	@file = params[:file]
	@line = params[:line]
	@file_content = file = File.open("/mnt/sdb5/OE-NIK/PhD/bosch/debrecen/framework/UniDeb/src/com/unideb/bosch/automatedcar/PowertrainSystem.java", "rb").read
	
	# read the CSV containing the event ids
	file = File.open("pmd.csv", "rb")
	csv_contents = file.read
	keys = ["Problem","Package","File","Priority","Line","Description","Rule set","Rule"]
	@data = CSV.parse(csv_contents).map {|a| Hash[ keys.zip(a) ] }
	data_min = @data.select { |key, value| key.to_s.match(/#{@file}/) }
	@w = @data.select { |key, value| key.to_s.match(/#{@file}/) }.keep_if { |k, _| ["Problem","Priority","Line","Description"].include? k }
	@json = @data.select { |key, value| key.to_s.match(/#{@file}/) }.to_json.to_s
	
	lines = Set.new
	for row in data_min do
		lines.add row["Line"].to_s
	end
	@lines = "";
	for e in lines do
		@lines += e + ","
	end
	@lines = @lines[0..-2]
	
	haml :source
end
