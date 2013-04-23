<?php

//error_reporting(E_ALL);	// ^ E_NOTICE);
require_once ("$DOCUMENT_ROOT/include/class.db.php");
require_once ("$DOCUMENT_ROOT/include/class.pgdb.php");

function permanently_delete_all_rows_from_db ()
{
  $pgdb = &staticInstance ("pgdb");
  $delete_messages = "DELETE FROM messages;";
  $delete_threads = "DELETE FROM message_threads;";
  $retval = $pgdb->exec ($delete_messages, PARANOIA_LO);
  $result = "Messages and threads have NOT been deleted";
  if ($retval)
    {
      $retval = $pgdb->exec ($delete_threads, PARANOIA_LO);
      if ($retval)
	$result = "All messages and threads have been deleted";
    }
  return $result;
}
function delete_thread_rows_from_db ($rows_to_remove)
{
  $result = "";
  $pgdb = &staticInstance ("pgdb");
  foreach ($rows_to_remove as $row)
    {
      $query = "UPDATE messages SET deleted = true WHERE thread_id = $row;";
      $retval = $pgdb->exec ($query, PARANOIA_LO);
      if (!$retval)
	$result .= "Message #$row was NOT removed; ";
      else
	$result .= "Message #$row was removed; ";
    }
  return $result;
}
function delete_rows_from_db ($rows_to_remove)
{
  $result = "";
  $pgdb = &staticInstance ("pgdb");
  foreach ($rows_to_remove as $row)
    {
      $query = "UPDATE messages SET deleted = true WHERE id = $row;";
      $retval = $pgdb->exec ($query, PARANOIA_LO);
      if (!$retval)
	$result .= "Message #$row was NOT removed; ";
      else
	$result .= "Message #$row was removed; ";
    }
  return $result;
}
function delete_topic_rows_from_db ($rows_to_remove)
{
  $result = "";
  $pgdb = &staticInstance ("pgdb");
  foreach ($rows_to_remove as $row)
    {
      $query = "DELETE FROM message_topics WHERE id = $row;";
      $retval = $pgdb->exec ($query, PARANOIA_LO);
      if (!$retval)
	$result .= "Topic #$row was NOT removed; ";
      else
	$result .= "Topic #$row was removed; ";
    }
  return $result;
}
function new_messages_yes_no ($lastMessageID)
{
  $pgdb = &staticInstance ("pgdb");
  $query = "SELECT max(id) FROM messages WHERE deleted = false;";
  list ($maxID) = $pgdb->fetch_one ($query);
  return ((int)$maxID > (int)$lastMessageID);
}
function update_cashier_in_thread ($thread_id, $new_cashier_id)
{
  $pgdb = &staticInstance ("pgdb");
  $query = "BEGIN;";
  $pgdb->exec ($query, PARANOIA_HI);

  $query = "SELECT cashier_id FROM message_threads WHERE id = $thread_id;";
  list ($existing_cashier_id) = $pgdb->fetch_one ($query, PARANOIA_HI);
  if ($existing_cashier_id == 0)
    {
      $update = "UPDATE message_threads SET cashier_id = $new_cashier_id WHERE id = $thread_id;";
      $pgdb->exec ($update, PARANOIA_HI);
    }
  $query = "COMMIT;";
  $pgdb->exec ($query, PARANOIA_HI);
  
}
function insert_new_message_and_thread ($_text, $_from_id, $_player_id, $_cashier_id, $_topic_id)
{
  $pgdb = &staticInstance ("pgdb");
  $query = "BEGIN;";
  $pgdb->exec ($query, PARANOIA_HI);

  $new_thread_id = get_new_thread_id ();
  $player_id = db_quote ($_player_id);
  $cashier_id = db_quote ($_cashier_id);
  $topic_id = db_quote ($_topic_id);

  $threads_insert = "INSERT INTO message_threads (id, player_id, cashier_id, topic_id) " .
				      "VALUES ($new_thread_id, $player_id, $cashier_id, $topic_id);";
  $pgdb->exec ($threads_insert, PARANOIA_HI);

  $text = db_quote ($_text);
  $from_id = db_quote ($_from_id);
  $new_message_id = insert_new_message ($text, $from_id, $new_thread_id, true);

  $query = "COMMIT;";
  $pgdb->exec ($query, PARANOIA_HI);
  
  return $new_message_id;
}
function insert_new_message ($text, $from_id, $thread_id, $insert_in_progess = false)
{
  $pgdb = &staticInstance ("pgdb");
  if (!$insert_in_progess)
    {
      $query = "BEGIN;";
      $pgdb->exec ($query, PARANOIA_HI);
    }

  $new_message_id = get_new_message_id ();

  $messages_insert = "INSERT INTO messages (id, text, from_id, thread_id) " .
				  "VALUES ($new_message_id, $text, $from_id, $thread_id);";
  $pgdb->exec ($messages_insert, PARANOIA_HI);

  if (!$insert_in_progress)
    {
      $query = "COMMIT;";
      $pgdb->exec ($query, PARANOIA_HI);
    }
  return $new_message_id;
}
function get_new_message_id ()
{
  $pgdb = &staticInstance ("pgdb");
  $query = "SELECT nextval('message_id_seq');";
  $result = $pgdb->exec ($query, PARANOIA_HI, 1);
  list($new_message_id) = $pgdb->fetch_row ($result);
  return $new_message_id;
}
function update_replied_to_message ($new_thread_id, $replied_to_message_id)
{
  $pgdb = &staticInstance ("pgdb");
  $query = ("UPDATE messages SET thread_id = " . db_quote($new_thread_id) . " WHERE id = " . db_quote($replied_to_message_id) . ";");
  $result = $pgdb->exec($query, PARANOIA_HI, 0);
}
function get_new_thread_id ()
{
  $pgdb = &staticInstance ("pgdb");
  $query = "SELECT nextval('thread_id_seq');";
  $result = $pgdb->exec ($query, PARANOIA_HI, 1);
  list($new_thread_id) = $pgdb->fetch_row($result);
  return $new_thread_id;
}
function get_player_id_from_name ($player_name, $verfied = false)
{
  $player_id = null;
  $pgdb = &staticInstance ("pgdb");
  $query = ("SELECT id FROM players WHERE upper(name) = upper(" . db_quote ($player_name) . ");");
  if (!$verfied)
  {
    list ($player_id) = $pgdb->fetch_one ($query, PARANOIA_HI);
  }
  else
    {
      $result = $pgdb->exec ($query, PARANOIA_HI);
      list($player_id) = $pgdb->fetch_row ($result);
    }
  return $player_id;
}
function prepare_message_for_insert_admin ($text, $from_id, $thread_id, $player_id, $cashier_id, $topic_id, &$new_message, &$updated_message) {
  // called from admin's send-message-from-admin.php
  if ($thread_id == 0)
    {
      $new_message_id = insert_new_message_and_thread ($text, $from_id, $player_id, $cashier_id, $topic_id);
    }
  else
    {
      $new_message_id = insert_new_message (db_quote ($text), $from_id, $thread_id);
      update_cashier_in_thread ($thread_id, $cashier_id);
    }
  // now fetch the new message
  fetch_one_message_from_db ($new_message_id, $new_message, true);
  return true;
  
  $old_thread_id = $thread_id;

  //fix this
  if ($player_id == 0) {  // means this is a new message and player_id is not yet known
    $player_name = $player_id; // rotten, i know
    $player_id = get_player_id_from_name ($player_name);
  }
  $result = insert_new_message ($text, $player_id, $thread_id, $topic_id, $cashier_username);
  if ($result)
    {
      $retval = true;
      fetch_one_message_from_db ($new_message_id, $new_message, true);
      if ($old_thread_id == 0 && $replied_to_message_id != 0) 
	fetch_one_message_from_db ($replied_to_message_id, $updated_message, true);
    }
  else
    {
      $retval = false;
    }

  return $retval;
}

function fetch_one_message_from_db ($message_id, &$msg, $with_name=false)
{
  $pgdb = &staticInstance ("pgdb");

  if ($with_name)
    $query = ("SELECT mv.id, mv.text, date_trunc('second',mv.received_date) AS received_date, " .
		"p1.name, mv.thread_id, mv.topic_id, mtop.text AS topic_text, p2.name AS cashier_username " .
		"FROM messages_view mv, players p1, players p2, message_topics mtop " .
		"WHERE mv.topic_id = mtop.id AND mv.player_id = p1.id AND mv.cashier_id = p2.id AND mv.id = $message_id;");
  else
    $query = "SELECT mv.id, mv.text, date_trunc('second',mv.received_date) AS received_date, mv.player_id, mv.thread_id, mv.topic_id, mtop.text as topic_text, COALESCE(p.name, 'No Cashier') as cashier_username FROM message_topics mtop, messages_view mv LEFT JOIN players AS p ON mv.cashier_id = p.id WHERE mv.topic_id = mtop.id AND mv.id = $message_id ;";
    //$query = ("SELECT mv.id, mv.text, date_trunc('second',mv.received_date) AS received_date, " .
		//"mv.player_id, mv.thread_id, mv.topic_id, mtop.text AS topic_text, p.name AS cashier_username " .
		//"FROM messages_view mv, players p, message_topics mtop " .
		//"WHERE mv.topic_id = mtop.id AND mv.cashier_id = p.id AND mv.id = $message_id;");

  $message = $pgdb->fetch_one ($query, PARANOIA_HI);
  if ($message)
    {
      $retval = true;
      $msg = $message;
    }
  else
    {
      $retval = false;
      $msg = "Query failed ($query) :" . $pgdb->error ();
    }

  return $retval;
}

function fetch_messages_from_db ($player_name, &$msg)
{
  $mark_read_update = "";
  $pgdb = &staticInstance ("pgdb");

  if ($player_name == "")
    {
      $query = "SELECT mv.id, mv.text, date_trunc('second',mv.received_date) AS received_date,p1.name, mv.thread_id, mv.topic_id, mtop.text as topic_text, COALESCE(p2.name, 'No Cashier') AS cashier_username FROM players p1, message_topics mtop, messages_view mv LEFT JOIN players as p2 ON mv.cashier_id = p2.id WHERE mv.player_id = p1.id AND mv.topic_id = mtop.id AND mv.deleted = false ORDER BY mv.id DESC;";
      //$mark_read_update = "UPDATE messages SET read = true FROM message_threads mtrh WHERE from_id != mthr.cashier_id;";
    }
  else
    {
      $player_id = get_player_id_from_name ($player_name);
      $query = "SELECT mv.id, mv.text, date_trunc('second',mv.received_date) AS received_date, mv.player_id, mv.thread_id, mv.topic_id, mtop.text as topic_text, COALESCE(p.name, 'No Cashier') as cashier_username FROM message_topics mtop, messages_view mv LEFT JOIN players AS p ON mv.cashier_id = p.id WHERE mv.topic_id = mtop.id AND mv.deleted = false AND mv.player_id = $player_id ORDER BY mv.id DESC;";
      $mark_read_update = "UPDATE messages SET read = true FROM message_threads mthr " .
			  "WHERE thread_id = mthr.id AND mthr.player_id = $player_id AND from_id != $player_id;";
    }
  $messageArray = $pgdb->fetch_array_all ($query, DB_ASSOC, PARANOIA_HI);
  if ($mark_read_update != "")
    $retval = $pgdb->exec ($mark_read_update, PARANOIA_LO);

  if ($messageArray)
    {
      $retval = true;
      $msg = $messageArray;
    }
  else
    {
      $retval = false;
      $msg = "Query failed ($query) :" . $pgdb->error ();
    }

  return $retval;
}
function is_player_logged_in ($player_id)
{
  $pgdb = &staticInstance ("pgdb");
  $query = ("SELECT player_id FROM logins, players WHERE players.id=logins.player_id AND"
	  . " out_time is NULL AND players.id=" . db_quote ($player_id) . " ORDER BY in_time DESC LIMIT 1;");
  $result = $pgdb->exec ($query, PARANOIA_HI);
  if ($pgdb->num_rows ($result) != 1)
    $retval = false;
  else
    $retval = true;
  return $retval;
}
function fetch_message_topics (&$topics)
{
  $pgdb = &staticInstance ("pgdb");
  $query = ("SELECT id AS topic_id, text AS topic_text FROM message_topics ORDER BY id;");
  $messageArray = $pgdb->fetch_array_all ($query, DB_ASSOC, PARANOIA_HI);
  if ($messageArray)
    {
      $retval = true;
      $topics = $messageArray;
    }
  else
    {
      $retval = false;
      $topics = "Query failed ($query) :" . $pgdb->error ();
    }
  return $retval;
}
?>
