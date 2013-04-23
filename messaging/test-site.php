<?php
require_once ('/var/www/siteconf/config.php');
print_r($SITE);
print('dev is: '.($SITE['DEVELOPMENT']?'true':'false').' and site is:'. $SITE['SERVER_NAME']."\n");
if ($_SERVER['argc'] == 2)
  $host_to_check = $_SERVER['argv'][1];
else
  $host_to_check = 'barney';
print(gethostbyname($host_to_check)."\n");
print (((gethostbyname($host_to_check) != $host_to_check)?'got it':'not')."\n");
?>
