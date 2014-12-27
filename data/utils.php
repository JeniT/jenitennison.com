<?php
  $store = 'rdfquery-dev1';
  
  function exists($idUri) {
    global $store;
    $host = $_SERVER['HTTP_HOST'];
    $id = "http://$host$idUri";
    $sparql = "ASK { <$id> ?p ?v . }";
    $params = array('query' => $sparql, 'output' => 'json');
    $query = http_build_query($params);
    $request = "http://api.talis.com/stores/$store/services/sparql?$query";
    $resource = file_get_contents($request, 'rb');
    $result = strstr(strstr($resource, '"boolean":'), ':');
    return !strstr($result, 'false');
  }
  
  function error() {
    header('HTTP/1.1 404 Not Found');
    echo <<<EOF
<html>
  <head>
    <title>404 Not Found</title>
  </head>
  <body>
    <h1>404 Not Found</h1>
    <p>No such resource</p>
  </body>
</html>
EOF;
  }
  
  function proxy($type, $limit = 10) {
    global $store;
    $docUri = $_SERVER['REQUEST_URI'];
    // URL for the RDF
    if ($_SERVER['PATH_INFO']) {
      $dir = dirname($_SERVER['SCRIPT_NAME']);
      $path = substr($docUri, strlen($dir));
      $idUri = "$dir/id$path";
      if (exists($idUri)) {
        $domain = $_SERVER['HTTP_HOST'];
        $id = "http://$domain$idUri";
        $params = array('about' => $id, 'output' => 'rdf');
        $query = http_build_query($params);
        $rdfURL = "http://api.talis.com/stores/$store/meta?$query";
      } else {
        error();
        return;
      }
    } else {
      $start = (int)$_GET['start'];
      $sparql = "CONSTRUCT { ?thing a <$type> . ?thing <http://www.w3.org/2000/01/rdf-schema#label> ?label . } WHERE { ?thing a <$type> . OPTIONAL { ?thing <http://www.w3.org/2000/01/rdf-schema#label> ?label . }} ORDER BY ?thing LIMIT $limit OFFSET $start";
      $params = array('query' => $sparql, 'output' => 'rdf');
      $query = http_build_query($params);
      $rdfURL = "http://api.talis.com/stores/$store/services/sparql?$query";
    }
    // URL for the transformation
    $params = array('xml-uri' => $rdfURL, 
      'xsl-uri' => "http://api.talis.com/stores/$store/items/tidyRDF.xsl");
    $query = http_build_query($params);
    $txURL = "http://api.talis.com/tx?$query";
    
    $resource = fopen($txURL, 'rb');
    header("Content-Type: application/rdf+xml", true);
    header("Content-Location: $docUri.rdf", true);
    fpassthru($resource);
    return;
  }
?>