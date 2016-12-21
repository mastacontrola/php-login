<?php

// Database connect settings.
$servername = 'localhost';
$username = 'web';
$password = 'webpassword';
$database = 'login';


// Various site settings.
$SessionTimeout = 900; // measured in seconds.
$PasswordDefault = "changeme";
$SiteName = "MySite";
$home = "home.php"; //This is the home file.


// Messages. 
$SiteErrorMessage = "ERROR: There was a site problem. Report this to your administrator and try again later.";
$BadLoginError = "ERROR: Username and/or password is no good.";
$IPBlockedMessage = "ERROR: You are blocked. Report this to your administrator and try again later.";
$incomplete = "ERROR: Not all fields completed.";
$invalidData = "ERROR: Invalid data in one or more fields.";



//Timezone info.
$TimeZone="America/Chicago";
//Find a listing of timezones here:
//  http://php.net/manual/en/timezones.php
date_default_timezone_set($TimeZone);






?>

