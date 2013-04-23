<?php
  require_once ("$DOCUMENT_ROOT/bugsy/admin/messaging/inc.messaging.db.funcs.php");

  $rows_to_remove = explode (",", $_REQUEST["rows_to_remove"]);
  
  echo delete_rows_from_db ($rows_to_remove);
?>
