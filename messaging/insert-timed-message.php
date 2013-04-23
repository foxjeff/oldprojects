<?php
require_once ("$DOCUMENT_ROOT/include/class.db.php");

$text = db_quote($_REQUEST["text"]);
$tab_id = $_REQUEST["tab_id"];
$priority = $_REQUEST["priority"];
$splat_duration = $_REQUEST["splat_duration"];
$start_date = db_quote($_REQUEST["start_date"]);
$repetition_interval = db_quote($_REQUEST["repetition_interval"]);
$max_repetitions = db_quote($_REQUEST["max_repetitions"]);

$db =& dbGame();
$insert = 'INSERT INTO timed_messages '.
	      '(text, tab_id, priority, splat_duration, begin_date, repetition_interval, max_repetitions) '.
	    "VALUES ($text, $tab_id, $priority, $splat_duration, $start_date, $repetition_interval, $max_repetitions);";
$result = $db->exec($insert,PARANOIA_HI);
return $result;
?>
