<?php
require('includes/application_top.php');
setlocale(LC_MONETARY, 'en_US');

$do_show_history = $_REQUEST['show_history'];
$for_date = $_REQUEST['for_date'];

$today = date("Y-m-d");
$date = "'".$today."'";
$before_date = "'".$today . ' 23:59:59'."'";
$display_date = date("@g:i a");
$sales_data = get_sales_data($date, $before_date);
print $display_date . "|" . $sales_data;
return;
switch ($for_date)
{
  case "TODAY":
    break;
  case "YESTERDAY": // won't work
    //$date = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 1,   date("Y")));
    $date .= ' - INTERVAL 1 DAY';
    $before_date .= ' - INTERVAL 1 DAY';
    $display_date = 'Yesterday';
    break;
  case "LAST_WEEK":
    //$date = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 7,   date("Y")));
    $date .= ' - INTERVAL 7 DAY';
    $before_date .= ' - INTERVAL 7 DAY';
    $display_date = 'Last Week';
    break;
  case "LAST_MONTH":
    // change this to be same day/same week last month
    //$date = date("Y-m-d", mktime(0, 0, 0, date("m") - 1, date("d"),   date("Y")));
    $date .= ' - INTERVAL 1 MONTH';
    $before_date .= ' - INTERVAL 1 MONTH';
    $display_date = 'Last Month';
    break;

//print $display_date."|".money_format('%n',$total_sales)."|".$total_order_count."|".money_format('%n',$total_aff_cost)."|".$total_aff_order_count."|".$percent_total_count."|".$percent_total_sales;
print $display_date."|".money_format('%n',$total_sales)."|".$total_order_count."|".money_format('%n',$total_aff_cost)."|".$total_aff_order_count."|".$percent_total_count."|".$percent_total_sales;
}


function get_sales_data($date, $before_date)
{
  //do queries
  $query = "SELECT sum(ot.value) AS total_sales, count(o.orders_id) AS total_order_count FROM orders_total ot, orders o WHERE o.orders_id = ot.orders_id AND ot.class='ot_subtotal' AND o.date_purchased >= $date AND o.date_purchased <= $before_date ;";

  $query2 = "SELECT sum(afs.affiliate_payment) AS total_aff_cost, count(o.orders_id) AS total_aff_order_count FROM orders o, affiliate_sales afs WHERE o.orders_id = afs.affiliate_orders_id AND afs.affiliate_id !=0 AND afs.affiliate_id NOT IN (164, 365, 428, 429, 434, 334, 54026, 163, 55862, 55863, 55867, 55868, 55869, 55870, 55871, 55872, 55873, 55874, 55875, 55876, 55877, 55884, 55885, 55886, 55887, 55888, 55889, 55923, 55954, 55965, 55966, 56024, 56028, 56045) AND o.date_purchased >= $date AND o.date_purchased <= $before_date ;";

  //print DB_SERVER." ".DB_DATABASE."<br />\n";

  $result=mysql_query($query);
  if (!$result)
  {
    die('Invalid query: ' . mysql_error());
  }
  list($total_sales, $total_order_count) = mysql_fetch_array($result);

  $result2=mysql_query($query2);
  if (!$result2)
  {
    die('Invalid query: ' . mysql_error());
  }
  list($total_aff_cost, $total_aff_order_count) = mysql_fetch_array($result2);

  $percent_total_sales = 0;
  $percent_total_count = 0;
  if ($total_order_count > 0)
    $percent_total_count = number_format($total_aff_order_count / $total_order_count * 100);
  if ($total_sales > 0)
    $percent_total_sales = number_format($total_aff_cost / $total_sales * 100);

  //build array
  $return_value = money_format('%n',$total_sales)."|".$total_order_count."|".money_format('%n',$total_aff_cost)."|".$total_aff_order_count."|".$percent_total_count."|".$percent_total_sales;
  //return array
  return $return_value;
}
?>
