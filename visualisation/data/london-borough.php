<?php
  include "utils.php";
  proxy('?borough a <http://www.jenitennison.com/ontology/data#LondonBorough> .
         ?borough <http://www.w3.org/2000/01/rdf-schema#label> ?label .
         ?borough <http://www.jenitennison.com/ontology/data#maleLifeExpectancy> ?maleLE .
         ?borough <http://www.jenitennison.com/ontology/data#femaleLifeExpectancy> ?femaleLE .', 
        '?label');
?>