<?php
require_once ("$DOCUMENT_ROOT/include/class.db.php");
require_once ("$DOCUMENT_ROOT/include/class.pgdb.php");


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
function displayTopics() {
$sessionUsername = $_SESSION["userName"]; 


print <<<EOF
<script type="text/javascript" language="javascript" src="fancy-and-timers.js"></script>
<script type="text/javascript" language="javascript">
function getHttpRequestObject() {

    http_request = false;

    if (window.XMLHttpRequest) { // Mozilla, Safari,...
	http_request = new XMLHttpRequest();
	if (http_request.overrideMimeType) {
	    http_request.overrideMimeType('text/xml');
	    // See note below about this line
	}
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
function removeRow(rows_to_remove)
{
  xhr = getHttpRequestObject();
  xhr.onreadystatechange=displayRemoveResult;
  xhr.open ("POST",
	    "/bugsy/admin/messaging/remove-topic-row.php?rows_to_remove=" + rows_to_remove);
  xhr.send (null);
}
function displayRemoveResult()
{
  if (xhr.readyState == 4)
    {
      alert(xhr.responseText);
      window.location.href = document.URL;
    }
}
function updateRow(rowID)
{
  topic_id = rowID;
  topic_text = document.getElementById(rowID).value;
  xhr = getHttpRequestObject();
  xhr.onreadystatechange=displayUpdatedRow;
  xhr.open ("POST",
	    "/bugsy/admin/messaging/update-topic-row.php?topic_id=" + topic_id + "&topic_text=" + topic_text);
  xhr.send (null);
}
function displayUpdatedRow()
{
  if (xhr.readyState == 4)
    {
      window.location.href = document.URL;
    }
}
function addRow()
{
  tbody = document.getElementById ("tdata");
  tr = tbody.insertRow (0);
  td = tr.insertCell (tr.cells.length);
  td.setAttribute ("class","col01");
  ip = document.createElement("input");
  ip.setAttribute("type","text");
  ip.setAttribute("value","New Topic Here");
  ip.setAttribute("id","newb");
  ip.setAttribute("size","30");
  td = tr.insertCell (tr.cells.length);
  td.appendChild(ip);
  td = tr.insertCell (tr.cells.length);
  ip = document.createElement("input");
  ip.setAttribute("onClick","finishAdd()");
  ip.setAttribute("type","button");
  ip.setAttribute("value","FinishAdd");
  td.appendChild(ip);
  ip = document.createElement("input");
  ip.setAttribute("onClick","cancelAdd()");
  ip.setAttribute("type","button");
  ip.setAttribute("value","Cancel");
  td.appendChild(ip);
  document.getElementById("newb").focus();
  document.getElementById("newb").select();
}
function cancelAdd()
{
  window.location.href = document.URL;
}
function finishAdd()
{
  topic_text = document.getElementById("newb").value;
  xhr = getHttpRequestObject();
  xhr.onreadystatechange=displayUpdatedRow;
  xhr.open ("POST",
	    "/bugsy/admin/messaging/insert-topic-row.php?topic_text=" + topic_text);
  xhr.send (null);
}
function checkAllRows()
{
  inputs = document.fooform.elements;
  for (var i = 0; i < inputs.length; i++) {
    if (inputs[i].type == "checkbox") {
      inputs[i].checked = true;
      //alert(inputs[i].checked);
    }
  }
}
function removeCheckedRows()
{
  inputs = document.fooform.elements;
  var rows_to_remove = new Array();
  for (var i = 0; i < inputs.length; i++) {
    if (inputs[i].type == "checkbox" && inputs[i].checked) {
      rows_to_remove.push(inputs[i].id.match(/\d+/));
    }
  }
  if (confirm ("Really remove these topics?: " + rows_to_remove))
    removeRow(rows_to_remove);
}
</script>

<html>

<head>
  <link rel="stylesheet" href="/bugsy/admin/messaging/messagingstyle.css" type="text/css">
  <title>
    Messaging
  </title>

</head>
<body onload = "">
<div id="top">
  <h1>Messaging Topics</h1>
  </div>
<div id="left">
  <span><br /></span>
</div> <!-- "left" -->


<div id="center">
<center>

  <table class = "highlightTable" id = "dataTable01">
    <thead>
      <tr class="headerow">
	<td class=col-header>ID</td>
	<td class=col-header>Topic</td>
	<td colSpan=2>Actions</td>
      </tr>
    </thead>
    <tbody id="tdata">
      <form name=fooform>
EOF;
  $result = fetch_message_topics($topics);
  foreach ($topics as $key => $row)
    {
      $topic_id = $row[topic_id];
      $topic_text = $row[topic_text];
      $tid = "foo" . $topic_id;
      $cbid = "cb" . $topic_id;
print <<<EOF
      <tr>
	<td class=col01>$topic_id</td>
	<td><input type="text" id=$topic_id class=col01 size="30" value="$topic_text"></td>
	<td><input type="button" id=$tid onClick="updateRow($topic_id)" value="Update"></td>
	<td><input type="checkbox" id=$cbid></td>
      </tr>
EOF;
    }//foreach $topics
print <<<EOF
      </form>
    </tbody>
  </table>
<input type="button" value="Add Row" onClick="addRow()">
<input type="button" value="Delete Checked Rows" onClick="removeCheckedRows()">
<input type="button" value="Check All Rows" onClick="checkAllRows()">
</center>
</div> <!-- "center" -->

<div id="right">
</div> <!-- "right" -->

</body>
</html>
EOF;

}
displayTopics();
?>
