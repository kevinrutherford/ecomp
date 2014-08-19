require 'sinatra'
require 'haml'
require 'json'

get '/list' do
	output = ""
	for x in Dir.entries("public/data")
		unless x.start_with?(".")
			output += "<li><a href=\"/#"+x+"\">"+x+"</a></li>"
		end
	end

	haml :list, :locals => { :project_list => output }
end

get '/' do
  haml :index
end
