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
                        if (isset($_SESSION["User ID"]) && isset($_SESSION["Privilages"])) {
                            $UserID = $_SESSION["User ID"];
                            $Privilages = $_SESSION["Privilages"];
                            //echo ("<hr>User ID: " . $UserID . "<br>Privilages: " . $Privilages);
                        } else {
                            session_unset();
                            session_destroy();
                            echo "You are not authorised! Redirecting you to the home page<br/>";
                            die('<meta http-equiv="refresh" content="3; url=index.php" />');
                            //header('Location: index.php');
                            //die();
                        }
                        ?>
                        <?php if ($Privilages == "1") : ?>
                            <hr>
                            <h2>Logged in as Doctors</h2>

                            <!-- VIEW TABLES -->
                            <hr>
                            <form action="queryShowTable.php" method="post">
                                <h3>0 View Every Table</h3>
                                <h4>Parameters:</h4>
                                <label for="action">Table</label>
                                <div class="form-group"><select id="action" name="action">
                                        <option value="" selected>Select table...</option>
                                        <option value="T1-Company">T1-Company</option>
                                        <option value="T1-User">T1-User</option>
                                        <option value="T1-Question">T1-Question</option>
                                        <option value="T1-Questionnaire">T1-Questionnaire</option>
                                        <option value="T1-Question Questionnaire Pairs">T1-Questionnaire Questionnaire Pairs</option>
                                    </select></div>
                                <input type="submit" name="Query Show Table" class="form-control btn btn-primary submit px-3" value="QUERY SHOW TABLE">
                            </form>

                        <?php endif; ?>


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
