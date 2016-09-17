#!/usr/bin/ruby
require 'sinatra'
require 'haml'
require 'csv'
require 'json'
require 'yaml'
require 'set'
require 'git'

#### Sinatra parts

set :haml, {:format => :html5 }

get '/pmd' do
	config = readConfig
	
	@latestCommit = cloneGitRepo config
	runPMD config
	
	@rules = config["pmd"]["rules"]
	@data = readCSV config["workingDir"]+"/pmd.csv"
	
	haml :index
end

get '/pmd/source' do
	@file = params[:file]
	@package = params[:package].gsub(/\./, '/')
	
	config = readConfig
	
	@file_content = file = File.open(config["workingDir"] + "/" + config["git"]["branch"] + "/" + config["git"]["sourceDir"] + "/" + @package + "/" + @file, "rb").read
	
	@data = readCSV config["workingDir"]+"/pmd.csv"
	data_min = @data.select { |key, value| key.to_s.match(/#{@file}/) }
	
	@json = @data.select { |key, value| key.to_s.match(/#{@file}/) }.to_json.to_s
	
	@lines = uniqeErrorLines data_min
	
	haml :source
end

#### helper functions

def readConfig
	return YAML.load(File.open("config.yml", "rb").read)
end

def cloneGitRepo config
	workingDir = config["workingDir"]
	branch = config["git"]["branch"]
	repository = config["git"]["repository"]
	if not Dir.exists? workingDir then
		Dir.mkdir workingDir
		g = Git.clone(repository, branch, :path => workingDir)
		latestCommit = g.log.last
	else
		g = Git.open(workingDir + "/" + branch)
		g.pull
		latestCommit = g.log.last
	end
	
	return latestCommit
end

def runPMD config
	cmd = "pmd -dir #{config["workingDir"]}/#{config["git"]["branch"]}/#{config["git"]["sourceDir"]} -f csv -R #{formatRules config} > #{config["workingDir"]}/pmd.csv"
	
	# run os command
	value = %x[ #{cmd} ]
end

def formatRules config
	result = ""
	
	rulesetFiles = {"Android" => "android","Basic" => "basic","Braces" => "braces","Clone Implementation" => "clone","Code Size" => "codesize","Comments" => "comments","Controversial" => "controversial","Coupling" => "coupling","Design" => "design","Empty Code" => "empty","Finalizer" => "finalizers","Import Statements" => "imports","J2EE" => "j2ee","JavaBeans" => "javabeans","JUnit" => "junit","Jakarta Commons Logging" => "logging-jakarta-commons","Java Logging" => "logging-java","Migration" => "migrating","Naming" => "naming","Optimization" => "optimizations","Strict Exceptions" => "strictexception","String and StringBuffer" => "strings","Security Code Guidelines" => "sunsecure","Type Resolution" => "typeresolution","Unnecessary" => "unnecessary","Unused Code" => "unusedcode"}
	
	for r in config["pmd"]["rules"] do
		result += "java-" + rulesetFiles[r] + ","
	end
	return result[0..-2]
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
