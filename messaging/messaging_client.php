<?php
require_once ('/var/www/siteconf/config.php');
require_once ("$DOCUMENT_ROOT/include/class.db.php");
require_once ("$DOCUMENT_ROOT/bugsy/admin/includes/inc.check-admin-auth.php");
require_once ("$DOCUMENT_ROOT/include/pear/JSON.php");

$cashier_username = $_SESSION["userName"]; 
$cashiers_list = Array("CASH1STARNYA","CASH2SKATHRYN","CASH4SCARMEN","SECURE1SDAVE","FARFEL2","FARFEL");
$cashier_id = $_SESSION["userID"]; 
//echo $cashier_id.$cashier_username;
//if ($cashier_username == null)
//{
  //$cashier_id = 55;
  //$cashier_username = "x55";
//}
$lastMessageID = 0;
$last_reply = Array();
$last_told = Array();
$db =& dbGame();
$begin = 'BEGIN;';
$commit = 'COMMIT;';
$db->exec ($begin);

$query = "SELECT DISTINCT
	    COALESCE(p2.name, 'No_Cashier') as cashier,
	    p.name AS player,
	    mt.text AS topic,
	    mv.cashier_id as cashier_id,
	    mv.thread_id AS thread_id
	  FROM
	    players p,
	    message_topics mt,
	    messages_view mv
	  LEFT JOIN
	    players p2
	  ON
	    mv.cashier_id = p2.id
	  WHERE
	    deleted=false
	    AND mv.player_id = p.id
	    AND mv.topic_id = mt.id
	  ORDER BY
	    mv.thread_id DESC
	  ;";
$threads = $db->fetch_array_all ($query, DB_ASSOC);

$query = "SELECT
	    p.name AS from,
	    date_trunc('minute',mv.received_date) AS date,
	    mv.text AS text,
	    mv.thread_id AS thread_id,
	    mv.id AS message_id,
	    mv.from_id as from_id,
	    mv.topic_id AS topic_id
	  From
	    messages_view mv,
	    players p
	  WHERE
	    deleted=false
	    AND mv.from_id = p.id
	  ORDER BY
	    mv.id DESC;
	  ";
$messages = $db->fetch_array_all ($query, DB_ASSOC);
$db->exec ($commit);

$json = new Services_JSON();
$json_threads = $json->encode($threads);
$json_messages = $json->encode($messages);
print <<<EOF

<html>
<head>

<script type='text/javascript' src="/javascript/prototype.js"></script>
<script type='text/javascript' src="/javascript/scriptaculous.js"></script>
<script type="text/javascript" language="javascript" src="fancy-and-timers.js"></script>
<script type='text/javascript'>

var _threads = $json_threads;
var _messages = $json_messages;
var _cashier_id = $cashier_id;

var checkForNewMessagesTimeoutID;
var lastMessageID = -1;
function checkForNewMessages ()
{
  clearTimeout (checkForNewMessagesTimeoutID);
  if (lastMessageID == -1)  // first time only
    {
      lastMessageID = parseInt(document.getElementById ("lastMessageID").innerHTML);
      checkForNewMessagesTimeoutID = setTimeout ("checkForNewMessages()", 5000);  // try again in 5 seconds
    }
  else
    {
      lastMessageID = parseInt(document.getElementById ("lastMessageID").innerHTML);
      //alert('lmid= ' + lastMessageID);
      new Ajax.Request('/bugsy/admin/messaging/check-for-new-messages.php',
	{
	  asynchronous: true,
	  method: 'post',
	  parameters:   'lastMessageID=' + lastMessageID,
	  onSuccess: function(request)
	    {
	      finishCheckingForNewMessages(request.responseText);
	    },
	  onFailure: function(request)
	    {
	      alert('checkForNewMessages failed: ' + request.responseText);
	    }
	});
    }
}
function finishCheckingForNewMessages (result)
{
  clearTimeout (checkForNewMessagesTimeoutID);
  if (result == true)
    {
      document.getElementById ("hot1").style.display = "";
      cycleColors ();
    }
  else
    {
      checkForNewMessagesTimeoutID = setTimeout ("checkForNewMessages()", 50000);  // try again in 50 seconds
    }
}
function doPageRefresh ()
{
  window.location.href = document.URL;
}
function show_thread_messages(message_thread_id, row_id, reply_thread_id)
{
  thread_row = \$(row_id);
  if (Element.hasClassName(thread_row, 'expanded'))
    {
      Element.removeClassName(thread_row, 'expanded');
      Element.hide(message_thread_id);	//Element.show("$message_thread_id");
    }
  else
    {
      Element.addClassName(thread_row, 'expanded');
      Element.show(message_thread_id);	//Element.show("$message_thread_id");
    }
  //if (Element.hasClassName(reply_thread_id, 'make_it_red'))
    //Element.removeClassName(reply_thread_id, 'make_it_red');
}

function hide_all()
{
  thread_rows = document.getElementsByClassName('expanded');
  thread_rows.each(function(thread_row)
    {
      Element.removeClassName(thread_row, 'expanded');
    });
  messages = document.getElementsByClassName('message_class');
  messages.each(function(message)
    {
      Element.hide(message);
    });
}

function show_all()
{
  current_cashier = \$('cashiers').value;
  new_cashier_class = 'message_cashier_'+cashiers_array[current_cashier];

  messages = document.getElementsByClassName('message_class');
  messages.each(function(message)
    {
      if (Element.hasClassName(message, new_cashier_class) || cashiers_array[current_cashier] == 'All_Cashiers')
	Element.show(message);
    });
  thread_rows_odd = document.getElementsByClassName('highlightOffOdd');
  thread_rows = thread_rows_odd.concat(document.getElementsByClassName('highlightOffEven'));
  thread_rows.each(function(thread_row)
    {
      Element.addClassName(thread_row, 'expanded');
    });
}

var current_palette = 0;
// objectify this array
var palettes = ['message_toggle_black','message_toggle_black','message_toggle_white','message_toggle_white','message_toggle_white'];

function cycle_colors(incoming)
{
  old_palette = current_palette;
  if (incoming >=0 && incoming <= 4)
    old_palette, current_palette = incoming;
  else
    {
      current_palette = ((++current_palette > 4) ? 0 : current_palette);
    }
  palette = palettes[current_palette];

  Element.removeClassName('thread_table_header', 'thread_table_header' + old_palette);
  Element.addClassName('thread_table_header', 'thread_table_header' + current_palette);

  thread_rows_odd = document.getElementsByClassName('highlightOdd' + old_palette);
  thread_rows_odd.each(function(thread_row)
    {
      Element.removeClassName(thread_row, 'highlightOdd' + old_palette);
      Element.addClassName(thread_row, 'highlightOdd' + current_palette);
    });
  thread_rows_even = document.getElementsByClassName('highlightEven' + old_palette);
  thread_rows_even.each(function(thread_row)
    {
      Element.removeClassName(thread_row, 'highlightEven' + old_palette);
      Element.addClassName(thread_row, 'highlightEven' + current_palette);
    });

  message_toggle_rows = document.getElementsByClassName('message_toggle_black');
  if (message_toggle_rows.length == 0)
    message_toggle_rows = document.getElementsByClassName('message_toggle_white');

  if (palette == 'message_toggle_black')
    {
      new_toggle_color = 'message_toggle_black';
      old_toggle_color = 'message_toggle_white';
    }
  else
    {
      new_toggle_color = 'message_toggle_white';
      old_toggle_color = 'message_toggle_black';
    }
  message_toggle_rows.each(function(message_toggle_row, rownum)
    {
      Element.removeClassName(message_toggle_row, old_toggle_color);
      Element.addClassName(message_toggle_row, new_toggle_color);
    });

  give_cookie(current_palette);
}
function give_cookie(current_palette)
{
  document.cookie = "current_palette =" + current_palette;
}

function get_cookie()
{
  cookie = 0;
  cookies = document.cookie;
  cookies = \$A(cookies.split(';'));
  cookies.each(function(_cookie)
    {
      if (_cookie.indexOf('current_palette') == 0)
	{
	  _cookie = _cookie.split('=');
	  cookie = _cookie[1];
	}
    })
  
  cycle_colors(cookie);
}

var current_cashier = -1;
var cashiers_array = ["$cashier_username", 'No_Cashier', 'All_Cashiers'];
function select_cashier_toggle()
{
  hide_all();
  current_cashier = ((++current_cashier > 2) ? 0 : current_cashier);
  \$('cashiers').value = current_cashier;
  filter_by_cashier();
}
function select_cashier_widget(evt)
{
  hide_all();
  current_cashier = \$('cashiers').value;
  filter_by_cashier();
}
function filter_by_cashier()
{
  new_cashier = cashiers_array[current_cashier];
  all_cashier_rows = document.getElementsByClassName('cashier');
  all_cashier_rows.each(function(row)
    {
      Element.hide(row);
    });
  if (new_cashier == 'All_Cashiers')
    {
      all_cashier_rows.each(function(row, rownum)
	{
	  rehighlight_row(row, rownum);
	  Element.show(row);
	});
    }
  else
    {
      new_cashier_rows = all_cashier_rows.findAll(function(cashier_row)
	{
	  return Element.hasClassName(cashier_row, new_cashier);
	});
      new_cashier_rows.each(function(row, rownum)
	{
	  rehighlight_row(row, rownum);
	  Element.show(row);
	});
    }
}
function rehighlight_row(row, rownum)
{
  Element.removeClassName(row, 'highlightEven' + current_palette);
  Element.removeClassName(row, 'highlightOdd' + current_palette);
  if ((rownum % 2) == 1)
    {
      Element.addClassName(row, 'highlightOdd' + current_palette);
    }
  else
    {
      Element.addClassName(row, 'highlightEven' + current_palette);
    }
}

var isChecked = false;
function toggle_checked()
{
  toggle_checkbox = \$('toggle_checkbox');
  if (toggle_checkbox.checked)
      check_all_rows();
  else
      uncheck_all_rows();
}
function check_all_rows()
{
  inputs = document.getElementsByTagName("input");
  //inputs = document.messageDataForm.elements;
  for (var i = 0; i < inputs.length; i++) {
    if (inputs[i].type == "checkbox") {
      inputs[i].checked = true;
    }
  }
}
function uncheck_all_rows()
{
  inputs = document.getElementsByTagName("input");
  for (var i = 0; i < inputs.length; i++) {
    if (inputs[i].type == "checkbox") {
      inputs[i].checked = false;
    }
  }
}
function remove_checked_rows()
{
  rows_to_remove = new Array();
  inputs = document.getElementsByTagName("input");
  for (var i = 0; i < inputs.length; i++) {
    if (inputs[i].type == "checkbox" && inputs[i].checked) {
      rows_to_remove.push(inputs[i].id.match(/\d+/));
    }
  }
  if (rows_to_remove.length == 0) return;
  if (confirm ("Really remove these threads?: " + rows_to_remove)) {
    new Ajax.Request('/bugsy/admin/messaging/remove-thread-rows.php',
      {
	asynchronous: true,
	method: 'post',
	parameters:   'rows_to_remove=' + rows_to_remove,
	onSuccess: function(request)
	  {
	    alert("finished removing rows: " + request.responseText);
	    doPageRefresh();
	  },
	onFailure: function(request)
	  {
	    alert('delete rows failed: ' + request.responseText);
	  }
      });
  }
}
</script>

<style type="text/css">
body, td
{
  font-family: Lucida Grande, Arial, sans-serif; font-size:13px;
  scrollbar-face-color:#999999; 
  scrollbar-arrow-color:#ffffff; 
  scrollbar-track-color:#ffffff; 
  scrollbar-shadow-color:'#ffffff'; 
  scrollbar-highlight-color:'#ffffff';  
  scrollbar-darkshadow-Color:'#ffffff';
}

a.message_toggle_black:link, a.message_toggle_black:visited { color:black; }
a.message_toggle_black:hover { color:white; }
a.message_toggle_white:link, a.message_toggle_white:visited { color:white; }
a.message_toggle_white:hover { color:yellow; }

#button_container
{
  position:absolute;
  top:0px;
  left:10px;
  width:889px;
  height:22px;
  background:black;
  padding: 0px;
}
#table_container
{
  position:absolute;
  top:22px;
  left:10px;
}
.arf
{
  position:absolute;
  top:400px;
  left:10px;
  width:889px;
  height:22px;
}
#header_text
{
  font-family: Optima, Lucida Grande, serif;
  font-variant: small-caps;
  font-weight: bold;
  font-size: 15;
  position:absolute;
  left:0;
  color:#ffee00;
}
#hot1
{
  cursor: pointer;
  text-decoration: underline;
  font-family: Optima, Lucida Grande, serif;
  font-variant: small-caps;
  font-weight: bold;
  font-size: 15;
  position:absolute;
  left:220;
  color:#ffee00;
}


.button  {
  color: #ffffff;
  background-color: #999999;
  border: 1px solid #807F7F;
  border-bottom: 1px solid #999999;
  font-size: 10px;
  width: 70px;
}

.delete_class {
  color: #ffffff;
  background-color: #999999;
  /*border: 0px solid #807F7F;
  border-bottom: 0px solid #999999;
  font-size: 10px;
  padding: 0px;
  position:absolute;
  top:0px;
  left:323px;
  z-index:30;
*/
}
.checkbox_class {
  color: #ffffff;
  background-color: #999999;
  /*border: 0px solid #807F7F;
  border-bottom: 0px solid #999999;
  font-size: 10px;
  padding: 0px;
  position:absolute;
  left:483px;
  z-index:30;
*/
}
.dropdown  {
  color: #ffffff;
  background-color: #999999;
  border: 0px solid #807F7F;
  border-bottom: 0px solid #999999;
  font-size: 10px;
  padding: 0px;
  position:absolute;
  top:0px;
  left:420px;
  z-index:30;

}
.inputbox {
  color: #000000;
  background-color: #DADADA;
  padding: 0px;
  border: 0px solid #061F4B;
  font-family: arial, helvetica, verdana, sans serif;
  font-size: 9px;
}

.thread_table_header0 td
{
  color:#000000;
  background:#c6846a;
}
.thread_table_header1 td
{
  color:#000000;
  background:#e24949;
}
.thread_table_header2 td
{
  color:#ffffff;
  background:#2e5ebe;
}
.thread_table_header3 td
{
  color:#ffffff;
  background:#af4985;
}
.thread_table_header4 td
{
  color:#ffffff;
  background:#f36d20;
}
.highlightEven0
{
  color:	#000000;
  background:	#b9c1a9;
}
.highlightOdd0
{
  color:	#000000;
  background:	#ffdba9;
}
.highlightEven1
{
  color:	#000000;
  background:	#de8660;
}
.highlightOdd1
{
  color:	#000000;
  background:	#fdb396;
}
.highlightEven2
{
  color:	#ffffff;
  background:	#527ccf;
}
.highlightOdd2
{
  color:	#ffffff;
  background:	#658ddd;
}
.highlightEven3
{
  color:	#ffffff;
  background:	#65bfc7;
}
.highlightOdd3
{
  color:	#ffffff;
  background:	#e57186;
}
.highlightEven4
{
  color:	#ffffff;
  background:	#006d9f;
}
.highlightOdd4
{
  color:	#ffffff;
  background:	#003562;
}
.cashier_header
{
  cursor: pointer;
  text-decoration: underline;
}
.message_table_header td
{
  font-size: 11px;
  font-weight: bolder;
  color:black;
  background:#999999
}
.highlightOffEven_m
{
  color:	#000000;
  background:	#ecebeb;
}
.highlightOffOdd_m
{
  color:	#000000;
  background:	#f8f8f8;
}
.messages
{
 font-size:11px;
}
.make_it_red
{
  color:	red;
}
</style>
</head>

<body onload='get_cookie(); checkForNewMessages();'>
<div id='button_container' align=right>
  <span id='header_text'>Cashier Messaging, Threaded Style</span>
  <div id="hot1"
      style="display:none"> 
    <span
    onClick="doPageRefresh ()">
      New Message Waiting
    </span>
  </div>
  <input type='image' src='images/button-deletechecked.gif'  value='Delete Checked' onclick='remove_checked_rows()'>
<!--  <input id='toggle_checkbox' type='checkbox' class='checkbox_class' src='images/button-unchecked.gif'  value='Check All' onclick="toggle_checked()"> -->
  <select name='cashiers' id='cashiers' class='dropdown' onclick='select_cashier_widget(event);'>
    <option value="2">All Cashiers</option>
    <option value="1">Unassigned</option>
    <option value="0">Myself</option>
  </select>
  <input type='image' src='images/button-cyclecolors.gif'  value='Cycle Colors' onclick='cycle_colors()'>
  <input type='image' src='images/button-collapse.gif' value='Collapse' onclick='hide_all()'>
  <input type='image' src='images/button-showall.gif' value='Show All' onclick='show_all()'>
</div>
<div id='table_container'>
  <table id = 'thread_table' width='889' cellpadding='0' cellspacing='0'>
    <thead id = 'thread_table_header' class='thread_table_header0'>
      <tr>
	<td width='110'><span class='cashier_header' onclick='select_cashier_toggle();'>Cashier</span></td>
	<td width='110'>Player</td>
	<td width='190'>Topic</td>
	<td width='150'>Told</td>
	<td width='150'>Reply</td>
	<td width='50'></td>
	<td width='129'></td>
      </tr>
    </thead>
  <tbody>
EOF;
foreach ($threads as $rownum => $thread)
{
  $row_id = 'cashier'.$rownum;
  $thread_id = $thread['thread_id'];
  $messages_for_thread = 'messageDiv'.$thread_id;
  $message_thread_id = 'message_'.$thread_id;
  $told_thread_id = 'told_'.$thread_id;
  $reply_thread_id = 'reply_'.$thread_id;
  $message_cashier_class = "'" . "message_class" . " " . "message_cashier_" . $thread['cashier']. "'";
  $table_id = 'table'.$thread_id;
  if ($rownum % 2 == 1)
    $row_class = "'" . "highlightOdd0" . " " . "cashier" . " " .$thread['cashier']. "'";
  else
    $row_class = "'" . "highlightEven0" . " " . "cashier" . " " .$thread['cashier']. "'";

  print <<<EOF
      <tr id=$row_id class=$row_class vAlign='top'>
	<td width='110'><a id='message_toggle' class='message_toggle_black' href='javascript:show_thread_messages("$message_thread_id","$row_id","$reply_thread_id");'>$thread[cashier]</a></td>
	<td width='110'>$thread[player]</td>
	<td width='190'>$thread[topic]</td>
	<td id=$told_thread_id width='150'></td>
	<td id=$reply_thread_id width='150'>$last_reply[$thread_id]</td>
	<td width='50'><input id=$thread[thread_id] type='checkbox'></td>
	<td width='129'></td>
      </tr>
      <tr>
	<td colspan=7>
EOF;
  $flag_reply = false;
  $got_told = false;
  $got_reply = false;
  build_messages_div ($thread_id, $message_thread_id, $table_id, $message_cashier_class, $thread['cashier_id'], $thread[player], $messages);
  print <<<EOF
  <script>
    \$("$told_thread_id").innerHTML = "$last_told[$thread_id]";
    \$("$reply_thread_id").innerHTML = "$last_reply[$thread_id]";
  </script>
EOF;
    if ($flag_reply || $last_told[$thread_id] == null)
    {
      print <<<EOF
	<script>
	  Element.addClassName("$reply_thread_id", 'make_it_red');
	</script>
EOF;
    }
}//foreach thread
print <<<EOF
    </tbody>
  </table>
  <span id="arf"></span>
  <span id="lastMessageID"
    style="display:none">
      $lastMessageID
  </span>
</div>
EOF;
  require_once ("create_message.php");
print <<<EOF
</body>
</html>
EOF;

function build_messages_div ($_thread_id, $message_thread_id, $table_id, $message_cashier_class, $cashier_id, $player, $messages)
{
  global $lastMessageID, $last_told, $last_reply, $got_told, $got_reply, $flag_reply, $cashiers_list;
  print <<<EOF
<div id=$message_thread_id class=$message_cashier_class style='display:none'>
  <table id = $table_id width='889' cellpadding='0' cellspacing='0'>
    <thead class = 'message_table_header'>
      <tr>
	<td width='80'></td>
	<td width='60'>From</td>
	<td width='120'>Sent</td>
	<td width='629'>Text</td>
	<td width='0'></td>
	<td width='0'></td>
	<td width='0'></td>
      </tr>
    </thead>
  <tbody class='messages'>
EOF;
  $row_number = 0;

  foreach ($messages as $message_rownum => $message)
    {
      $row_id = 'message_row'.$message_rownum;
      $my_date = $message['date'];
      $new_date = strftime ("%D %H:%M", strtotime ($my_date));

      if ($message['message_id'] > $lastMessageID)
	$lastMessageID = $message['message_id'];

      if ($_thread_id == $message['thread_id'])
	{
	  if (!$got_told && in_array(strtoupper($message['from']),$cashiers_list)) //$message['from_id'] == $cashier_id)
	    {
	      $last_told[$_thread_id] = $new_date;
	      $got_told = true;
	    }
	  if (!in_array(strtoupper($message['from']),$cashiers_list) && !$got_reply)  //$message['from_id'] != $cashier_id && !$got_reply)
	    {
	      $last_reply[$_thread_id] = $new_date;
	      $got_reply = true;
	    }
	  if ($got_reply && $got_told)
	    {
	      if (strtotime($last_reply[$_thread_id]) > strtotime($last_told[$_thread_id]))
	      {
		$flag_reply = true;
	      }
	    }
	  if ($row_number++ % 2 == 1)
	    $row_class = 'highlightOffOdd_m';
	  else
	    $row_class = 'highlightOffEven_m';
	  print <<<EOF
      <tr id = $row_id class = $row_class vAlign='top'>
	<td width='80'>
EOF;
	  if ($row_number == 1)
	    { 
	      print <<<EOF
	  <input type='image' src='images/button-reply.gif' value='Reply' onclick='prepare_message_form("$player", "$message[thread_id]", "$message[topic_id]" )'>
EOF;
	    }
	  print <<<EOF
	</td>
	<td width='60'>$message[from]</td>
	<td width='120'>$new_date</td>
	<td width='629'>$message[text]</td>
	<td width='0' id='thread_id' style="display:none">$message[thread_id]</td>
	<td width='0'></td>
	<td width='0'></td>
      </tr>
EOF;
	}
    }//foreach message
  print <<<EOF
    </tbody>
  </table>
</div>
EOF;

}//build_messages_div

?>
