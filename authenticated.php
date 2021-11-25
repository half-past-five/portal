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
        <hr><h2>Logged in as Observer Admin</h2>

        <!--Query 1-->
        <hr>
        <form action="query1.php" method="post">
            <h3>Query 1 (Add Company with Company Admin)</h3>
            <h4>Parameter:</h4>
            Name <input type="text" name="name" placeholder="Konstantinos Larkos"><br>
            Birth Date <input type="date" name="bday"><br>
            Sex <input type="text" name="sex" placeholder="M/F"><br>
            Position <input type="text" name="position" placeholder="CEO"><br>
            Username <input type="text" name="username" placeholder="klarko01"><br>
            Password <input type="password" name="password" placeholder="hihi"><br>
            Manager ID <input type="text" name="manager_id" placeholder="1"><br>
            Company Registration Number <input type="text" name="company_reg_num" placeholder="1"><br>
            Company Brand Name <input type="text" name="company_brand_name" placeholder="EPL342"><br>
            <input type="submit" name="Query 1">
        </form>

        <!--Query 2a-->
        <hr>
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
        <hr>
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

    <?php elseif ($Privilages == "2") : ?>
        <hr><h2>Logged in as Company Admin</h2>
    <?php else : ?>
        <hr><h2>Logged in as User</h2>
    <?php endif; ?>

    <hr><form method="post" action="auth.php">
        <input type="submit" name="disconnect" value="Disconnect" />
    </form>