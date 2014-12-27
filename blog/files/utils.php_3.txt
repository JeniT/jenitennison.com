<?php
  function create_contains_call($matches) {
    $string = $matches[1];
    $regex = quotemeta($matches[2]);
    return "regex(str($string), $regex)";
  }

  function create_starts_with_call($matches) {
    $string = $matches[1];
    $regex = quotemeta(substr($matches[2], 1, strlen($matches[2]) - 2));
    return "regex(str($string), '^$regex')";
  }

  function create_ends_with_call($matches) {
    $string = $matches[1];
    $regex = quotemeta(substr($matches[2], 1, strlen($matches[2]) - 2));
    return "regex(str($string), '$regex$')";
  }

  function create_matches_call($matches) {
    $string = $matches[1];
    $regex = substr($matches[2], 1, strlen($matches[2]) - 2);
    return "regex(str($string), '^$regex$')";
  }

  function create_like_call($matches) {
    $string = $matches[1];
    $regex = quotemeta(substr($matches[2], 1, strlen($matches[2]) - 2));
    $regex = str_replace('%', '.*', $regex);
    $regex = str_replace('_', '.', $regex);
    return "regex(str($string), '^$regex$')";
  }

  function create_sameTerm_call($matches) {
    return 'sameTerm(' . $matches[1] . ', <' . $matches[2] . '>)';
  }

  function create_variable_ref($matches) {
    if ($matches[1]) {
      return $matches[1];
    } else if ($matches[2]) {
      return $matches[2];
    } else {
      return '?' . $matches[3] . $matches[4];
    }
  }

  function proxy($where, $order, $store = 'rdfquery-dev1') {
    $start = (int)$_GET['start'];
    $tqx = $_GET['tqx'];
    $tq = $_GET['tq'];
  
    // Parse tq parameter
    $select = '*';
    $tokenised = preg_split('/(select|where|order by|limit|offset) /', $tq, null, PREG_SPLIT_NO_EMPTY | PREG_SPLIT_DELIM_CAPTURE);
    for ($i = 0; $i < count($tokenised); $i += 2) {
      $value = trim($tokenised[$i + 1]);
      switch (trim($tokenised[$i])) {
        case 'select': 
          $select = preg_replace('/([a-z][a-z0-9]*)($|[, \)])/i', '?$1$2', $value);
          $select = str_replace(',', '', $select);
          break;
        case 'where':
          $filter = preg_replace('/ and /', ' && ', $value);
          $filter = preg_replace('/ or /', ' || ', $filter);
          $filter = preg_replace('/ \<\> /', ' != ', $filter);
          $filter = preg_replace("/\\\'/", "'", $filter);
          $filter = preg_replace_callback('/(\'[^\']*\'|[^ ]+) contains (\'[^\']*\'|[^ ]+)/', create_contains_call, $filter);
          $filter = preg_replace_callback('/(\'[^\']*\'|[^ ]+) starts with (\'[^\']*\'|[^ ]+)/', create_starts_with_call, $filter);
          $filter = preg_replace_callback('/(\'[^\']*\'|[^ ]+) ends with (\'[^\']*\'|[^ ]+)/', create_ends_with_call, $filter);
          $filter = preg_replace_callback('/(\'[^\']*\'|[^ ]+) matches (\'[^\']*\'|[^ ]+)/', create_matches_call, $filter);
          $filter = preg_replace_callback('/(\'[^\']*\'|[^ ]+) like (\'[^\']*\'|[^ ]+)/', create_like_call, $filter);
          $filter = preg_replace_callback('/(\'[^\']+\')|(\<[^\<]+\>)|([a-z][a-z0-9]*)($|[, \)])/i', create_variable_ref, $filter);
          $filter = " FILTER ( $filter ) ";
          break;
        case 'order by':
          $order = preg_replace('/([a-z][a-z0-9]*) (asc|desc)/i', '$2($1)', $value);
          $order = preg_replace('/([a-z][a-z0-9]*)($|[, \)])/i', '?$1$2', $order);
          $order = str_replace(',', '', $order);
          break;
        case 'limit': 
          $limit = " LIMIT $value";
          break;
        case 'offset';
          $offset = " OFFSET $value";
          break;
      }
    }
    $sparql = "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> SELECT DISTINCT $select WHERE { $where $filter } ORDER BY $order $limit $offset";
    
    //echo("<p>tq: $tq</p>");
    //echo("<p>sparql: $sparql</p>");

    $params = array('query' => $sparql, 'output' => 'xml');
    $query = http_build_query($params);
    $rdfURL = "http://api.talis.com/stores/$store/services/sparql?$query";

    /*
    $resource = fopen($rdfURL, 'rb');
    header('Content-Type: application/xml', true);
    fpassthru($resource);
    return;
    */

    // URL for the transformation
    $params = array('xml-uri' => $rdfURL, 
      'xsl-uri' => "http://www.jenitennison.com/visualisation/data/SRXtoGoogleVisData.xsl",
      'tqx' => $tqx);
    $query = http_build_query($params);
    $txURL = "http://api.talis.com/tx?$query";

    $resource = fopen($txURL, 'rb');
    header('Content-Type: application/json', true);
    fpassthru($resource);
    return;
  }
?>