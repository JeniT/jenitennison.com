#!/usr/bin/env ruby
require 'rubygems'
require 'rest_client'
require 'nokogiri'

query = 'SELECT DISTINCT ?type WHERE { ?thing a ?type . } ORDER BY ?type'
endpoint = 'http://localhost:8000/sparql/'

puts "POSTing SPARQL query to #{endpoint}"
response = RestClient.post endpoint, :query => query
puts "Response #{response.code}"
xml = Nokogiri::XML(response.to_str)

xml.xpath('//sparql:binding[@name = "type"]/sparql:uri', 'sparql' => 'http://www.w3.org/2005/sparql-results#').each do |type|
  puts type.content
end
  