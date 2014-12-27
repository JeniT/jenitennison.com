<?php
  include "utils.php";
  proxy('?point a <http://transport.data.gov.uk/0/ontology/traffic#CountPoint> .
         ?point <http://transport.data.gov.uk/0/ontology/traffic#roadCategory> <http://transport.data.gov.uk/0/category/road/motorway> .
         ?point <http://transport.data.gov.uk/0/ontology/traffic#road> ?road .
         ?road <http://transport.data.gov.uk/0/ontology/roads#number> ?number .
         ?point <http://www.w3.org/2003/01/geo/wgs84_pos#lat> ?lat .
         ?point <http://www.w3.org/2003/01/geo/wgs84_pos#long> ?long .
         ?point <http://transport.data.gov.uk/0/ontology/traffic#count> ?count .
         ?count <http://transport.data.gov.uk/0/ontology/traffic#category> <http://transport.data.gov.uk/0/category/motor-vehicle> .
         ?count <http://transport.data.gov.uk/0/ontology/traffic#direction> ?direction .
         ?count <http://transport.data.gov.uk/0/ontology/traffic#hour> ?hour .
         ?count rdf:value ?value .', 
        '?lat ?long', 
        'transport');
?>