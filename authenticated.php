<?php
session_start();
// Get the DB connection info from the session
$serverName = $_SESSION["serverName"];
$connectionOptions = $_SESSION["connectionOptions"];
?>

<html>

<head>
    <title>Authenticated User</title>
    <link rel="icon" href="images/logo.png">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link href="https://fonts.googleapis.com/css?family=Lato:300,400,700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
    <link rel="stylesheet" href="css/style.css">
    <style>
        .divShow {
            display: none;
        }
    </style>
</head>

<body class="img js-fullheight" style="background-image: url(images/background.jpg);">
    <section class="ftco-section">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-md-6 col-lg-4">
                    <div class="login-wrap p-0">

                        <?php
                        if (isset($_SESSION["UID"])) {
                            $UID = $_SESSION["UID"];
                        } else {
                            session_unset();
                            session_destroy();
                            echo "You are not authorised! Redirecting you to the home page<br/>";
                            die('<meta http-equiv="refresh" content="3; url=index.php" />');
                        }
                        ?>

                        <hr>
                        <h2>Logged in as Doctors</h2>

                        <!-- VIEW TABLES -->
                        <hr>
                        <form action="queryShowPatients.php" method="post">
                            <h3>View Patients Table</h3>
                            <input type="submit" name="Query Show Patients" class="form-control btn btn-primary submit px-3" value="QUERY SHOW Patients">
                        </form>

                        <hr>
                        <form method="post" action="logout.php">
                            <button type="submit" name="disconnect" class="form-control btnn btnn-primary submit px-3">Disconnect</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </section>




</body>

</html>