<?php
error_reporting(E_ALL ^E_NOTICE);
require_once ('/var/www/siteconf/config.php');
require_once ("$DOCUMENT_ROOT/include/class.db.php");
require_once ("$DOCUMENT_ROOT/include/func.bans.php");
require_once ("my_growler.php");

// crontab entry for this job:
//    58 * * * * php -q /srv/html/dev-jf/bugsy/admin/messaging/cronnie.php
//    58 * * * * php -q ~/work/cronnie.php
$db =& dbGame();
$my_growler =& growler_singleton();
$granularity = "'minute'";
$notice_array = array('priority' => 0, 'sticky' => false);
$date_format = "g:i a";

if ($_SERVER['argc'] == 2)
  if ($_SERVER['argv'][1] == 'reset')
    {
      reset_timed_messages();
      return;
    }

$query = 
    "SELECT text,tab_id,priority,splat_duration,id,current_repetition,max_repetitions,repetition_interval,begin_date ".
    "FROM timed_messages ".
    "WHERE begin_date <= date_trunc($granularity, now()) ".
      "AND current_repetition <= max_repetitions;";

$rows = $db->fetch_array_all($query, DB_ASSOC);

if (sizeof($rows) > 0)
{
  $date_string = "@".date($date_format);
  $message_found = "";
  foreach($rows as $row)
    {
      $result = broadcast_priority_message($row['text'], $row['tab_id'], $row['priority'], $row['splat_duration']);
      if (!$result)
	{
	  $err = ban_get_last_error();
	  // log timestamped $err
	  $my_growler->send_notification('result: '.ban_get_last_error().' '.$row['text'].' '.$row['tab_id'].' '.$row['priority'].' '.$row['splat_duration']);
	}
      else
	{
	  // log timestamped success notification
	}
      $message_found .= "found message#". $row['id']."\n"."repetition #".$row['current_repetition']." of #".$row['max_repetitions']."\n";
      $update = 
	  "UPDATE timed_messages ".
	  "SET current_repetition = ".++$row['current_repetition'].
	    ", begin_date = begin_date + repetition_interval ".
	  "WHERE id = ".$row['id'].";";
      $db->exec($update,PARANOIA_HI);
    }
  $my_growler->send_notification($message_found, $notice_array);
}
else
{
  $my_growler->send_notification("found nothing @".date($date_format), $notice_array);
  //reset_timed_messages();
}
list ($next_date) = $db->fetch_one(
	"SELECT begin_date ".
	"FROM timed_messages ".
	"WHERE current_repetition <= max_repetitions ".
	  "AND begin_date <= date_trunc($granularity, now())+repetition_interval ".
	"ORDER BY begin_date ASC LIMIT 1;",
	PARANOIA_LO);
if (isset($next_date))
  $my_growler->send_notification("Next message will be @".$next_date, $notice_array);


function reset_timed_messages()
{
  Global $granularity, $notice_array;
  $db =& dbGame();
  $my_growler =& growler_singleton();
  $update = 
      "UPDATE timed_messages ".
      "SET current_repetition = 1, ".
	  "begin_date = date_trunc($granularity, now());";
  $db->exec($update,PARANOIA_HI);
  $reset_notice = "found nothing @".date($date_format)."\n"."resetting...";
  $result = print_r($db->fetch_array_all('SELECT id, current_repetition, begin_date FROM timed_messages'),true);
  $my_growler->send_notification($reset_notice, $notice_array);
  //$my_growler->send_notification($result, $notice_array);
  print($reset_notice.$result);
}
?>
