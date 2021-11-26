<?php
session_start();
// Get the DB connection info from the session
$serverName = $_SESSION["serverName"];
$connectionOptions = $_SESSION["connectionOptions"];
?>

<html>

<head>
    <title>Authenticated User</title>
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

<body class="img js-fullheight" style="background-image: url(https://www.yerun.eu/wp-content/uploads/2021/07/UCY-SOCIAL-ACTIVITIES-1600x1071.jpg);">
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
                            <h2>Logged in as Observer Admin</h2>

                            <!--Query 1-->
                            <hr>
                            <form action="query1.php" method="post">
                                <h3>Query 1 (Add Company Admin with Company)</h3>
                                <h4>Parameter:</h4>
                                <div class="form-group">
                                    <input type="text" name="name" placeholder="Admin Name" class="form-control">
                                    Birth Date <input type="date" name="bday" class="form-control">
                                </div>
                                <div class="form-group">Sex
                                    <select id="sex" name="sex">
                                        <option value="M">M</option>
                                        <option value="F">F</option>
                                    </select>
                                </div>

                                <div class="form-group"><input type="text" name="position" placeholder="Position" class="form-control"></div>
                                <div class="form-group"><input type="text" name="username" placeholder="Username" class="form-control"></div>
                                <div class="form-group"><input type="password" name="password" placeholder="Password" class="form-control"></div>
                                <div class="form-group"><input type="text" name="manager_id" placeholder="Manager ID" class="form-control"></div>
                                <div class="form-group"><input type="text" name="company_reg_num" placeholder="Company Registration Number" class="form-control"></div>
                                <div class="form-group"><input type="text" name="company_brand_name" placeholder="Company Brand Name" class="form-control"></div>
                                <div class="form-group"><input type="submit" name="Query 1" class="form-control btn btn-primary submit px-3" value="Query 1"></div>
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
                                <h3>Query 2A (Insert/Update/View Company)</h3>
                                <h4>Parameter:</h4>
                                <label for="action">Action</label>
                                <div class="form-group"><select id="action" name="action" class="form-control" onchange="showHideQuery2a(this.value);">
                                        <option value="" selected>Select function...</option>
                                        <option value="insert">Insert</option>
                                        <option value="update">Update</option>
                                        <option value="show">Show</option>
                                    </select></div>
                                <div id="q2a_show" class="divShow">
                                    <div class="form-group"><input type="text" class="form-control" name="company_id" placeholder="Registration Number"></div>
                                </div>
                                <div id="q2a_insert" class="divShow">
                                    <div class="form-group"><input type="text" class="form-control" name="brand_name" placeholder="Brand Name"></div>
                                    <div class="form-group"><input type="date" class="form-control" name="new_date" placeholder="Induction Date"></div>
                                </div>

                                <input type="submit" name="Query 2a" value="QUERY 2A" class="form-control btn btn-primary submit px-3">
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
                                <h3>Query 2B (Insert/Update/View Admin)</h3>
                                <h4>Parameter:</h4>
                                <label for="action">Action</label>
                                <div class="form-group"><select id="action" class="form-control" name="action" class="default" onchange="showHideQuery2b(this.value);">
                                        <option value="" selected>Select function...</option>
                                        <option value="insert">Insert</option>
                                        <option value="update">Update</option>
                                        <option value="show">Show</option>
                                    </select></div>
                                <div id="q2b_show" class="divShow">
                                    <div class="form-group"><input type="text" name="username" class="form-control" placeholder="Username"></div>
                                </div>
                                <div id="q2b_insert" class="divShow">
                                    <div class="form-group"><input type="text" name="name" class="form-control" placeholder="Name"></div>
                                    <div class="form-group">
                                        Birth Date<input type="date" name="bday" class="form-control" placeholder="Birth Date">
                                        Sex<select id="sex" name="sex" class="form-control">
                                            <option value="M">M</option>
                                            <option value="F">F</option>
                                        </select>
                                    </div>
                                    <div class="form-group"><input type="text" name="position" class="form-control" placeholder="Position"></div>
                                    <div class="form-group"><input type="password" name="password" class="form-control" placeholder="Password"></div>
                                    <div class="form-group"><input type="text" name="manager_id" class="form-control" placeholder="Manager ID"></div>
                                    <div class="form-group"><input type="text" name="company_id" class="form-control" placeholder="Company ID"></div>
                                </div>
                                <input type="submit" name="Query 2b" value="QUERY 2B" class="form-control btn btn-primary submit px-3">
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
                                    <input type="text" name="name" placeholder="Admin Name" class="form-control">
                                    <div class="form-group">
                                        Birth Date<input type="date" name="bday" class="form-control" placeholder="Birth Date">
                                        Sex<select id="sex" name="sex" class="form-control">
                                            <option value="M">M</option>
                                            <option value="F">F</option>
                                        </select>
                                    </div>
                                    <div class="form-group"><input type="text" name="position" class="form-control" placeholder="Position"></div>
                                    <div class="form-group"><input type="text" name="username" class="form-control" placeholder="Username"></div>
                                    <div class="form-group"><input type="password" name="password" class="form-control" placeholder="Password"></div>
                                    <div class="form-group"><input type="text" name="manager_id" class="form-control" placeholder="Manager ID"></div>
                                    <div class="form-group"><input type="submit" name="Query 3" class="form-control btn btn-primary submit px-3" value="QUERY 3">
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
                                    <div class="form-group"><select id="action" class="form-control" name="action" class="default" onchange="showHideQuery4(this.value);">
                                            <option value="" selected>Select function...</option>
                                            <option value="insert">Insert</option>
                                            <option value="update">Update</option>
                                            <option value="show">Show</option>
                                        </select></div>
                                    <div id="q4_show" class="divShow">
                                        <div class="form-group"><input class="form-control" type="text" name="username" placeholder="Username"></div>
                                    </div>
                                    <div id="q4_insert" class="divShow">
                                        <div class="form-group"><input class="form-control" type="text" name="name" placeholder="Name"></div>
                                        <div class="form-group">
                                            Birth Date<input type="date" name="bday" class="form-control" placeholder="Birth Date">
                                            Sex<select id="sex" name="sex" class="form-control">
                                                <option value="M">M</option>
                                                <option value="F">F</option>
                                            </select>
                                        </div>
                                        <div class="form-group"><input class="form-control" type="text" name="position" placeholder="Position"></div>
                                        <div class="form-group"><input class="form-control" type="password" name="password" placeholder="Password"></div>
                                        <div class="form-group"><input class="form-control" type="text" name="manager_id" placeholder="Manager ID"></div>
                                    </div>
                                    <input type="submit" name="Query 4" class="form-control btn btn-primary submit px-3" value="QUERY 4">
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
                                    <h3>Query 5 (Insert/Update/Delete Question)</h3>
                                    <h4>Parameter:</h4>
                                    <div class="form-group">Action <select id="action" name="action" class="form-control" onchange="showHideQuery5(this.value);">
                                            <option value="" selected>Select function...</option>
                                            <option value="insert">Insert</option>
                                            <option value="update">Update</option>
                                            <option value="delete">Delete</option>
                                        </select></div>
                                    <div id="q5_delete" class="divShow">
                                        <div class="form-group"><input type="text" name="question_id" placeholder="Question ID"></div>
                                    </div>
                                    <div id="q5_insert" class="divShow">
                                        <div class="form-group"><input class="form-control" type="text" name="description" placeholder="Description"></div>
                                        <div class="form-group"><input class="form-control" type="text" name="text" placeholder="Text"></div>
                                        <div class="form-group">Type <select class="default" id="type" name="type" onchange="showHideQuery5b(this.value);">
                                                <option value="" selected>Select question...</option>
                                                <option value="Free Text">Free Text</option>
                                                <option value="Multiple Choice">Multiple Choice</option>
                                                <option value="Arithmetic">Arithmetic</option>
                                            </select></div>
                                        <div id="Free Text" class="divShow">
                                            <div class="form-group"><input class="form-control" type="text" name="restriction" placeholder="Restriction"></div>
                                        </div>
                                        <div id="Multiple Choice" class="divShow">
                                            <div class="form-group"><input class="form-control" type="text" name="selectable_amount" placeholder="Selectable Amount"></div>
                                            <div class="form-group"><input class="form-control" type="text" name="answers" placeholder="Answers"></div>
                                        </div>
                                        <div id="Arithmetic" class="divShow">
                                            <div class="form-group"><input class="form-control" type="text" name="min" placeholder="Min"></div>
                                            <div class="form-group"><input class="form-control" type="text" name="max" placeholder="Max"></div>
                                        </div>
                                    </div>
                                    <br><input type="submit" name="Query 5" class="form-control btn btn-primary submit px-3" value="QUERY 5">
                                </form>
                            <?php else : ?>
                                <hr>
                                <h2>Logged in as Simple User</h2>
                            <?php endif; ?>




                            <!--Query 7-->
                            <hr>
                            <form action="query7.php" method="post">
                                <h3>Query 7 (Company's Questionnaires)</h3>
                                <input type="submit" name="Query 7" class="form-control btn btn-primary submit px-3" value="QUERY 7">
                            </form>

                            <!--Query 8-->
                            <hr>
                            <form action="query8.php" method="post">
                                <h3>Query 8 (Most Popular Questionnaires)</h3>
                                <input type="submit" name="Query 8" class="form-control btn btn-primary submit px-3" value="QUERY 8">
                            </form>

                            <!--Query 9-->
                            <hr>
                            <form action="query9.php" method="post">
                                <h3>Query 9 (All Questionnaires)</h3>
                                <input type="submit" name="Query 9" class="form-control btn btn-primary submit px-3" value="QUERY 9">
                            </form>

                            <!--Query 10-->
                            <hr>
                            <form action="query10.php" method="post">
                                <h3>Query 10 (Average Question per Questionnaire)</h3>
                                <input type="submit" name="Query 10" class="form-control btn btn-primary submit px-3" value="QUERY 10">
                            </form>

                            <!--Query 11-->
                            <hr>
                            <form action="query11.php" method="post">
                                <h3>Query 11 (Large Questionnaires)</h3>
                                <input type="submit" name="Query 11" class="form-control btn btn-primary submit px-3" value="QUERY 11">
                            </form>

                            <!--Query 12-->
                            <hr>
                            <form action="query12.php" method="post">
                                <h3>Query 12 (Small Questionnaires)</h3>
                                <input type="submit" name="Query 12" class="form-control btn btn-primary submit px-3" value="QUERY 12">
                            </form>

                            <!--Query 13-->
                            <hr>
                            <form action="query13.php" method="post">
                                <h3>Query 13 (Questionnaires with exact same Questions)</h3>
                                <input type="submit" name="Query 13" class="form-control btn btn-primary submit px-3" value="QUERY 13">
                            </form>

                            <!--Query 14-->
                            <hr>
                            <form action="query14.php" method="post">
                                <h3>Query 14 (Questionaires which have at least the Questions of selected Questionnaire)</h3>
                                <div class="form-group"><input class="form-control"type="text" name="@qn_id" placeholder="Questionnaire ID"></div>
                                <input type="submit" name="Query 14" class="form-control btn btn-primary submit px-3" value="QUERY 14">
                            </form>


                            <!--Query 15-->
                            <hr>
                            <form action="query15.php" method="post">
                                <h3>Query 15 (k Least Used Questions)</h3>
                                <div class="form-group"><input class="form-control" type="text" name="@q@k_min" placeholder="Number k"></div>
                                <input type="submit" name="Query 15" class="form-control btn btn-primary submit px-3" value="QUERY 15">
                            </form>

                            <!--Query 16-->
                            <hr>
                            <form action="query16.php" method="post">
                                <h3>Query 16 (Small Questionnaires)</h3>
                                <input type="submit" name="Query 16" class="form-control btn btn-primary submit px-3" value="QUERY 16">
                            </form>

                        <?php endif; ?>


                        <hr>
                        <form method="post" action="logout.php">
                            <button type="submit" name="disconnect" class="form-control btn btn-primary submit px-3">Disconnect</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </section>




</body>

</html>