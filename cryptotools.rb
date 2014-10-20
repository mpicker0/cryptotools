#!/usr/bin/env ruby
#

require "rubygems"
require "bundler/setup"

require "sinatra"
require "digest/md5"
require "base64"
require "haml"
require "cgi"
require "zlib"
require "openssl"

set :static => true

title_map = {
  base64: "Base 64 encoding",
  urlencode: "URL encoding",
  websphere: "IBM XOR password encoding (WebSphere)",
  stashfile: "IBM stash file decoding",
  md5sum: "MD5 message digest",
  sha1sum: "SHA1 hashing",
  hex: "Hex encoding",
  x509: "X.509 PEM certificate encoding",
  samlrr: "SAML request/response encoding"
}
 
# index
get "/" do
  haml :index, locals: {title: "CryptoTools"}
end

get "/*" do
  resource = params[:splat].first
  haml resource.to_sym, :locals => {title: title_map[resource.to_sym]}
end

# ciphers/coding
post "/base64" do
  if params[:process] == "Encode"
    output = Base64.strict_encode64(params[:input])
  else
    output = Base64.decode64(params[:input])
    hex = Base64.decode64(params[:input]).each_byte.map { |b| b.to_s(16) }.join
  end
  haml :base64, locals: {
    title: title_map[:base64],
    input: params[:input], 
    output: output,
    hex: hex
  }
end

post "/urlencode" do
  if params[:process] == "Encode"
    # CGI::escape will work here, but encodes spaces as +, not %20
    output = ERB::Util.url_encode(params[:input])
  else
    output = CGI::unescape(params[:input])
  end
  haml :urlencode, locals: { 
    title: title_map[:urlencode],
    input: params[:input], 
    output: output 
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
  haml :websphere, locals: { 
    title: title_map[:websphere],
    input: "{xor}" + params[:input], 
    output: output 
    }
end

post "/stashfile" do
  output = ""
  Base64.decode64(params[:input]).each_char.collect do |c|
    decoded_char = c.ord ^ 0xf5
    if decoded_char == 0
      break
    end
    output += decoded_char.chr
  end
  haml :stashfile, locals: { 
    title: title_map[:stashfile],
    input: params[:input], 
    output: output
    }
end

# hashes
post "/md5sum" do
  haml :md5sum, locals: { 
    title: title_map[:md5sum],
    input: params[:input], 
    output: Digest::MD5.hexdigest(params[:input]) 
    }
end

post "/sha1sum" do
  haml :sha1sum, locals: { 
    title: title_map[:sha1sum],
    input: params[:input], 
    output: Digest::SHA1.hexdigest(params[:input]) 
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
  haml :hex, locals: { 
    title: title_map[:hex],
    input: params[:input], 
    output: output 
    }
end

post "/x509" do
  if not params[:input].index("\n") or params[:input].index("\n") > 77
    params[:input] = params[:input].scan(/.{1,77}/).join("\n")
  end
  if not params[:input].start_with?("-----BEGIN CERTIFICATE-----")
    params[:input] = "-----BEGIN CERTIFICATE-----\n#{params[:input]}\n-----END CERTIFICATE-----"
  end
  cert = OpenSSL::X509::Certificate.new(params[:input])
  output = cert.to_text
  class << cert
    attr_accessor :md5_thumbprint, :sha1_thumbprint
  end
  cert.md5_thumbprint = Digest::MD5.hexdigest(cert.to_der).scan(/../).join(":")
  cert.sha1_thumbprint = Digest::SHA1.hexdigest(cert.to_der).scan(/../).join(":")
  haml :x509, locals: { 
    title: title_map[:x509],
    input: params[:input], 
    output: output,
    cert: cert
    }
end

post "/samlrr" do
  unencoded = CGI::unescape(params[:input])
  unbase64 = Base64.decode64(unencoded)
  output = unbase64[0] == "<" ? unbase64 : 
    Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(unbase64)
  haml :samlrr, locals: { 
    title: title_map[:samlrr],
    input: params[:input], 
    output: output 
    }
end
