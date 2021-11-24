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

    <!--Query 1-->
    <form action="query1.php" method="post">
        <h3>Query 1 (Add Company with Company Admin)</h3>
        <h4>Parameter:</h4>
        Name <input type="text" name="name" placeholder="Konstantinos Larkou"><br>
        Birth Date <input type="date" name="bday" placeholder="04/06/2000"><br>
        Sex <input type="text" name="sex" placeholder="M"><br>
        Position <input type="text" name="position" placeholder="CEO"><br>
        Username <input type="text" name="username" placeholder="klarko01"><br>
        Password <input type="password" name="password"><br>
        Manager ID <input type="text" name="manager_id" placeholder="1"><br>
        Company Registration Number <input type="text" name="company_reg_num" placeholder="007"><br>
        Company Brand Name <input type="text" name="company_brand_name" placeholder="James Bond"><br>
        <input type="submit" name="Query 1">
    </form>

    <!--Query 2a-->
    <form action="query2a.php" method="post">
        <h3>Query 2a (Add Company)</h3>
        <h4>Parameter:</h4>
        <label for="action">Action</label>
        <select id="action" name="action">>
            <option value="insert">Insert</option>
            <option value="update">Update</option>
            <option value="show">Show</option>
        </select><br>
        Registration Number <input type="text" name="company_id"><br>
        Brand Name<input type="text" name="brand_name"><br>
        Induction Date<input type="date" name="new_date"><br>

        <input type="submit" name="Query 2a">
    </form>

    <!--Query 2b-->
    <form action="query2b.php" method="post">
        <h3>Query 2b (Add Company Admin)</h3>
        <h4>Parameter:</h4>
        <label for="action">Action</label>
        <select id="action" name="action">>
            <option value="insert">Insert</option>
            <option value="update">Update</option>
            <option value="show">Show</option>
        </select><br>
        Name <input type="text" name="name"><br>
        Birth Date <input type="date" name="bday"><br>
        Sex <input type="text" name="sex"><br>
        Position <input type="text" name="position"><br>
        Username <input type="text" name="username"><br>
        Password <input type="password" name="password"><br>
        Manager ID <input type="text" name="manager_id"><br>
        Company ID <input type="text" name="company_id"><br>
        <input type="submit" name="Query 2b">
    </form>