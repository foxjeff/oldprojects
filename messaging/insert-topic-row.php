<?php
  require_once ("$DOCUMENT_ROOT/include/class.db.php");
  require_once ("$DOCUMENT_ROOT/include/class.pgdb.php");

  $topic_text = $_REQUEST["topic_text"];
  
  $pgdb = &staticInstance ("pgdb");
  $retval = $pgdb->insert("message_topics", array("text" => $topic_text), PARANOIA_HI);
  return $retval;
?>
