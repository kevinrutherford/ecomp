require 'sinatra'
require 'haml'
require 'json'

get '/list' do
	output = ""
	for x in Dir.entries("public/data")
		unless x.start_with?(".")
			output += "<a href=\"/#"+x+"\">"+x+"</a><br>"
		end
	end

	output
end

get '/' do
  haml :index
end
