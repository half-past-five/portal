<?php
session_start();
// Get the DB connection info from the session
$serverName = $_SESSION["serverName"];
$connectionOptions = $_SESSION["connectionOptions"];
?>

<html>

<head>
	<style>
		table th {
			background: grey
		}

		table tr:nth-child(odd) {
			background: LightYellow
		}

		table tr:nth-child(even) {
			background: LightGray
		}
	</style>
</head>

<body>
	<table cellSpacing=0 cellPadding=5 width="100%" border=0>
		<tr>
			<td vAlign=top width=170><img height=91 alt=UCY src="images/ucy.jpg" width=94>
				<h5>
					<a href="http://www.ucy.ac.cy/">University of Cyprus</a><BR />
					<a href="http://www.cs.ucy.ac.cy/">Dept. of Computer Science</a>
				</h5>
			</td>
			<td vAlign=center align=middle>
				<h2>Welcome to the EPL342 project test page</h2>
			</td>
		</tr>
	</table>
	<hr>


	<?php
	$time_start = microtime(true);
	echo "Connecting to SQL server (" . $serverName . ")<br/>";
	echo "Database: " . $connectionOptions[Database] . ", SQL User: " . $connectionOptions[Uid] . "<br/>";
	//echo "Pass: " . $connectionOptions[PWD] . "<br/>";

	//Establishes the connection
	$conn = sqlsrv_connect($serverName, $connectionOptions);

	if (isset($_POST['connect'])) {
		echo "<br/>Trying to authenticate to T1-Users!<br/>";
		$tsql = "{call Authenticate(?,?)}";
		if (empty($_POST["username"]))
			echo "Username is empty!<br/>";
		if (empty($_POST["password"]))
			echo "Password is empty!<br/>";
		echo "Executing query: " . $tsql . ") with Username: " . $_POST["username"] . "<br/>";
		//echo "Pass: " . $_POST["password"] . "<br/>";

		// Getting parameter from the http call and setting it for the SQL call
		$params = array(
			array($_POST["username"], SQLSRV_PARAM_IN),
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
	?>
	<hr>
	<form action="authenticated.php" method="post" class="signin-form">
		<div class="form-group">
			<button type="submit" name="authenticate" class="form-control btn btn-primary submit px-3">Proceed</button>
		</div>
	</form>


	<?php
	if (isset($_POST['disconnect'])) {
		echo "Clossing session and redirecting to start page</br>";
		echo "Thank you for choosing EPL342 Team 1!";
		session_unset();
		session_destroy();
		die('<meta http-equiv="refresh" content="5; url=index.php" />');
	}
	?>

	<form method="post">
		<input type="submit" name="disconnect" value="Disconnect" />
	</form>

</body>

</html>