#!/usr/bin/env ruby
require 'rubygems'
require 'net/http'
require 'nokogiri'

query = 'SELECT DISTINCT ?type WHERE { ?thing a ?type } ORDER BY ?type'
endpoint = URI.parse('http://localhost:8000/sparql/')

puts "Sending POST SPARQL query to #{endpoint.host}:#{endpoint.port}"
response = Net::HTTP.post_form(endpoint, {'query' => query})
puts "Response #{response.code} #{response.message}"
xml = Nokogiri::XML(response.body)

xml.xpath('//sparql:binding[@name = "type"]/sparql:uri', 'sparql' => 'http://www.w3.org/2005/sparql-results#').each do |type|
  puts type.content
end
