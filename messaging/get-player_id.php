<?php
require_once ("$DOCUMENT_ROOT/bugsy/admin/messaging/inc.messaging.db.funcs.php");

  if ($_REQUEST["id"])
    echo get_player_name_from_id ($_REQUEST["id"]);
  else
    echo get_player_id_from_name ($_REQUEST["name"], true);
  
?>
