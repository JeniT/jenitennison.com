<?php
  $tq = 'apple, sum(banana), cucumber';
  $tq = preg_replace('/([a-z]+)([, \)$])/', '?$1$2', $tq);
  echo($tq);
?>