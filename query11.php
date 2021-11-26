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

    //Establishes the connection
    echo "Connecting to SQL server (" . $serverName . ")<br/>";
    echo "Database: " . $connectionOptions[Database] . ", SQL User: " . $connectionOptions[Uid] . "<br/>";
    //echo "Pass: " . $connectionOptions[PWD] . "<br/>";
    $conn = sqlsrv_connect($serverName, $connectionOptions);

    //Read Stored proc with param
    $tsql = "{call Q11(?)}";
    $UserID = $_SESSION["User ID"];
    echo "Executing query: " . $tsql . ") with parameter " . $UserID . "<br/>";

    $params = array(
        array($UserID, SQLSRV_PARAM_IN)
    );

    $getResults = sqlsrv_query($conn, $tsql, $params);

    echo ("Results:<br/>");
    echo ($getResults);
    if ($getResults == FALSE) 
        die(FormatErrors(sqlsrv_errors()));

    PrintResultSet($getResults);

    /* Free query  resources. */
    sqlsrv_free_stmt($getResults);

    /* Free connection resources. */
    sqlsrv_close($conn);

    $time_end = microtime(true);
    $execution_time = round((($time_end - $time_start) * 1000), 2);
    echo ('<br>QueryTime: ' . $execution_time . ' ms');

    function PrintResultSet($resultSet)
    {
        echo ("<table><tr >");

        foreach (sqlsrv_field_metadata($resultSet) as $fieldMetadata) {
            echo ("<th>");
            echo $fieldMetadata["Name"];
            echo ("</th>");
        }
        echo ("</tr>");

        while ($row = sqlsrv_fetch_array($resultSet, SQLSRV_FETCH_ASSOC)) {
            echo ("<tr>");
            foreach ($row as $col) {
                echo ("<td>");
                echo (is_null($col) ? "Null" : $col);
                echo ("</td>");
            }
            echo ("</tr>");
        }
        echo ("</table>");
    }

    function FormatErrors( $errors ){
		/* Display errors. */
		echo "Error information: ";

		foreach ( $errors as $error )
		{
			echo "SQLSTATE: ".$error['SQLSTATE']."";
			echo "Code: ".$error['code']."";
			echo "Message: ".$error['message']."";
		}
	}
    ?>

    <form method="post">
        <input type="submit" name="disconnect" value="Disconnect" />
        <input type="submit" value="Menu" formaction="authenticated.php">
    </form>

</body>

</html>