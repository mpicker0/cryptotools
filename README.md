cryptotools
===========

Description
-----------
`cryptotools` provides a browser-based way to find MD5 and SHA1 hashes, do URL encoding and decoding, Base64 encoding and decoding, and a few other useful things.  It is written in Ruby, using [Sinatra](http://www.sinatrarb.com/) for the web front-end.

History
-------
Many years ago, I started using a PHP-based tool called [Cryptomak](http://sourceforge.net/projects/makcoder/) to do simple things like MD5 and SHA1 hashing for password comparisons.  I gradually started to add my own features, until the PHP code became large and difficult to maintain.

Having gotten interested in Ruby recently, I decided to try to re-implement it in Ruby, and needing a simple web front-end, I chose Sinatra.

Demo
----
Try it on [Heroku](https://my-cryptotools.herokuapp.com/).

Bulding and running locally
---------------------------
Install dependencies with:

    bundle install --path vendor/bundle

Start it directly with:

    bundle exec ./cryptotools.rb

Then, browse to <http://localhost:4567>

You can also start it via [Rack](https://rack.github.io/):

    bundle exec rackup config.ru

Then, browse to <http://localhost:9292>
