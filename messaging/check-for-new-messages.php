<?php
require_once ("$DOCUMENT_ROOT/bugsy/admin/messaging/inc.messaging.db.funcs.php");

  $lastMessageID = $_REQUEST["lastMessageID"];
  echo new_messages_yes_no ($lastMessageID);
?>
