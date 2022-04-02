<?php
session_start();
// Get the DB connection info from the session
$serverName = $_SESSION["serverName"];
$connectionOptions = $_SESSION["connectionOptions"];
?>

<html>

<head>
	<title>Log In</title>
	<link rel="icon" href="images/logo.png">
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
	<link href="https://fonts.googleapis.com/css?family=Lato:300,400,700&display=swap" rel="stylesheet">
	<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
	<link rel="stylesheet" href="css/style.css">
</head>

<style>
	.myDiv {
		background-color: lightgray;
		text-align: center;
	}
</style>

<body class="img js-fullheight" style="background-image: url(images/background.jpg);">
	<section class="ftco-section">
		<div class="container">
			<div class="row justify-content-center">
				<div class="col-md-6 col-lg-4">
					<div class="login-wrap p-0">
						<!-- <div class="myDiv"> -->
							<?php
							$time_start = microtime(true);
							echo "Connecting to SQL server (" . $serverName . ")<br/>";
							echo "Database: " . $connectionOptions["Database"] . ", SQL User: " . $connectionOptions["Uid"] . "<br/>";
							//echo "Pass: " . $connectionOptions[PWD] . "<br/>";

							//Establishes the connection
							$conn = sqlsrv_connect($serverName, $connectionOptions);

							if (isset($_POST['connect'])) {
								echo "<br/>Trying to authenticate doctor!<br/>";
								$tsql = "{call Authenticate(?,?)}";
								if (empty($_POST["email"]))
									echo "Email is empty!<br/>";
								if (empty($_POST["password"]))
									echo "Password is empty!<br/>";
								echo "Executing query: " . $tsql . ") with email: " . $_POST["email"] . "<br/>";
								//echo "Pass: " . $_POST["password"] . "<br/>";

								// Getting parameter from the http call and setting it for the SQL call
								$params = array(
									array($_POST["email"], SQLSRV_PARAM_IN),
									array($_POST["password"], SQLSRV_PARAM_IN)
								);

								$getResults = sqlsrv_query($conn, $tsql, $params);
								if ($getResults == FALSE)
									die(FormatErrors(sqlsrv_errors()));

								$result = sqlsrv_fetch_array($getResults, SQLSRV_FETCH_ASSOC);
								/* Arrays in PHP work like objects */
								if (isset($result["User ID"])) {
									$UserID = $result["User ID"];
									$Privilages = $result["Privilages"];
									/* Add authorised User credentials in SESSION */
									$_SESSION["User ID"] = $UserID;
									$_SESSION["Privilages"] = $Privilages;
									echo ("<hr>Authentication Successful!</br>User ID: " . $UserID . "</br>Privilages: " . $Privilages);
								} else {
									echo ("<hr>Authentication Unsuccessful!");
								}

								/* Free query  resources. */
								sqlsrv_free_stmt($getResults);

								/* Free connection resources. */
								sqlsrv_close($conn);

								$time_end = microtime(true);
								$execution_time = round((($time_end - $time_start) * 1000), 2);
								echo ('<br>QueryTime: ' . $execution_time . ' ms');
							}
							?></b>
							<hr>
							<form action="authenticated.php" method="post" class="signin-form">
								<div class="form-group">
									<button type="submit" name="authenticate" class="form-control btn btn-primary submit px-3">Proceed</button>
								</div>
							</form>

							<form method="post" action="logout.php">
								<button type="submit" name="disconnect" class="form-control btn btn-primary submit px-3">Disconnect</button>
							</form>
						<!-- </div> -->
					</div>
				</div>
			</div>
		</div>
	</section>


</body>

</html>