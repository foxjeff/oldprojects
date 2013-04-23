<?php
require_once ("$DOCUMENT_ROOT/include/pear/Net/Growl.php");
function &growler_singleton()
  {
    static $obj;
    if (!isset($obj))
      {
	$obj = new My_Growler();
      }
    return $obj;
}
class My_Growler
{
  var $_application;
  var $_application_name;
  var $_growl_notifications;
  var $_growl_password;
  var $_growl_options;
  var $_notify_options;
  var $_growl;

  function My_Growler()
    {
      $this->_application_name = 'cronnie@fox.planetacetech.com';
      $this->_growl_notifications = array('Errors', 'Messages');
      $this->_growl_password = 'happy';
      $this->_application= new Net_Growl_Application($this->_application_name, $this->_growl_notifications, $this->_growl_password);
      $this->_growl_options = array('host' => 'bitsnbytes.planetacetech.com');
      $this->_notify_options = array('priority' => 0, 'sticky' => true);
      $this->_growl = new Net_Growl($this->_application,null,null,$this->_growl_options);
    }
  function send_notification($notice, $notify_options = null)
    {
      if ($notify_options == null)
	$notify_options = $this->_notify_options;
      $this->_growl->notify( 'Messages', $this->_application_name, $notice, $notify_options);
    }
}
?>
