#!/usr/bin/env ruby
require 'rubygems'
require 'rest_client'

filename = '/Users/Jeni/Downloads/index.rdf'
graph    = 'http://source.data.gov.uk/data/reference/organogram-co/2010-06-30'
endpoint = 'http://localhost:8000/data/'

puts "Loading #{filename} into #{graph} in 4store"
response = RestClient.put endpoint + graph, File.read(filename), :content_type => 'application/rdf+xml'
puts "Response #{response.code}: 
#{response.to_str}"
