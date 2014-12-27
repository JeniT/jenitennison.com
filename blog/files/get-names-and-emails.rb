#!/usr/bin/env ruby
require 'rubygems'
require 'net/http'
require 'rdf'

query = "PREFIX foaf: <http://xmlns.com/foaf/0.1/>

CONSTRUCT {
  ?person 
    a foaf:Person ;
    foaf:name ?name ;
    ?prop ?value .
} WHERE { 
  ?person a foaf:Person ;
    foaf:name ?name ;
    ?prop ?value .
}"
endpoint = URI.parse('http://localhost:8000/sparql/')

puts "Sending POST SPARQL query to #{endpoint.host}:#{endpoint.port}"
request = Net::HTTP::Post.new(endpoint.path, {'Accept' => 'text/plain'})
request.set_form_data({'query' => query}, ';')
response = Net::HTTP.new(endpoint.host, endpoint.port).start {|http| http.request(request) }
puts "Response #{response.code} #{response.message}"

graph = RDF::Graph.new
RDF::Reader.for(:ntriples).new(response.body) do |reader|
  reader.each_statement do |statement|
    graph.insert(statement)
  end
end

puts "\nLoaded #{graph.count} triples\n"

rdf = RDF::Vocabulary.new('http://www.w3.org/1999/02/22-rdf-syntax-ns#')
foaf = RDF::Vocabulary.new('http://xmlns.com/foaf/0.1/')

query = RDF::Query.new({
  :person => {
    rdf.type  => foaf.Person,
    foaf.name => :name,
    foaf.mbox => :email,
  }
})

people = {}
query.execute(graph).each do |person|
  people[person.name.to_s] = person.email.to_s
end
puts "\nCreating directory of #{people.length} people"

stott_email = people['Andrew Stott']
puts "\nAndrew Stott's email address: #{stott_email}"