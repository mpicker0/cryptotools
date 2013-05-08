#!/usr/bin/env ruby
#

require "sinatra"
require "digest/md5"
require "base64"
require "erb"
require "cgi"
require "zlib"
require "openssl"

set :static => true

title_map = {
  base64: "Base 64 encoding",
  urlencode: "URL encoding",
  websphere: "IBM XOR password encoding (WebSphere)",
  md5sum: "MD5 message digest",
  sha1sum: "SHA1 hashing",
  hex: "Hex encoding",
  x509: "X.509 PEM certificate encoding",
  samlrr: "SAML request/response encoding"
}
 
# index
get "/" do
  erb :index, :locals => {:title => "CryptoTools"}
end

get "/*" do
  resource = params[:splat].first
  erb resource.to_sym, :locals => {:title => title_map[resource.to_sym]}
end

# ciphers/coding
post "/base64" do
  if params[:process] == "Encode"
    output = Base64.encode64(params[:input])
  else
    output = Base64.decode64(params[:input])
  end
  erb :base64, :locals => { 
    :title => title_map[:base64],
    :input => params[:input], 
    :output => output 
    }
end

post "/urlencode" do
  if params[:process] == "Encode"
    # CGI::escape will work here, but encodes spaces as +, not %20
    output = ERB::Util.url_encode(params[:input])
  else
    output = CGI::unescape(params[:input])
  end
  erb :urlencode, :locals => { 
    :title => title_map[:urlencode],
    :input => params[:input], 
    :output => output 
    }
end

post "/websphere" do
  if params[:process] == "Encode" 
    output = "{xor}" + Base64.encode64(params[:input].each_char.collect do |c|
      (c.ord ^ "_".ord).chr
    end.join(""))
  else
    params[:input].sub!("{xor}", "") if params[:input].start_with?("{xor}")
    output = Base64.decode64(params[:input]).each_char.collect do |c|
      (c.ord ^ "_".ord).chr
    end.join("")
  end
  erb :websphere, :locals => { 
    :title => title_map[:websphere],
    :input => "{xor}" + params[:input], 
    :output => output 
    }
end

# hashes
post "/md5sum" do
  erb :md5sum, :locals => { 
    :title => title_map[:md5sum],
    :input => params[:input], 
    :output => Digest::MD5.hexdigest(params[:input]) 
    }
end

post "/sha1sum" do
  erb :sha1sum, :locals => { 
    :title => title_map[:sha1sum],
    :input => params[:input], 
    :output => Digest::SHA1.hexdigest(params[:input]) 
    }
end

# other tools
post "/hex" do
  if params[:process] == "Text to Hex"
    output = params[:input].each_byte.map { |b| b.to_s(16) }.join
  else
    params[:input] = "0" + params[:input] if params[:input].length % 2 != 0
    output = Array(params[:input]).pack("H*")
  end
  erb :hex, :locals => { 
    :title => title_map[:hex],
    :input => params[:input], 
    :output => output 
    }
end

post "/x509" do
  cert = OpenSSL::X509::Certificate.new(params[:input])
  output = cert.to_text
  erb :x509, :locals => { 
    :title => title_map[:x509],
    :input => params[:input], 
    :output => output,
    :cert => cert
    }
end

post "/samlrr" do
  unencoded = CGI::unescape(params[:input])
  unbase64 = Base64.decode64(unencoded)
  output = unbase64[0] == "<" ? unbase64 : 
    Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(unbase64)
  erb :samlrr, :locals => { 
    :title => title_map[:samlrr],
    :input => params[:input], 
    :output => output 
    }
end
