<?php
  include "utils.php";
  proxy('?rMP a <http://guardian.dataincubator.org/ns/MemberOfParliament> .
         ?rMP <http://xmlns.com/foaf/0.1/name> ?mp .
         ?rMP <http://guardian.dataincubator.org/ns/mp-expenses/majority> ?majority .
         ?rMP <http://dbpedia.org/property/constituency> ?rConstituency .
         ?rConstituency rdfs:label ?constituency .
         ?rMP <http://dbpedia.org/property/party> ?rParty .
         ?rConstituency <http://www.w3.org/2003/01/geo/wgs84_pos#lat> ?lat .
         ?rConstituency <http://www.w3.org/2003/01/geo/wgs84_pos#long> ?long .
         ?rMP <http://guardian.dataincubator.org/ns/mp-expenses/total-basic> ?totalBasic .
         ?rMP <http://guardian.dataincubator.org/ns/mp-expenses/total-travel> ?totalTravel .
         ?rMP <http://guardian.dataincubator.org/ns/mp-expenses/additional-costs-allowance> ?additionalCosts .
         ?rMP <http://guardian.dataincubator.org/ns/mp-expenses/total-claim> ?totalClaim .',
        'desc(?totalTravel)', 
        'guardian');
?>