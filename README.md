cryptotools
===========

Description
-----------
`cryptotools` provides a browser-based way to find MD5 and SHA1 hashes, do URL encoding and decoding, Base64 encoding and decoding, and a few other useful things.  It is written in Ruby, using [Sinatra](http://www.sinatrarb.com/) for the web front-end.

History
-------
Many years ago, I started using a PHP-based tool called [Cryptomak](http://sourceforge.net/projects/makcoder/) to do simple things like MD5 and SHA1 hashing for password comparisons.  I gradually started to add my own features, until the PHP code became large and difficult to maintain.

Having gotten interested in Ruby recently, I decided to try to re-implement it in Ruby, and needing a simple web front-end, I chose Sinatra.

Requirements
------------
* [Ruby 1.9](http://www.ruby-lang.org); I have not tested with Ruby 1.8, but the only thing I know of that would prevent its running are some hash literals.
* [Sinatra](http://www.sinatrarb.com/)

Demo
----
Try it on [Heroku](http://my-cryptotools.herokuapp.com/).

Running locally
---------------

    bundle install --path vendor/bundle
    bundle exec ./cryptotools.rb

Then, browse to <http://localhost:4567>
