#!/usr/bin/ruby
require 'sinatra'
require 'haml'
require 'csv'
require 'json'
require 'yaml'
require 'set'
require 'git'
require 'rest-client'

#### Sinatra parts

set :haml, {:format => :html5 }

get '/pmd' do
	config = readConfig
	
	@latestCommit = getGitRepo config
	runPMD config
	
	@rules = config["pmd"]["rules"]
	@data = readCSV config["workingDir"]+"/pmd.csv"
	
	# serve index page
	haml :index
end

get '/pmd/source' do
	# process URL parameters
	@file = params[:file]
	@package = params[:package].gsub(/\./, '/')
	
	config = readConfig
	
	@file_content = file = File.open(config["workingDir"] + "/" + config["git"]["branch"] + "/" + config["git"]["sourceDir"] + "/" + @package + "/" + @file, "rb").read
	
	@data = readCSV config["workingDir"]+"/pmd.csv"
	data_min = @data.select { |key, value| key.to_s.match(/#{@file}/) }
	
	@json = @data.select { |key, value| key.to_s.match(/#{@file}/) }.to_json.to_s
	@lines = uniqeErrorLines data_min
	
	# serve source view page
	haml :source
end

#### helper functions

def readConfig
	return YAML.load(File.open("config.yml", "rb").read)
end

# clones git repository or pulls changes if local exists and returns the latest commit
def getGitRepo config
	workingDir = config["workingDir"]
	branch = config["git"]["branch"]
	repository = config["git"]["repository"]
	
	# when working directory does not exist, create it and clone the repository
	# otherwise just pull changes
	if not Dir.exists? workingDir then
		Dir.mkdir workingDir
		g = Git.clone(repository, branch, :path => workingDir)
		latestCommit = g.log.last
	else
		g = Git.open(workingDir + "/" + branch)
		if not isLatestGithubCommit? repository, g then
			g.pull
		end
		latestCommit = g.log.last
	end
	
	return latestCommit
end

# builds arguments for PMD and executes the OS command
# if expects that PMD is installed on the system!
def runPMD config
	cmd = "pmd -dir #{config["workingDir"]}/#{config["git"]["branch"]}/#{config["git"]["sourceDir"]} -f csv -R #{formatRules config} > #{config["workingDir"]}/pmd.csv"
	
	# run os command
	value = %x[ #{cmd} ]
end

# builds the command line argument from the rules set names 
def formatRules config
	result = ""
	
	# rule set filename is not indicated from the name of the rule set, so a mapping is used
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

# gets the error line numbers from the CSV data and builds a string listing them without duplication
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

# checks whether repo is on GitHub, a GitHub API can be used
# returns true if GitHub and the latest commit is in local repo
# otherwise returns false
def isLatestGithubCommit? repository, git
	result = false
	if repository.include? "github.com" then
		
		# uses a GitHub API to get the latest commit hash
		json = JSON.parse RestClient.get('https://api.github.com/repos' + repository[/(.*)(github.com)(.*)(.git)/, 3] + '/commits')

		if git.log.last == json[0]["sha"] then
			result = true
		end
	end
	return result
end
