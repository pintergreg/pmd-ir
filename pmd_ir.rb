#!/usr/bin/ruby
require 'sinatra'
require 'haml'
#~ require 'sass'
require 'csv'

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
	
	haml :source
end
