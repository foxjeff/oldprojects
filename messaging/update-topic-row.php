<?php
  require_once ("$DOCUMENT_ROOT/include/class.db.php");
  require_once ("$DOCUMENT_ROOT/include/class.pgdb.php");

  $topic_id = $_REQUEST["topic_id"];
  $topic_text = $_REQUEST["topic_text"];
  
  $pgdb = &staticInstance ("pgdb");
  $retval = $pgdb->update("message_topics", array("text" => $topic_text), array("id" => $topic_id), array (), PARANOIA_HI);
  return $retval;
?>
