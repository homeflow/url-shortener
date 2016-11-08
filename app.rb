require 'sinatra'

require 'json'
require './app_config'
require './token_generator'
require 'hiredis'
require 'redis'
require "redis/namespace"
require 'uri'
require './page'

before do
    $r = Redis::Namespace.new(:url_short, :redis => Redis.new)
end

get "/urls" do
      H = HTMLGen.new if !defined?(H)
      H.set_title "URLs"
      url_list = ""
      $r.smembers('urls').each do |token_url|
        begin 
          token, url = token_url.split('*')
          clicks = $r.get(CLICK_COUNTER_NAMESPACE + token)
          clicks = 0 if clicks.nil?
          url_list << H.li {DOMAIN + token + " - " + url + ": "+ clicks.to_s + " clicks"}
        rescue Exception => e
          puts "Url_short "+token_url+" "+e.message
        end
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
		params[:url] = "http://" + params[:url] if params[:url][0..3] != "http"
		token = TokenGenerator.new.generate_token(params[:url])
		$r.set(URL_TOKEN_NAMESPACE + token, params[:url])
        $r.sadd('urls',token+ "*" +params[:url])
        response = {'shorturl' => DOMAIN + token}
	else
		status 400 # Bad Request
        response = {'error' => 'Invalid URL'+params.inspect}
	end
    response.to_json
end
