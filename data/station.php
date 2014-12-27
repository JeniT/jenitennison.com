<?php
  $path = explode("/", $HTTP_SERVER_VARS['PATH_INFO']);
  $tlc = $path[1];
  $id = "http://www.data.gov.uk/id/station/$tlc";
  $params = array('about' => $id, 'output' => 'xml');
  $query = http_build_query($params);
  $request = "http://api.talis.com/stores/rdfquery-dev1/meta?$query";
  //echo $request;
  $resource = fopen($request, 'rb');
  header("Content-Type: application/rdf+xml");
  header("Content-Location: /data/station/$tlc.rdf");
  fpassthru($resource);
  exit;
?>