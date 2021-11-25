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
    $UserID = $_SESSION["User ID"];
    $tsql = "{call Q3(?,?,?,?,?,?,?,?)}";
    echo "Executing query: " . $tsql . ") with parameter " . $UserID . $_POST["name"] . $_POST["bday"] . $_POST["sex"] . $_POST["position"] . $_POST["username"] . $_POST["password"] . $_POST["manager_id"] . "<br/>";

    //Initialize Parameters
    $params = array(
        array($UserID, SQLSRV_PARAM_IN),
        array($_POST["name"], SQLSRV_PARAM_IN),
        array($_POST["bday"], SQLSRV_PARAM_IN),
        array($_POST["sex"], SQLSRV_PARAM_IN),
        array($_POST["position"], SQLSRV_PARAM_IN),
        array($_POST["username"], SQLSRV_PARAM_IN),
        array($_POST["password"], SQLSRV_PARAM_IN),
        array($_POST["manager_id"], SQLSRV_PARAM_IN)
    );

    sqlsrv_query($conn, $tsql, $params);

    /* Free connection resources. */
    sqlsrv_close($conn);

    $time_end = microtime(true);
    $execution_time = round((($time_end - $time_start) * 1000), 2);
    echo ('<br>QueryTime: ' . $execution_time . ' ms');
    ?>

    <form method="post">
        <input type="submit" name="disconnect" value="Disconnect" />
        <input type="submit" value="Menu" formaction="authenticated.php">
    </form>

</body>

</html>