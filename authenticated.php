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
    if (isset($_SESSION["User ID"]) && isset($_SESSION["Privilages"])) {
        $UserID = $_SESSION["User ID"];
        $Privilages = $_SESSION["Privilages"];
        echo ("User ID: ");
        echo ($UserID);
        echo ("<br>Privilages: ");
        echo ($Privilages);
    } else {
        session_unset();
        session_destroy();
        echo "You are not authorised! Redirecting you to the home page<br/>";
        die('<meta http-equiv="refresh" content="3; url=index.php" />');
        //header('Location: index.php');
        //die();
    }
    ?>