# Code from Older Projects

### ChartDataInCharge
* A hobby project, part of a Mac OSX application
* Objective-C

### sales_widget2
* An OSX widget for displaying up-to-the-moment sales data. This was production code.
* HTML, CSS, JavaScript, SQL and PHP

### messaging/
* A production messaging system for pokerpages.com, an online poker-playing website and Java client
	* send/receive messages  from Admins, Cashiers to individual players
		* could send to players even if offline
		* read notifications sent back to senders
		* threaded view of conversations
		* players received notifications of unread messages upon login
	* ability to broadcast messages to groups of players
		* criteria for player selection could be saved
		* messages could be queued for later sending
* HTML, CSS, JavaScript, SQL and PHP

### simulator/
* A simulator for city bus scheduling (telematics) and position tracking.
	* The simulator used YAML files to describe scenarios
		* the scenarios had 4-6 buses making 2-6 stops along 10 mile or longer routes
		* in addition to simulating buses moving along their routes and stopping at stations
		* scenarios including contacting other buses in an ad hoc manner
		* ad hoc meant that when buses encountered each other, they shared telemetry data
		* additionally, different hardware in the system had to emulated such as:
			* the hardware on each bus that had the telemetry data
			* the hardware at various bus stations used to communicate with the central bus terminal
