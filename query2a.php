<?php
session_start();
// Get the DB connection info from the session
if (isset($_SESSION["serverName"]) && isset($_SESSION["connectionOptions"])) {
    $serverName = $_SESSION["serverName"];
    $connectionOptions = $_SESSION["connectionOptions"];
} else {
    // Session is not correctly set! Redirecting to start page
    session_unset();
    session_destroy();
    echo "Session is not correctly set! Clossing session and redirecting to start page in 3 seconds<br/>";
    die('<meta http-equiv="refresh" content="3; url=index.php" />');
    //header('Location: index.php');
    //die();
}
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

    //Read Stored proc with param
    $tsql = "{call Q2a(?,?,?,?)} ";
    echo "Executing query: " . $tsql . ") with parameter " . $UserID . $_POST["action"] . $_POST["name"] . $_POST["bday"] . $_POST["sex"] . $_POST["position"] . $_POST["username"] . $_POST["password"] . $_POST["manager_id"] . $_POST["is_admin"] . "<br/>";

    $params = array(
        array($_POST["action"], SQLSRV_PARAM_IN),
        array($_POST["company_id"], SQLSRV_PARAM_IN),
        array($_POST["brand_name"], SQLSRV_PARAM_IN),
        array($_POST["new_date"], SQLSRV_PARAM_IN),
    );

    $getResults = sqlsrv_query($conn, $tsql, $params);
    
    echo ("Results:<br/>");
    echo($getResults);
	if ($getResults == FALSE){
		die(FormatErrors(sqlsrv_errors()));
        echo("error");
    }

	PrintResultSet($getResults);
	/* Free query  resources. */  
	sqlsrv_free_stmt($getResults);

	/* Free connection resources. */  
	sqlsrv_close( $conn); 

	function PrintResultSet ($resultSet) {
		echo ("<table><tr >");
		
		foreach( sqlsrv_field_metadata($resultSet) as $fieldMetadata ) {
			echo ("<th>");
			echo $fieldMetadata["Name"];
			echo ("</th>");
		}
		echo ("</tr>");

		while ($row = sqlsrv_fetch_array($resultSet, SQLSRV_FETCH_ASSOC)) {
			echo ("<tr>");
			foreach($row as $col){
				echo ("<td>");
				echo (is_null($col) ? "Null" : $col);
				echo ("</td>");
			}
			echo ("</tr>");
		}
		echo ("</table>");
	}
    ?>

    <form method="post">
        <input type="submit" name="disconnect" value="Disconnect" />
        <input type="submit" value="Menu" formaction="authenticated.php">
    </form>

</body>

</html>