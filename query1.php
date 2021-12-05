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
    <title>Add Company Admin with Company</title>
    <link rel="icon" href="https://i.imgur.com/70ln1bX.png">
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
                echo "Database: " . $connectionOptions["Database"] . ", SQL User: " . $connectionOptions["Uid"] . "<br/>";
                //echo "Pass: " . $connectionOptions[PWD] . "<br/>";
                $conn = sqlsrv_connect($serverName, $connectionOptions);

                //Read Stored proc with param
                $tsql = "{call Q1(?,?,?,?,?,?,?,?,?,?,?)}";
                echo "Executing query: " . $tsql . ") with parameter " . $_POST["name"] . $_POST["bday"] . $_POST["sex"] . $_POST["position"] . $_POST["username"] . $_POST["password"] . $_POST["manager_id"] . $_POST["company_reg_num"] . $_POST["company_brand_name"] . $_POST["IDCard"] . $UserID . "<br/>";

                $params = array(
                    array($_POST["name"], SQLSRV_PARAM_IN),
                    array($_POST["bday"], SQLSRV_PARAM_IN),
                    array($_POST["sex"], SQLSRV_PARAM_IN),
                    array($_POST["position"], SQLSRV_PARAM_IN),
                    array($_POST["username"], SQLSRV_PARAM_IN),
                    array($_POST["password"], SQLSRV_PARAM_IN),
                    array($_POST["manager_id"], SQLSRV_PARAM_IN),
                    array($_POST["company_reg_num"], SQLSRV_PARAM_IN),
                    array($_POST["company_brand_name"], SQLSRV_PARAM_IN),
                    array($_POST["IDCard"], SQLSRV_PARAM_IN),
                    array($UserID, SQLSRV_PARAM_IN)
                );

                sqlsrv_query($conn, $tsql, $params);

                /* Free connection resources. */
                sqlsrv_close($conn);

                $time_end = microtime(true);
                $execution_time = round((($time_end - $time_start) * 1000), 2);
                echo ('<br>QueryTime: ' . $execution_time . ' ms');
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
