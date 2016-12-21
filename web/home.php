<?php
include 'vars.php';
include 'verifysession.php';
if ($SessionIsVerified == "1") {


    echo "Verified";

} else {
    echo "Not verified";
}
?>
