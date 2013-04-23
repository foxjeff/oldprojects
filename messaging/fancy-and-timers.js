//  fancy.js
//  functions to support admin/cashier messaging html
var colors;
var currColor = 0;
var intervalID;
var totalCycles = 0;

function initColors ()
{
  colors = ["red", "green", "blue", "yellow"];
}
function cycleColors ()
{
  if (typeof colors == "undefined")
    initColors ();
  currColor = (currColor == 3) ? 0 : ++currColor;
  document.getElementById ("hot1").style.color = colors[currColor];
  if (totalCycles++ < 27)
    { 
      intervalID = setTimeout ("cycleColors ()", 100);
    }
  else
    {
      clearTimeout (intervalID);
      totalCycles = 0;
      currColor = 0;
    }
}
// call cycleColors () when you want to flash an element with id=hot1
function areThereNewMessages (lastMessageID)
{
  xhr = getHttpRequestObject ();
  xhr.onreadystatechange = notifyUserOfNewMessages;
  xhr.open ("POST",
	    "/bugsy/admin/messaging/check-db-for-new-messages.php?lastMessageID=" + lastMessageID);
  xhr.send (null);
}
function notifyUserOfNewMessages ()
{
  if (xhr.readyState == 4)
    {
      if (xhr.responseText)
      {
	document.getElementById ("hot1").style.display="";
      }
    }
}
