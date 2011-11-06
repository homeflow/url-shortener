require 'sinatra'
require 'json'
require './app_config'
require './token_generator'
require 'redis'

before do
	$r = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT)
end

get %r{/([\w]+)} do |hash|
	url = $r.get(URL_TOKEN + hash)
	unless url.nil?
		$r.incr(CLICK_COUNTER + hash)
		status 302
		headers "Location" => url
	else
		status 404
	end
	
end

post "/url" do
	unless params[:url].nil?
		token = TokenGenerator.new.generate_token(params[:url])
		$r.set(URL_TOKEN + token, params[:url])
		output = { shorturl: DOMAIN + token}.to_json
	else
		status 400 # Bad Request
		output = {error: "Empty URL"}.to_json
	end
end