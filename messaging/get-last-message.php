<?php
require_once ("$DOCUMENT_ROOT/bugsy/admin/messaging/inc.messaging.db.funcs.php");

  fetch_one_message_from_db ($_REQUEST["id"], $messages, true);
  
  echo implode ("|", $messages);
?>
