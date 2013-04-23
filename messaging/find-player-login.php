<?php
require_once ("$DOCUMENT_ROOT/bugsy/admin/messaging/inc.messaging.db.funcs.php");

  if (is_player_logged_in ($_REQUEST["id"]))
    echo "Player is logged in";
  else
    echo "Player is not logged in";
?>
