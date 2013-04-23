<?php
require_once ("$DOCUMENT_ROOT/include/class.db.php");
require_once ("$DOCUMENT_ROOT/include/class.pgdb.php");
require_once ("$DOCUMENT_ROOT/bugsy/admin/messaging/inc.messaging.db.funcs.php");
require_once ("$DOCUMENT_ROOT/include/func.bans.php");

$text = $_REQUEST["text"];
$from_id = $_REQUEST["from_id"];
$thread_id = $_REQUEST["thread_id"];
$player_id = $_REQUEST["player_id"];
$cashier_id = $_REQUEST["cashier_id"];
$topic_id = $_REQUEST["topic_id"];

//$result = prepare_message_for_insert ($messageText, $playerID, $replied_to_message_id, $thread_id, $topic_id, $cashier_username, $new_message, $updated_message);
$result = prepare_message_for_insert_admin ($text, $from_id, $thread_id, $player_id, $cashier_id, $topic_id, $new_message, $updated_message);

if ($result)
  admin_message_to_player ($player_id);

  $response = implode ("|", $new_message) . "<|>" . "";
  //if (isset ($updated_message)) $response .= implode ("|", $updated_message); else $response .= "";
  echo $response;

?>
