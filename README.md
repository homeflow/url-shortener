Simple URL shortener with Ruby, Sinatra and Redis
=================================================
by Felipe Ribeiro <felipernb@gmail.com>

requires the following gems:

* redis
* sinatra
* json

It works as a REST API and to shorten an URL, one must do:

    curl -X POST -d "url=http://google.com" http://YOURDOMAIN/url

The return will be a JSON with the `shorturl` field that contains the shortened URL (as expected :P)

When GETing the short url:

    curl GENERATED_URL

The response will redirect you to the proper URL and increment the number of accesses

Stats page comming soon
