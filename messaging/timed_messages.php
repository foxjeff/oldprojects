<?php
require_once ("$DOCUMENT_ROOT/include/pear/JSON.php");

print <<<EOF
<html>
<head>
<link rel="stylesheet" type="text/css" media="all" href="/javascript/calendar2-blue.css" title="Winter" />
<script type="text/javascript" src="/javascript/calendar2.js"></script>
<script type="text/javascript" src="/javascript/lang/calendar2-en.js"></script>
<script type="text/javascript" src="/javascript/calendar2-setup.js"></script>
<script type='text/javascript' src="/javascript/prototype.js"></script>
<script type='text/javascript' src="/javascript/scriptaculous.js"></script>
<script type="text/javascript">
  var my_calendar;
  window.onload = function()
		  {
		    //Element.hide('get_start_date');
		    //my_calendar.hide();
		  }
  function get_started()
  {
    Element.hide('getting_started');
    Element.show('enter_text');
    Field.activate('message_text');
  }
  function capture_message_text()
  {
    Element.hide('enter_text');
    Element.show('get_tab_id');
  }
  function capture_tab_id()
  {
    Element.hide('get_tab_id');
    Element.show('get_priority');
  }
  var is_calendar_created = false;
  function capture_priority()
  {
    Element.hide('get_priority');
    Element.show('get_splat_duration');
  }
  function capture_splat_duration()
  {
    Element.hide('get_splat_duration');
    Element.show('get_start_date');
    if (!is_calendar_created)
      create_calendar();
  }
  function capture_start_date()
  {
    //my_calendar.hide();
    Element.hide('get_start_date');
    Element.show('get_repetition_inteval');
  }
  function capture_repetition_interval()
  {
    //validate
    v = $('repetition_interval').value;
    u = $('repetition_interval_unit').value;
    Element.hide('get_repetition_inteval');
    Element.show('get_max_repetitions');
  }
  function capture_max_repetitions()
  {
    Element.hide('get_max_repetitions');
    Element.show('message_stuff');
  }
  // date functions:
  function is_before_today(date)
  {
    return_value = false;
    now = new Date();
    if (date.getFullYear() <= now.getFullYear())
      if (date.getMonth() <= now.getMonth())
	if (date.getDate() < now.getDate())
	  return_value = true;
    return return_value;
  }
  function date_selected(calendar, formatted_date)
  {
    if (!is_before_today(calendar.date))
      document.getElementById('date_goes_here').innerHTML = formatted_date;
    else
      { //force back to today
	calendar.setDate(new Date());
	document.getElementById('date_goes_here').innerHTML = calendar.date.print(calendar.dateFormat);
      }
  }
  function disable_dates(date)
  {
    return is_before_today(date);
  }
  function create_calendar()
  {
    my_calendar = 
    Calendar.setup
    (
      {
	inputField      : 'date_goes_here',
	dateStatusFunc  : disable_dates,
	showOthers      : true,
	weekNumbers     : false,
	showsTime	: true,
	timeFormat      : 12,
	range		: [2006,2007],
	ifFormat        : '%a, %b %e, %Y @%I:%M %p'
      }
    );
    is_calendar_created = true;
  }
</script>
<style type='text/css'>
body, td
{
  font-family: Lucida Grande, Arial, sans-serif; font-size:15px;
  scrollbar-face-color:#999999; 
  scrollbar-arrow-color:#ffffff; 
  scrollbar-track-color:#ffffff; 
  scrollbar-shadow-color:#ffffff; 
  scrollbar-highlight-color:#ffffff;  
  scrollbar-darkshadow-Color:#ffffff;
}
#button_container
{
  position:absolute;
  top:0px;
  left:10px;
  width:800;
  height:22px;
  background:black;
  padding: 0px;
}
#stuff_container
{
  position:absolute;
  top:22px;
  left:10px;
}
#calendar_container
{
  float: left;
  margin-left: 1em;
  margin-bottom: 1em;
}
.header_text
{
  font-family: Optima, Lucida Grande, serif;
  font-variant: small-caps;
  font-weight: bold;
  font-size: 17;
  position:absolute;
  left:4;
  color:#ffee00;
}

</style>
</head>
<body>
<!--<form id='timed_messages_form' name='timed_messages_form' method='POST' action='javascript:;'> -->
<div id='button_container'>
  <span id='header_text' class='header_text'>Welcome to Timed Messages</span>
</div>
<div id='stuff_container'>
  <div id='question_area' class='question'>
    <div id='getting_started'>If you are ready to create a new Timed Message click: 
      <a id='clickhere' href='#' onclick='get_started()'>Get Started</a>
    </div>
    <div id='enter_text' style='display:none'>
      What is your message?
      <input type='text' id='message_text' name='message_text' value='' size='60' onblur='capture_message_text()'>
    </div>
    <div id='get_tab_id' style='display:none'>
      Thank you.  On what TAB do want this message displayed: 
      <input type='radio' id='tab_id_radio_pp' name='tab_id_radios' value='PP' onclick='capture_tab_id()'>PokerPages
      <input type='radio' id='tab_id_radio_pso' name='tab_id_radios' value='PSO' onclick='capture_tab_id()'>PokerSchoolOnline
      <input type='radio' id='tab_id_radio_bc' name='tab_id_radios' value='BC' onclick='capture_tab_id()'>BugsysClub
    </div>
    <div id='get_priority' style='display:none'>
      Thanks.  now, what is the Priority for this message?
      <input type='radio' id='priority_most' name='priority_radios' value='most' onclick='capture_priority()'>Most Important
      <input type='radio' id='priority_imp' name='priority_radios' value='important' onclick='capture_priority()'>Important
      <input type='radio' id='priority_soso' name='priority_radios' value='soso' onclick='capture_priority()'>So-So Importance
    </div>
    <div id='get_splat_duration' style='display:none'>
      Thanks, for how many seconds should this message be displayed?
      <select id='splat_duation' name='splat_duration' onchange='capture_splat_duration()'>
	<option value='5'>5 seconds</option>
	<option value='10'>10 seconds</option>
	<option value='15'>15 seconds</option>
	<option value='20'>20 seconds</option>
      </select>
    </div>
    <div id='get_start_date' style='display:none'>
      Well done, now, on what date do you want this message to begin displaying:<br />
      <input type='text' id='date_goes_here' name='date_goes_here' size='25' maxlength='40' onchange='capture_start_date()'>
    </div>
    <div id='get_repetition_inteval' style='display:none'>
      Great, we're almost done.  How often do you want this message to display?<br />
      Every:  <input type='text' id='repetition_interval' name='repetition_interval' size='5' maxlength='5' >
      <select id='repetition_interval_unit' name='repetition_interval_unit'>
	<option value='minutes'>minutes</option>
	<option value='hours'>hours</option>
	<option value='days'>days</option>
	<option value='weeks'>weeks</option>
      </select>
      <span id='next' onclick='capture_repetition_interval()'>Next</span>
    </div>
    <div id='get_max_repetitions' style='display:none'>
      <input type='text' id='repetition_interval' name='repetition_interval' size='5' maxlength='5' onblur='capture_max_repetitions()'>  times.
    </div>
  </div>
  <div id='input_area' class='input'> </div>
</div>
</body>
</html>
EOF;
      //button	    : "calendar_container", // ID of the parent element
      //<div id="calendar_container"><input type='button'value='blah'>blah
      //onSelect	    : date_selected,
/*
*/
?>
