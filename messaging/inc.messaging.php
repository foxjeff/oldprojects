<?php
error_reporting(E_ALL ^E_NOTICE);

require_once ("$DOCUMENT_ROOT/bugsy/admin/messaging/inc.messaging.db.funcs.php");

function displayMessages ()
{
$cashier_username = $_SESSION["userName"]; 
$cashier_id = $_SESSION["userID"]; 
//if ($cashier_id == null)
//{
//  $cashier_id = 55;
//  $cashier_username = "HelperBee";
//}
global $lastMessageID;


print <<<EOF
<script type="text/javascript" language="javascript" src="fancy-and-timers.js"></script>
<script type="text/javascript" language="javascript">
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
      xhr = getHttpRequestObject();
      xhr.onreadystatechange = finishCheckingForNewMessages;
      xhr.open ("POST",
		"/bugsy/admin/messaging/check-for-new-messages.php?lastMessageID=" + lastMessageID);
      xhr.send (null);
    }
}
function finishCheckingForNewMessages ()
{
  if (xhr.readyState == 4)
    {
      clearTimeout (checkForNewMessagesTimeoutID);
      if (xhr.responseText == true)
	{
	  document.getElementById ("hot1").style.display = "";
	  cycleColors ();
	}
      else
	{
	  checkForNewMessagesTimeoutID = setTimeout ("checkForNewMessages()", 50000);  // try again in 50 seconds
	}
    }
}
function doPageRefresh ()
{
  UnCheckAllRows();
  window.location.href = document.URL;
}
/*  //document.getElementById ("lastMessageID").innerHTML = $lastMessageID;
      alert ("old " + oldLastMessageID + " <> " + lastMessageID + " new");
  if (oldLastMessageID < $lastMessageID)
    {
      document.getElementById ("lastMessageID").innerHTML = $lastMessageID;
      checkForNewMessagesTimeoutID = setTimeout ("checkForNewMessages ()", 200);  // call myself back until it stops changing
    }
  else
    {
      clearTimeout (checkForNewMessagesTimeoutID);
    }
}*/
function highLightRow ()
{
  //clearText ();
  if (document.getElementById)
    {
      var tables = document.getElementsByTagName ('table');
      for (var i = 0; i < tables.length; i++)
	{
	  if (tables[i].className == 'highlightTable')
	    {
	      var trs = tables[i].getElementsByTagName ('tr');
	      for (var j = 0; j < trs.length; j++)
		{
		  if (trs[j].parentNode.nodeName == 'TBODY') {
		  if (j % 2 == 1)
		    var highlightClass = 'highlightOffOdd';
		  else
		    var highlightClass = 'highlightOffEven';
		  trs[j].className = highlightClass;
		  trs[j].onmouseover = function()
		    {
		      this.className = 'highlightOn';
		      return false
		    }
		  if (highlightClass == 'highlightOffOdd')
		    {
		      trs[j].onmouseout = function()
			{
			  this.className = 'highlightOffOdd';
			  return false
			}
		    }
		  if (highlightClass == 'highlightOffEven')
		    {
		      trs[j].onmouseout = function()
			{
			  this.className = 'highlightOffEven';
			  return false
			}}
		    }
		}
	    }
	}
    }
}
function msgToggle (evt)
{
  evtTarget = evt.target;
  fullID = (evtTarget.id.match (/\d+/))[0];
  //alert("target is " + fullID);
  msgTopicID = "msgTopicID" + fullID; //"msgTopicID" + rowNum;
  msgFullID = "msgFullID" + fullID;
  someID = "topicID" + fullID;
  if (document.getElementById (msgTopicID))  //topic is displayed
    {
      document.getElementById (msgTopicID).id = msgFullID;
      document.getElementById (msgFullID).innerHTML = document.getElementById (fullID).innerHTML;
    }
    else	//full is displayed
    {
      document.getElementById (msgFullID).id = msgTopicID;
      document.getElementById (msgTopicID).innerHTML = document.getElementById (someID).innerHTML;
      //document.getElementById (msgTopicID).innerHTML = document.getElementById (fullID).innerHTML.slice (0,17) + " ->";
    }
}
function goAway ()
{
  clearText ();
  document.getElementById ("textSpot2").style.display="none";
  document.getElementById ("prepareMessageButton").style.display = "";
}
function clearText ()
{
  document.getElementById ("toWhom").value = "";
  document.getElementById ("toWhomText").value = "Type Your Message Here.";
  document.getElementById ("tdPlayerID").innerHTML = "Players ID:<br />";
  document.getElementById ("toWhom").disabled = false;
  document.getElementById ("loggedIn").innerHTML = "";
}

function getHttpRequestObject() {

    http_request = false;

    if (window.XMLHttpRequest) { // Mozilla, Safari,...
	http_request = new XMLHttpRequest();
	if (http_request.overrideMimeType) {
	    http_request.overrideMimeType('text/xml');
	    // See note below about this line
	}
	http_request.overrideMimeType('text/plain');
    } else if (window.ActiveXObject) { // IE
	try {
	    http_request = new ActiveXObject("Msxml2.XMLHTTP");
	} catch (e) {
	    try {
		http_request = new ActiveXObject("Microsoft.XMLHTTP");
	    } catch (e) {}
	}
    }

    if (!http_request) {
	alert('Giving up :( Cannot create an XMLHTTP instance');
	return false;
    }

    return http_request;
}
var xhr;
function findPlayerLogin (v)
{
  xhr = getHttpRequestObject();	//new XMLHttpRequest ();
  xhr.onreadystatechange=displayPlayerLogin;
  xhr.open ("POST",
	    "/bugsy/admin/messaging/find-player-login.php?id=" + v);
  xhr.send (null);
}
function displayPlayerLogin ()
{
  if (xhr.readyState == 4)
    {
      var responseText = xhr.responseText;
      //newRow = responseText.split ("|");
      document.getElementById ("loggedIn").innerHTML = responseText;
    }
}
function sendMessage (_text, player_id, replied_to_message_id, thread_id, topic_id)
{
  clearTimeout (checkForNewMessagesTimeoutID); // make sure to stop checking for new messages
  xhr = getHttpRequestObject();
  xhr.onreadystatechange=messageSent;
  text = _text.replace ("#"," ");
  //alert ("sending: " + 
	    //"/bugsy/admin/messaging/send-message-from-admin.php?text=" + text
	    //+ "&from_id=" + $cashier_id + "&thread_id=" + thread_id
	    //+ "&player_id=" + player_id + "&cashier_id=" + $cashier_id + "&topic_id=" + topic_id);
  xhr.open ("POST",
	    "/bugsy/admin/messaging/send-message-from-admin.php?text=" + text
	    + "&from_id=" + $cashier_id + "&thread_id=" + thread_id
	    + "&player_id=" + player_id + "&cashier_id=" + $cashier_id + "&topic_id=" + topic_id);
  xhr.send (null);
}

function messageSent ()
{
  if (xhr.readyState == 4)
    {
      _replied_to_message_id = 0;
      _thread_id = 0;
      document.getElementById ("textSpot2").style.display="none";
      document.getElementById ("prepareMessageButton").style.display = "";
      newMessages = xhr.responseText.split("<|>");
      newRow = newMessages[0].split("|")
      if (newMessages[1] != "")	// an existing row has a new ThreadID
	{
	  changedRow = newMessages[1].split("|");
	  changedThreadID = "ThreadID"+changedRow[0];
	  document.getElementById (changedThreadID).innerHTML = newRow[4]; // updates changed row w/new ThreadID
	}
      addNewRow (newRow);
    }
}
function addNewRow (newRow)
{
  newMessageID = newRow[0];
  newMessageText = newRow[1];
  newReceivedDate = newRow[2];
  newPlayerName = newRow[3];
  newThreadID = newRow[4];
  newTopicID = newRow[5];
  newTopicText = newRow[6];
  newCashierUsername = newRow[7];

  document.getElementById ("lastMessageID").innerHTML = newMessageID;
  tbody = document.getElementById ("tdata");
  tr = tbody.insertRow (0);
  td = tr.insertCell (tr.cells.length);
  td.setAttribute ("class","col01");
  td.innerHTML = newMessageID;
  td = tr.insertCell (tr.cells.length);
  td.setAttribute ("class","msgTdClass");
  newAnchor = document.createElement ("a");
  newAnchor.setAttribute ("id","msgTopicID"+newMessageID);
  newAnchor.setAttribute ("class","msgClass");
  newAnchor.addEventListener ("click",msgToggle,false);
  //if (newMessageText.length > 17)
    //ntn = document.createTextNode (newMessageText.slice (0,17) + " ->");  //msgTopic
  //else
    //ntn = document.createTextNode (newMessageText);
  ntn = document.createTextNode (newTopicText);
  newAnchor.appendChild (ntn);
  td.appendChild (newAnchor);
  td = tr.insertCell (tr.cells.length);
  td.setAttribute ("class","col01");
  td.innerHTML = newReceivedDate;
  td = tr.insertCell (tr.cells.length);
  td.setAttribute ("class","col01");
  newAnchor = document.createElement ("a");
  newAnchor.setAttribute ("class","playername");
  newAnchor.setAttribute ("href","javascript:prepareMessageForm('" + newPlayerName + "', '" + newMessageID + "', '" + newThreadID + "', '" + newTopicID +  "')");
  ntn = document.createTextNode (newPlayerName);
  newAnchor.appendChild (ntn);
  td.appendChild (newAnchor);
  td = tr.insertCell (tr.cells.length);
  td.setAttribute ("class","col01");
  td.innerHTML = newThreadID;
  td.setAttribute ("id","ThreadID"+newMessageID);
  td = tr.insertCell (tr.cells.length);
  td.setAttribute ("class","userFarfel");
  td.innerHTML = newCashierUsername;
  td = tr.insertCell (tr.cells.length);
  td.setAttribute ("style","display:none");
  newAnchor = document.createElement ("a");
  newAnchor.setAttribute ("id",newMessageID);
  newAnchor.setAttribute ("class","msgClass");
  newAnchor.addEventListener ("click",msgToggle,false);
  ntn = document.createTextNode (newMessageText);
  newAnchor.appendChild (ntn);
  td.appendChild (newAnchor);
  td = tr.insertCell (tr.cells.length);
  td.setAttribute ("style","display:none");
  spn = document.createElement ("span");
  ntn = document.createTextNode (newTopicText);
  spn.appendChild (ntn);
  spn.setAttribute ("id","topicID"+newMessageID);
  td.appendChild (spn);
  td = tr.insertCell (tr.cells.length);
  cb = document.createElement("input");
  cb.setAttribute("type","checkbox");
  cb.setAttribute("id","cbID"+newMessageID);
  td.appendChild (cb);
  highLightRow ();
  doPageRefresh();
  checkForNewMessages (); // start checking for new messages again
}
function getID (v)
{
  xhr = getHttpRequestObject();	//new XMLHttpRequest ();
  xhr.onreadystatechange=showID;
  xhr.open ("GET",
	    "/bugsy/admin/messaging/get-player_id.php?name=" + v);
  xhr.send (null);
}
function showID ()
{
  if (xhr.readyState == 4) {
    if (xhr.status == 200)
    {
      var userID = 0;
      userID = xhr.responseText;
      verifiedOrNot = "";
      if (userID != 0 && userID != null)
	{
	  verifiedOrNot = "ID is Verified: " + userID;
	  document.getElementById ("sendButton").disabled = false;
	  findPlayerLogin (userID);
	}
      else
	{
	  verifiedOrNot = "ID was not found";
	  document.getElementById ("sendButton").disabled = true;
	}
      document.getElementById ("toWhomID").innerHTML = userID;
      document.getElementById ("tdPlayerID").innerHTML = verifiedOrNot;
    }}
}
var _replied_to_message_id, _thread_id;
function prepareMessageForm (player_name, replied_to_message_id, thread_id, topic_id)
  //called from PlayerID href
{
  player_name = (player_name != null)? player_name : 0;
  _replied_to_message_id = (replied_to_message_id != null)? replied_to_message_id : 0;
  _thread_id = thread_id = (thread_id != null)? thread_id : 0;
  clearText ();
  document.getElementById ("responseText").innerHTML = "";
  document.getElementById ("prepareMessageButton").style.display = "none";
  document.getElementById ("textSpot2").style.display="block";
  document.getElementById ("toWhomText").focus ();
  document.getElementById ("toWhomText").select ();
  document.getElementById ("toWhomText").value = player_name + " " + _replied_to_message_id + " " + _thread_id + " " + topic_id;
  document.getElementById ("topics").value = topic_id;
  if (player_name)
    {
      document.getElementById ("toWhom").value = player_name;
      getID (player_name);
    }
}
function showTopicsForm ()
{
  document.getElementById ("prepareMessageButton").style.display = "none";
  document.getElementById ("maintainTopicsButton").style.display = "none";
  document.getElementById ("topicsForm").style.display = "block";
}
function prepareMessageForSending ()
{
  messageText = document.getElementById ("toWhomText").value;
  playerID = document.getElementById ("toWhomID").innerHTML;
  document.getElementById ("loggedIn").innerHTML = playerID + " " + _replied_to_message_id + " " + _thread_id; 
  topic_id = document.getElementById ("topics").value;
  sendMessage (messageText, playerID, _replied_to_message_id, _thread_id, topic_id);
}
function checkAllRows()
{
  inputs = document.getElementsByTagName("input");
  //inputs = document.messageDataForm.elements;
  for (var i = 0; i < inputs.length; i++) {
    if (inputs[i].type == "checkbox") {
      inputs[i].checked = true;
    }
  }
}
function UnCheckAllRows()
{
  inputs = document.getElementsByTagName("input");
  for (var i = 0; i < inputs.length; i++) {
    if (inputs[i].type == "checkbox") {
      inputs[i].checked = false;
    }
  }
}
function removeCheckedRows()
{
  rows_to_remove = new Array();
  inputs = document.getElementsByTagName("input");
  //inputs = document.messageDataForm.elements;
  for (var i = 0; i < inputs.length; i++) {
    if (inputs[i].type == "checkbox" && inputs[i].checked) {
      rows_to_remove.push(inputs[i].id.match(/\d+/));
    }
  }
  if (confirm ("Really remove these messages?: " + rows_to_remove)) {
    xhr = getHttpRequestObject();
    xhr.onreadystatechange=finishRemovingRows;
    xhr.open ("GET",
	      "/bugsy/admin/messaging/remove-rows.php?rows_to_remove=" + rows_to_remove);
    xhr.send (null);
  }
}
function finishRemovingRows ()
{
  if (xhr.readyState == 4)
    {
      alert("finished removing rows: " + xhr.responseText);
      doPageRefresh();
    }
}
function permDelete()
{
  if (confirm ("Really delete all messages permanently?")) {
    if (confirm ("This action cannot be undone!")) {
      xhr = getHttpRequestObject();
      xhr.onreadystatechange=finishPermDelete;
      xhr.open ("GET",
		"/bugsy/admin/messaging/delete-all-messages.php");
      xhr.send (null);
    }
  }
}
function finishPermDelete()
{
  if (xhr.readyState == 4)
    {
      alert("Finished permanently deleting all rows");
      doPageRefresh();
    }
}
</script>

<html>

<head>
  <!--   <link rel="stylesheet" href="/bugsy/admin/adminstyle.css" type="text/css"> -->
  <link rel="stylesheet" href="/bugsy/admin/messaging/messagingstyle.css" type="text/css">
  <title>
    Messaging
  </title>

</head>
<body onload = "highLightRow(); checkForNewMessages() ">
<div id="top">
  <h1>Cashier Messaging Center</h1>
  </div>
<div id="left">
  <div id="columns">
  <a id="prepareMessageButton" onClick="prepareMessageForm ()" >Send a Message</a>
  <span><br /></span>
  <div id="toWhomID" style="display:none"></div>
  <div id="responseText"></div>
  <div id="textSpot2" style="display:none">
    <form id="messageForm">
    <table border cellpadding=0 cellspacing=0>Create A Message:
    <tr>
      <td id="fromWhom" colSpan=2>From:	$cashier_username</td>
    <tr>
      <td id="tdPlayerName">To:	(Player's Name)<br />
	<input type="text" id="toWhom" name="toWhom" size=20 onchange="getID(this.value)"/>
      </td>

      <td id="tdPlayerID">Players ID:<br />
      </td>
    </tr>
    <tr><td colSpan=2>Topic:<br /br><select name="topics" id="topics">
EOF;
    $retval = fetch_message_topics ($topics);
    foreach ($topics as $key => $row) {
print <<<EOF
      <option value=$row[topic_id]>$row[topic_text]</option>
EOF;
    }      
print <<<EOF
      </select>
    <tr><td colSpan=2>Message:<br />
      <textarea id="toWhomText" name="toWhomText" cols=35 rows=9 wrap="soft" >Type Your Message Here</textarea>
    </td></tr>
    <tr><td colSpan=2 align="right">
      <input type="button" onClick="goAway()" value="Close">
      <input type="button" onClick="clearText()" value="Clear">
      <input id="sendButton" type="button" onClick="prepareMessageForSending ()" value="Send" disabled>
    </td></tr>
    </table>
    </form>
    <div id="loggedIn"></div>
  </div>
  </div> <!-- "columns" -->
</div> <!-- "left" -->


<div id="center">
<center>

<!-- <h1>Messaging Center</h1> -->

  <table class = "highlightTable" id = "dataTable01">
    <thead>
      <tr class="headerow">
	<td class=col-header>ID</td>
	<td class=col-header>Topic</td>
	<td class=col-header>Received Date</td>
	<td class=col-header>Player Name</td>
	<td class=col-header>Thread ID</td>
	<td class=col-header>Cashier</td>
      </tr>
    </thead>
    <tbody id="tdata">
      <form name=messageDataForm>
EOF;
  $result = fetch_messages_from_db ("", $messages); // the "" first arg is for fetching all messages
  if ($result)
  {
    foreach ($messages as $key => $row)
      {
	$rowID = $row[id];
	if ($rowID > $lastMessageID)
	  $lastMessageID = $rowID;	// saving for later consumption
	$tdID = "msgTopicID" . $rowID;
	$threadID = "ThreadID" . $rowID;
	$someID = "topicID" . $rowID;
	$cbID = "cbID" . $rowID;
	$msgText = $row[text];
	//if (strlen ($msgText) > 17)
	  //$msgTopic = substr ($msgText, 0 , 17) . " ->";
	//else
	  //$msgTopic = $msgText;
	$msgReceivedDate = $row[received_date];
	$msgPlayerName = $row[name];
	$msgThreadID = $row[thread_id];
	$msgTopicID = $row[topic_id];
	$msgTopicText = $row[topic_text];
	$msgCashierUsername = $row[cashier_username];
  print <<<EOF
	<tr>
	  <td class=col01>$rowID</td>
	  <td class="msgTdClass" ><a id=$tdID class="msgClass" onClick="msgToggle(event)">$msgTopicText</a></td>
	  <td class=col01>$msgReceivedDate</td>
	  <td class=col01><a class="playername" href="javascript:prepareMessageForm('$msgPlayerName','$rowID','$msgThreadID','$msgTopicID')">$msgPlayerName</a></td>
	  <td class=col01 id=$threadID>$msgThreadID</td>
	  <td class=userFarfel>$msgCashierUsername</td>
	  <td style="display:none"><a id=$rowID class="msgClass" onClick="msgToggle(event)">$msgText</a></td>
	  <td style="display:none"><span id=$someID>$msgTopicText</span></td>
	  <td><input type="checkbox" id=$cbID></td>
	</tr>
EOF;
      }//foreach messages
  }//if messages > 0
print <<<EOF
      </form>
    </tbody>
  </table>

</center>
</div> <!-- "center" -->

<div id="right">
<input type="button" value="Delete Checked Rows" onClick="removeCheckedRows()">
<input type="button" value="Check All Rows" onClick="checkAllRows()">
<input type="button" value="UnCheck All Rows" onClick="UnCheckAllRows()">
<br /><br />
<input type="button" value="Permanently Delete" onClick="permDelete()">
  <div id="hot1"
      style="display:none"> 
    <span
    onClick="doPageRefresh ()">
      New Message Waiting
    </span>
  </div>
  <span id="lastMessageID"
    style="display:none">
      $lastMessageID
  </span>
</div> <!-- "right" -->

</body>
</html>
EOF;

}//displayMessages
?>
