<?php
  include "utils.php";
  $docUri = $_SERVER['REQUEST_URI'];
  $dir = dirname($_SERVER['SCRIPT_NAME']);
  $path = substr($docUri, strlen($dir));
  $idUri = "$dir/id$path";
  if (exists($idUri)) {
    $domain = $_SERVER['HTTP_HOST'];
    
    // URL for the RDF
    $id = "http://$domain$idUri";
    $params = array('about' => $id, 'output' => 'rdf');
    $query = http_build_query($params);
    $rdfURL = "http://api.talis.com/stores/$store/meta?$query";
    
    // URL for the transformation
    $params = array('xml-uri' => $rdfURL, 
      'xsl-uri' => "http://api.talis.com/stores/$store/items/tidyRDF.xsl");
    $query = http_build_query($params);
    $txURL = "http://api.talis.com/tx?$query";
    
    $resource = fopen($txURL, 'rb');
    header("Content-Type: application/rdf+xml");
    header("Content-Location: $docUri.rdf");
    fpassthru($resource);
    return;
  } else {
    error(404);
  }
?>