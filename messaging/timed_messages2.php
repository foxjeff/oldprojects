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
  var is_calendar_created = false;
  function do_fooey()
  {
    Element.toggle("fooey");
    if (!is_calendar_created)
      create_calendar();
  }
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
    if (is_before_today(calendar.date))
      { //force back to today
	calendar.setDate(new Date());
      }
    calendar.params.inputField.value = calendar.date.print(calendar.dateFormat);
  }
  function disable_dates(date)
  {
    return is_before_today(date);
  }
  var my_calendar;
  function create_calendar()
  {
    Calendar.setup
    (
      {
	inputField    : 'date_goes_here',
	dateStatusFunc: disable_dates,
	onSelect      : date_selected,
	showOthers    : true,
	weekNumbers   : false,
	showsTime     : true,
	timeFormat    : 12,
	range	      : [2006,2007],
	ifFormat      : '%a, %b %e, %Y @%I:%M %p'
      }
    );
    is_calendar_created = true;
  }
</script>
</head>
<body>
<div id="calendar_container"><input type='button'value='blah2' onclick='do_fooey()'></div>
<div id='fooey' style='display:none'><input type='text' id='date_goes_here' name='date_goes_here' size='25' maxlength='40'></div>
</body>
</html>
EOF;
?>
