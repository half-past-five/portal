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

    <style>
        .divShow {
            display: none;
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
        <hr>
        <h2>Logged in as Observer Admin</h2>

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
        <script>
            function showHideQuery2a(value) {
                if (value == "") {
                    document.getElementById("q2a_insert").style.display = "none";
                    document.getElementById("q2a_show").style.display = "none";
                }
                if (value == "insert" || value == "update") {
                    document.getElementById("q2a_insert").style.display = "block";
                    document.getElementById("q2a_show").style.display = "block";
                }
                if (value == "show") {
                    document.getElementById("q2a_insert").style.display = "none";
                    document.getElementById("q2a_show").style.display = "block";
                }
            }
        </script>


        <hr>
        <form action="query2a.php" method="post">
            <h3>Query 2a (Insert/Update/View Company)</h3>
            <h4>Parameter:</h4>
            <label for="action">Action</label>
            <select id="action" name="action" class="default" onchange="showHideQuery2a(this.value);">
                <option value="" selected>Select function...</option>
                <option value="insert">Insert</option>
                <option value="update">Update</option>
                <option value="show">Show</option>
            </select><br>
            <div id="q2a_show" class="divShow">
                Registration Number <input type="text" name="company_id"><br>
            </div>
            <div id="q2a_insert" class="divShow">
                Brand Name<input type="text" name="brand_name"><br>
                Induction Date<input type="date" name="new_date"><br>
            </div>

            <input type="submit" name="Query 2a">
        </form>

        <!--Query 2b-->
        <script>
            function showHideQuery2b(value) {
                if (value == "") {
                    document.getElementById("q2b_insert").style.display = "none";
                    document.getElementById("q2b_show").style.display = "none";
                }
                if (value == "insert" || value == "update") {
                    document.getElementById("q2b_insert").style.display = "block";
                    document.getElementById("q2b_show").style.display = "block";
                }
                if (value == "show") {
                    document.getElementById("q2b_insert").style.display = "none";
                    document.getElementById("q2b_show").style.display = "block";
                }
            }
        </script>

        <hr>
        <form action="query2b.php" method="post">
            <h3>Query 2b (Insert/Update/View Admin)</h3>
            <h4>Parameter:</h4>
            <label for="action">Action</label>
            <select id="action" name="action" class="default" onchange="showHideQuery2b(this.value);">
                <option value="" selected>Select function...</option>
                <option value="insert">Insert</option>
                <option value="update">Update</option>
                <option value="show">Show</option>
            </select><br>
            <div id="q2b_show" class="divShow">
                Username <input type="text" name="username"><br>
            </div>
            <div id="q2b_insert" class="divShow">
                Name <input type="text" name="name"><br>
                Birth Date <input type="date" name="bday"><br>
                Sex <input type="text" name="sex"><br>
                Position <input type="text" name="position"><br>
                Password <input type="password" name="password"><br>
                Manager ID <input type="text" name="manager_id"><br>
                Company ID <input type="text" name="company_id"><br>
            </div>
            <input type="submit" name="Query 2b">
        </form>

    <?php else : ?>
        <?php if ($Privilages == "2") : ?>
            <hr>
            <h2>Logged in as Company Admin</h2>
            <!--Query 3-->
            <hr>
            <form action="query3.php" method="post">
                <h3>Query 3 (Add Simple User)</h3>
                <h4>Parameter:</h4>
                Name <input type="text" name="name" placeholder="Konstantinos Larkos"><br>
                Birth Date <input type="date" name="bday"><br>
                Sex <input type="text" name="sex" placeholder="M/F"><br>
                Position <input type="text" name="position" placeholder="CEO"><br>
                Username <input type="text" name="username" placeholder="klarko01"><br>
                Password <input type="password" name="password" placeholder="hihi"><br>
                Manager ID <input type="text" name="manager_id" placeholder="1"><br>
                <input type="submit" name="Query 3">
            </form>

            <!--Query 4-->
            <script>
                function showHideQuery4(value) {
                    if (value == "") {
                        document.getElementById("q4_insert").style.display = "none";
                        document.getElementById("q4_show").style.display = "none";
                    }
                    if (value == "insert" || value == "update") {
                        document.getElementById("q4_insert").style.display = "block";
                        document.getElementById("q4_show").style.display = "block";
                    }
                    if (value == "show") {
                        document.getElementById("q4_insert").style.display = "none";
                        document.getElementById("q4_show").style.display = "block";
                    }
                }
            </script>

            <hr>
            <form action="query4.php" method="post">
                <h3>Query 4 (Insert/Update/View Company Admin)</h3>
                <h4>Parameters:</h4>
                <label for="action">Action</label>
                <select id="action" name="action" class="default" onchange="showHideQuery4(this.value);">
                    <option value="" selected>Select function...</option>
                    <option value="insert">Insert</option>
                    <option value="update">Update</option>
                    <option value="show">Show</option>
                </select><br>
                <div id="q4_show" class="divShow">
                    Username <input type="text" name="username"><br>
                </div>
                <div id="q4_insert" class="divShow">

                    Name <input type="text" name="name"><br>
                    Birth Date <input type="date" name="bday"><br>
                    Sex <input type="text" name="sex"><br>
                    Position <input type="text" name="position"><br>

                    Password <input type="password" name="password"><br>
                    Manager ID <input type="text" name="manager_id"><br>
                </div>
                <input type="submit" name="Query 2b">
            </form>

            <!-- Query 5 -->
            <script>
                function showHideQuery5(value) {
                    if (value == "") {
                        document.getElementById("q5_insert").style.display = "none";
                        document.getElementById("q5_delete").style.display = "none";
                    }
                    if (value == "insert") {
                        document.getElementById("q5_insert").style.display = "block";
                        document.getElementById("q5_delete").style.display = "none";
                    }
                    if (value == "update") {
                        document.getElementById("q5_insert").style.display = "block";
                        document.getElementById("q5_delete").style.display = "block";
                    }
                    if (value == "delete") {
                        document.getElementById("q5_insert").style.display = "none";
                        document.getElementById("q5_delete").style.display = "block";
                    }
                }
            </script>

            <script>
                function showHideQuery5b(value) {
                    if (value == "") {
                        document.getElementById("Free Text").style.display = "none";
                        document.getElementById("Multiple Choice").style.display = "none";
                        document.getElementById("Arithmetic").style.display = "none";
                    }
                    if (value == "Free Text") {
                        document.getElementById("Free Text").style.display = "block";
                        document.getElementById("Multiple Choice").style.display = "none";
                        document.getElementById("Arithmetic").style.display = "none";
                    }
                    if (value == "Multiple Choice") {
                        document.getElementById("Free Text").style.display = "none";
                        document.getElementById("Multiple Choice").style.display = "block";
                        document.getElementById("Arithmetic").style.display = "none";
                    }
                    if (value == "Arithmetic") {
                        document.getElementById("Free Text").style.display = "none";
                        document.getElementById("Multiple Choice").style.display = "none";
                        document.getElementById("Arithmetic").style.display = "block";
                    }
                }
            </script>

            <hr>
            <form action="query5.php" method="post">
                <h3>Query 5 (Insert/Update/View Question)</h3>
                <h4>Parameter:</h4>
                Action <select id="action" name="action" class="default" onchange="showHideQuery5(this.value);">
                    <option value="" selected>Select function...</option>
                    <option value="insert">Insert</option>
                    <option value="update">Update</option>
                    <option value="delete">Delete</option>
                </select><br>
                <div id="q5_delete" class="divShow">
                    Question ID <input type="text" name="question_id"><br>
                </div>
                <div id="q5_insert" class="divShow">
                    Description <input type="text" name="description"><br>
                    Text <input type="text" name="text"><br>
                    Type <select class="default" id="type" name="type" onchange="showHideQuery5b(this.value);">
                        <option value="" selected>Select question...</option>
                        <option value="Free Text">Free Text</option>
                        <option value="Multiple Choice">Multiple Choice</option>
                        <option value="Arithmetic">Arithmetic</option>
                    </select>
                    <div id="Free Text" class="divShow">
                        Restriction <input type="text" name="restriction"><br>
                    </div>
                    <div id="Multiple Choice" class="divShow">
                        Selectable Amount <input type="text" name="selectable_amount"><br>
                        Answers <input type="text" name="answers"><br>
                    </div>
                    <div id="Arithmetic" class="divShow">
                        Min <input type="text" name="min"><br>
                        Max <input type="text" name="max"><br>
                    </div>
                </div>
                <br><input type="submit" name="Query 5">
            </form>
        <?php else : ?>
            <hr>
            <h2>Logged in as Simple User</h2>
        <?php endif; ?>




        <!--Query 7-->
        <hr>
        <form action="query7.php" method="post">
            <h3>Query 7 (Company's Questionnaires)</h3>
            <input type="submit" name="Query 7">
        </form>

        <!--Query 8-->
        <hr>
        <form action="query8.php" method="post">
            <h3>Query 8 (Most Popular Questionnaires)</h3>
            <input type="submit" name="Query 8">
        </form>

        <!--Query 9-->
        <hr>
        <form action="query9.php" method="post">
            <h3>Query 9 (All Questionnaires)</h3>
            <input type="submit" name="Query 9">
        </form>

        <!--Query 10-->
        <hr>
        <form action="query10.php" method="post">
            <h3>Query 10 (Average Question per Questionnaire)</h3>
            <input type="submit" name="Query 10">
        </form>

        <!--Query 11-->
        <hr>
        <form action="query11.php" method="post">
            <h3>Query 11 (Large Questionnaires)</h3>
            <input type="submit" name="Query 11">
        </form>

        <!--Query 12-->
        <hr>
        <form action="query12.php" method="post">
            <h3>Query 12 (Small Questionnaires)</h3>
            <input type="submit" name="Query 12">
        </form>

        <!--Query 13-->
        <hr>
        <form action="query13.php" method="post">
            <h3>Query 13 (Questionnaires with exact same Questions)</h3>
            <input type="submit" name="Query 13">
        </form>

        <!--Query 14-->
        <hr>
        <form action="query14.php" method="post">
            <h3>Query 14 (Questionaires which have at least the Questions of selected Questionnaire)</h3>
            Questionnaire ID <input type="text" name="@qn_id"><br>
            <input type="submit" name="Query 14">
        </form>


        <!--Query 15-->
        <hr>
        <form action="query15.php" method="post">
            <h3>Query 15 (k Least Used Questions)</h3>
            Number k <input type="text" name="@q@k_min"><br>
            <input type="submit" name="Query 15">
        </form>

        <!--Query 16-->
        <hr>
        <form action="query16.php" method="post">
            <h3>Query 16 (Small Questionnaires)</h3>
            <input type="submit" name="Query 16">
        </form>

    <?php endif; ?>



    <hr>
    <form method="post" action="logout.php">
        <input type="submit" name="disconnect" value="Disconnect" />
    </form>