require 'sinatra'
require 'json'
require './app_config'
require './token_generator'
require 'hiredis'
require 'redis'
require 'uri'
require './page'

before do
    uri = URI.parse(ENV["REDIS_URL"])
    $r = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password) if !$r
end

get "/urls" do
    H = HTMLGen.new if !defined?(H)
    H.set_title "URLs"
    url_list = ""
    $r.smembers('urls').each do |token_url| 
        token, url = token_url.split('*')
        clicks = $r.get(CLICK_COUNTER_NAMESPACE + token)
        clicks = 0 if clicks.nil?
        url_list << H.li {DOMAIN + token + " - " + url + ": "+ clicks + " clicks"}
    end
    H.page {
        H.ul {
            url_list
        }
    }
end

get %r{/([a-zA-Z0-9]+)/stats} do |hash|
    $r.get(CLICK_COUNTER_NAMESPACE + hash)
end

get %r{/([a-zA-Z0-9]+)} do |hash|
	url = $r.get(URL_TOKEN_NAMESPACE + hash)
	unless url.nil?
		$r.incr(CLICK_COUNTER_NAMESPACE + hash)
		status 302
		headers 'Location' => url
	else
		status 404
	end
    body nil
end

post "/url" do
	unless params[:url].nil? and (params[:url] =~ URI::regexp).nil?
		token = TokenGenerator.new.generate_token(params[:url])
		$r.set(URL_TOKEN_NAMESPACE + token, params[:url])
        $r.sadd('urls',token+ "*" +params[:url])
        response = {'shorturl' => DOMAIN + token}
	else
		status 400 # Bad Request
        response = {'error' => 'Invalid URL'}
	end
    response.to_json
end
