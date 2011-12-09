require 'sinatra'
require 'json'
require './app_config'
require './token_generator'
require 'hiredis'
require 'redis'
require 'uri'

before do
	$r = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT) if !$r
end

get %r{/([\w]+)} do |hash|
	url = $r.get(URL_TOKEN_NAMESPACE + hash)
	unless url.nil?
		$r.incr(CLICK_COUNTER_NAMESPACE + hash)
		status 302
		headers 'Location' => url
	else
		status 404
	end
	
end

post "/url" do
	unless params[:url].nil? and (params[:url] =~ URI::regexp).nil?
		token = TokenGenerator.new.generate_token(params[:url])
		$r.set(URL_TOKEN_NAMESPACE + token, params[:url])
        $r.lpush('urls',params[:url])
        response = {'shorturl' => DOMAIN + token}
	else
		status 400 # Bad Request
        response = {'error' => 'Invalid URL'}
	end
    body response.to_json
end
