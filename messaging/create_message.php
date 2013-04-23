<?php
function fetch_message_topics (&$topics)
{
  $db =& dbGame();

  $query = ("SELECT id AS topic_id, text AS topic_text FROM message_topics ORDER BY id;");
  $topics = $db->fetch_array_all($query, DB_ASSOC);
}
print <<<EOF
<style>
#create_header
{
  position:absolute;
  top:0px;
  left:899px;
  height:22px;
  width:300px;
  background:black;
}
#create_container
{
  position:absolute;
  top:22px;
  left:0px;
  height:450;
  left:899px;
  width:300px;
/*  background:orange;*/
}
a#prepareMessageButton
{
  position:absolute;
  left:10px;
  top:0px;
  color:#ffee00;
  font-weight: bold;
}
a#prepareMessageButton:link 
{
}
a#prepareMessageButton:hover
{
  color: white;
  cursor: pointer;
}
#message_containter
{
  position:absolute;
  left:15px;
  top:10px;
  font-size: larger;
  font-weight: bold;
 /* color: #ff3400;*/
}
#tdFromWhom, #tdPlayerName, #tdPlayerID, #tdTopics
{
  border:solid black 1px;
}
#logged_in {color:red; font-weight:bold;}
.toWhom, .toWhomText
{
}
</style>
<script>
var isDown = false;
var _thread_id = 0;
function prepare_message_form(player, thread_id, topic_id)
{
  incoming = arguments;
  Element.hide("prepareMessageButton");
  if (!isDown)
    {
      Effect.BlindDown("create_container",
	{
	  afterFinish: function()
	    {
	      isDown = true;
	      \$('responseText').innerHTML = "";
	      \$('toWhomText').value = '';
	      \$('toWhomText').focus();
	      \$('toWhomText').select();
	      if (incoming.length != 0)
		{
		  _thread_id = thread_id;
		  \$('toWhom').value = player;
		  get_id(player);
		  \$('topics').value = topic_id;
		  \$('toWhomText').focus();
		  \$('toWhomText').select();
		}
	      else
		{
		  _thread_id = 0;
		  \$('toWhom').value = '';
		  \$('topics').value = 1;
		  \$('toWhom').focus();
		  \$('toWhom').select();
		  \$('sendButton').disabled = true;
		}
	    }
	});
    }
  else
    // meh!
    {
      \$('responseText').innerHTML = "";
      \$('toWhomText').value = '';
      \$('toWhomText').focus();
      \$('toWhomText').select();
      if (incoming.length != 0)
	{
	  _thread_id = thread_id;
	  \$('toWhom').value = player;
	  get_id(player);
	  \$('topics').value = topic_id;
	  \$('toWhomText').focus();
	  \$('toWhomText').select();
	}
      else
	{
	  _thread_id = 0;
	  \$('toWhom').value = '';
	  \$('topics').value = 1;
	  \$('toWhom').focus();
	  \$('toWhom').select();
	  \$('sendButton').disabled = true;
	}
    }
}
function prepare_message_for_sending()
{
  message_text = \$('toWhomText').value;
  player_id = \$('toWhomID').innerHTML;
  topic_id = \$("topics").value;
  \$('logged_in').innerHTML = message_text + ' ' + player_id + " " + _thread_id + " " + topic_id;
  send_message (message_text, player_id, _thread_id, topic_id);
}
function send_message(message_text, player_id, thread_id, topic_id)
{
  clearTimeout (checkForNewMessagesTimeoutID);
  message_text = message_text.replace('#'," ");
  cashier_id = _cashier_id;
  //alert ("sending: " + 
	    //"/bugsy/admin/messaging/send-message-from-admin.php?text=" + message_text
	    //+ "&from_id=" + cashier_id + "&thread_id=" + thread_id
	    //+ "&player_id=" + player_id + "&cashier_id=" + cashier_id + "&topic_id=" + topic_id);
  //return;
  new Ajax.Request('/bugsy/admin/messaging/send-message-from-admin.php',
    {
      asynchronous: true,
      method: 'post',
      parameters:   'text=' + message_text
		  + '&from_id=' + _cashier_id
		  + '&thread_id=' + thread_id
		  + '&player_id=' + player_id
		  + '&cashier_id=' + _cashier_id
		  + '&topic_id=' + topic_id,
      onSuccess: function(request)
	{
	  clear_text();
	  doPageRefresh();  //window.location.href = document.URL;
	  //go_away(true);
	},
      onFailure: function(request)
	{
	  alert('send_message failure: ' + request.responseText);
	}
    });
}
function clear_text()
{
  \$('toWhom').value = '';
  \$('toWhomText').value = '';
  \$('toWhomID').innerHTML = '';
  \$('tdPlayerID').innerHTML = '<b>Players ID</b>:<br />';
  \$('logged_in').innerHTML = '';
  \$('sendButton').disabled = true;
}
function go_away(withRefresh)
{
  clear_text();
  Effect.BlindUp("create_container",
    {
      afterFinish: function()
	{
	  Element.show("prepareMessageButton");
	  isDown = false;
	  //if (withRefresh)
	}
    });
}
function get_id(name)
{
  new Ajax.Request("/bugsy/admin/messaging/get-player_id.php",
    {
      asynchronous: true,
      method: "post",
      parameters: 'name=' + name,
      onSuccess: function(request)
	{
	  show_id(request.responseText);
	},
      onFailure: function(request)
	{
	  alert('get_id failure: ' + request.responseText);
	}
    });

}
function show_id(_id)
{
  user_id = 0;
  verified_or_not = "";
  if (_id != 0 && _id != null)
    {
      user_id = _id;
      verified_or_not = "ID is Verified:<br />" + user_id;
      \$('sendButton').disabled = false;
      find_player_login(user_id);
    }
  else
    {
      verified_or_not = "ID was not found";
      \$('sendButton').disabled = true;
    }
  \$('toWhomID').innerHTML = user_id;
  \$('tdPlayerID').innerHTML = verified_or_not;

}
function find_player_login(user_id)
{
  new Ajax.Request("/bugsy/admin/messaging/find-player-login.php",
    {
      asynchronous: true,
      method: "post",
      parameters: 'id=' + user_id,
      onSuccess: function(request)
	{
	  \$('logged_in').innerHTML = request.responseText;
	},
      onFailure: function(request)
	{
	  alert('find_player_login failure: ' + request.responseText);
	}
    });
}
</script>

  <div id='create_header'>
    <a id="prepareMessageButton" href="#" onClick="prepare_message_form()" >Send a Message</a>
  </div>
  <div id='create_container' style="display:none">
    <span><br /></span>
    <div id="toWhomID" style="display:none"></div>
    <div id="responseText"></div>
    <div id="message_containter" >
      <span>Send A Message:<br /></span>
      <form id="messageForm">
      <table border=0 cellpadding=0 cellspacing=0>
	<tr>
	  <td id="tdFromWhom" colSpan=2><b>From:</b>	$cashier_username</td>
	<tr>
	  <td id="tdPlayerName"><b>To:</b>	(Player's Name)<br />
	    <input type="text" id="toWhom" name="toWhom" size=20 onchange="get_id(this.value)"/>
	  </td>

	  <td id="tdPlayerID"><b>Players ID</b>:<br />
	  </td>
	</tr>
      <tr><td id="tdTopics" colSpan=2><b>Topic:</b><br /br><select name="topics" id="topics">
EOF;
    $retval = fetch_message_topics ($topics);
    foreach ($topics as $key => $row) {
print <<<EOF
	<option value=$row[topic_id]>$row[topic_text]</option>
EOF;
    }      
print <<<EOF
	</select>
      <tr><td colSpan=2><b>Message:</b><br />
	<textarea id="toWhomText" name="toWhomText" cols=35 rows=9 wrap="soft" ></textarea>
      </td></tr>
      <tr><td colSpan=2 align="right">
	<input type="button" onClick="go_away()" value="Close">
	<input type="button" onClick="clear_text()" value="Clear">
	<input id="sendButton" type="button" onClick="prepare_message_for_sending ()" value="Send" disabled>
      </td></tr>
      <tr><td id='logged_in'></td></tr>
      </table>
      </form>
    </div>
  </div> <!-- "create_container" -->


EOF;
?>
