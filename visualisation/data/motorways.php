<?php
  include "utils.php";
  proxy('?point a <http://transport.data.gov.uk/0/ontology/traffic#CountPoint> .
         ?point <http://transport.data.gov.uk/0/ontology/traffic#roadCategory> <http://transport.data.gov.uk/0/category/road/motorway> .
         ?point <http://transport.data.gov.uk/0/ontology/traffic#road> ?road .
         ?road <http://transport.data.gov.uk/0/ontology/roads#number> ?number .
         ?point <http://www.w3.org/2003/01/geo/wgs84_pos#lat> ?lat .
         ?point <http://www.w3.org/2003/01/geo/wgs84_pos#long> ?long .',
        '?lat ?long', 
        'transport');
?>