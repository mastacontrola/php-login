<?php
include 'vars.php';
include 'verifysession.php';
if ($SessionIsVerified == "1") {
	if ($isAdministrator == 1) {
		include 'functions.php';

		$target_dir = "$tempDir/";
		$target_file = $target_dir . basename($_FILES["fileToUpload"]["name"]);
		$uploadOk = 1;
		$fileType = pathinfo($target_file,PATHINFO_EXTENSION);
		$fileType = trim($fileType);

		//empty message variable for errors.
		$uploadMessage = "";

		// Check if file already exists. If so, delete it.
		if (file_exists($target_file)) {
			unlink($target_file);
		}


		// Check file size
		if ($_FILES["fileToUpload"]["size"] > 10000000) {
			$uploadOk = 0;
			$uploadMessage .= "<br>Sorry, your file is too large.";
		}


		// Allow certain file formats
		if($fileType != "mp4") {
			$uploadOk = 0;
			$uploadMessage .= "Sorry, only mp4 files are allowed.<br>You uploaded: $fileType";
		}


		// Check if $uploadOk is set to 0 by an error
		if ($uploadOk == 0) {
			setMessage($uploadMessage,"UploadPage.php");
		// if everything is ok, try to upload file
		} elseif (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
			//Here, the upload went through, begin importing the sql file.


			// Do stuff with the file here.




			//Delete uploaded file here, as we are done with it at this point.
			unlink($target_file);

			if ($importResult == "0") {
				setMessage("Import successful.","UploadPage.php");
			} else {
				setMessage("Import failed.","UploadPage.php");
			}


		} else {
			setMessage("Sorry, there was an error uploading your file.","UploadPage.php");
		}

	} else {
		//Not an admin, redirect to home.
		$NextURL="home.php";
		header("Location: $NextURL");
	}
}
?>

