#!/usr/bin/env ruby
require 'net/http'

file = File.new('/Users/Jeni/Downloads/index.rdf', 'r')
graph = 'http://source.data.gov.uk/data/reference/2010-06-30'
uri = URI.parse('http://localhost:8000/data/' + graph)

puts "Sending PUT #{uri.request_uri} to #{uri.host}:#{uri.port}"
Net::HTTP.start(uri.host, uri.port) do |http|
  headers = {'Content-Type' => 'application/rdf+xml'}
  put_data = file.read
  response = http.send_request('PUT', uri.request_uri, put_data, headers)
  puts "Response #{response.code} #{response.message}: 
#{response.body}"
end
