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
            background: black
        }

        table tr:nth-child(odd) {
            background: #4F1092
        }

        table tr:nth-child(even) {
            background: #9C1092
        }
    </style>
    <title>Show Questions</title>
    <link rel="icon" href="https://i.imgur.com/rWjWE94.png">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link href="https://fonts.googleapis.com/css?family=Lato:300,400,700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
    <link rel="stylesheet" href="css/style.css">
</head>

<body class="img js-fullheight" style="background-image: url(https://images.saymedia-content.com/.image/t_share/MTc4NzM1OTc4MzE0MzQzOTM1/how-to-create-cool-website-backgrounds-the-ultimate-guide.png);">
    <section class="ftco-section">
        <!-- <div class="container"> -->
        <div class="row justify-content-center">
            <!-- <div class="col-md-6 col-lg-4"> -->
            <div class="login-wrap p-0">

                <?php
                $time_start = microtime(true);

                //Establishes the connection
                echo "Connecting to SQL server (" . $serverName . ")<br/>";
                echo "Database: " . $connectionOptions[Database] . ", SQL User: " . $connectionOptions[Uid] . "<br/>";
                //echo "Pass: " . $connectionOptions[PWD] . "<br/>";
                $conn = sqlsrv_connect($serverName, $connectionOptions);

                //Read Stored proc with param
                $tsql = "{call Q4(?,?,?,?,?,?,?,?,?)} ";
                $UserID = $_SESSION["User ID"];
                echo "Executing query: " . $tsql . ") with parameter " . $UserID . $_POST["action"] . $_POST["name"] . $_POST["bday"] . $_POST["sex"] . $_POST["position"] . $_POST["username"] . $_POST["password"] . $_POST["manager_id"] . "<br/>";

                $params = array(
                    array($UserID, SQLSRV_PARAM_IN),
                    array($_POST["action"], SQLSRV_PARAM_IN),
                    array($_POST["name"], SQLSRV_PARAM_IN),
                    array($_POST["bday"], SQLSRV_PARAM_IN),
                    array($_POST["sex"], SQLSRV_PARAM_IN),
                    array($_POST["position"], SQLSRV_PARAM_IN),
                    array($_POST["username"], SQLSRV_PARAM_IN),
                    array($_POST["password"], SQLSRV_PARAM_IN),
                    array($_POST["manager_id"], SQLSRV_PARAM_IN)
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
                    echo ("<table style='color: white'><tr >");

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

                function FormatErrors($errors)
                {
                    /* Display errors. */
                    echo "Error information: ";

                    foreach ($errors as $error) {
                        echo "SQLSTATE: " . $error['SQLSTATE'] . "";
                        echo "Code: " . $error['code'] . "";
                        echo "Message: " . $error['message'] . "";
                    }
                }
                ?>

                <form method="post">
                    <div class="form-group">
                        <input type="submit" value="Menu" class="form-control btn btn-primary submit px-3" formaction="authenticated.php">
                    </div>
                </form>

            </div>
            <!-- </div> -->
        </div>
        <!-- </div> -->
    </section>
</body>

</html>