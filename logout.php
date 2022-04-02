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
    <title>Logging out!</title>
    <link rel="icon" href="images/logo.png">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link href="https://fonts.googleapis.com/css?family=Lato:300,400,700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
    <link rel="stylesheet" href="css/style.css">
</head>

<body class="img js-fullheight" style="background-image: url(images/background.jpg);">
    <section class="ftco-section">
        <div class="container">
            <div class="row justify-content-center">
                <!-- <div class="col-md-6 col-lg-4"> -->
                    <div class="login-wrap p-0">
                        <?php
                        if (isset($_POST['disconnect'])) {
                            echo "<h3>Clossing session and redirecting to home page</h3></br></br>";
                            echo "<h2 style='color:white'>Thank you for using HPF Portal!<h2>";
                            session_unset();
                            session_destroy();
                            die('<meta http-equiv="refresh" content="3.5; url=index.php" />');
                        }
                        ?>
                    </div>
                <!-- </div> -->
            </div>
        </div>
    </section>
</body>