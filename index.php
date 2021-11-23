<?php 
	session_start(); 
?>

<html>
<head>
  	<title>EPL342 project test page</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
	<link href="https://fonts.googleapis.com/css?family=Lato:300,400,700&display=swap" rel="stylesheet">
	<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
	<link rel="stylesheet" href="css/style.css">
	</head>
<body class="img js-fullheight" style="background-image: url(https://www.yerun.eu/wp-content/uploads/2021/07/UCY-SOCIAL-ACTIVITIES-1600x1071.jpg);">
<?php
	$sqlDBname = 'lpapal03';
	$sqlUser = 'lpapal03';
	$sqlPass = 'VuVrAvV6';

	$_SESSION["serverName"] = "mssql.cs.ucy.ac.cy";
	$_SESSION["connectionOptions"] = array(
				"Database" => $sqlDBname,
				"Uid" => $sqlUser,
				"PWD" => $sqlPass);
?>
<section class="ftco-section">
		<div class="container">
			<div class="row justify-content-center">
				<div class="col-md-6 col-lg-4">
					<div class="login-wrap p-0">
		      		<h3 class="mb-4 text-center">Observers System <br>Sign In</h3>
		      		<form action="auth.php" method="post" class="signin-form">
		      			<div class="form-group">
		      				<input name="username" type="text" class="form-control" placeholder="Username" required>
		      			</div>
	            		<div class="form-group">
	              			<input name="password" id="password-field" type="password" class="form-control" placeholder="Password" required>
	             			 <span toggle="#password-field" class="fa fa-fw fa-eye field-icon toggle-password"></span>
	            		</div>
	            		<div class="form-group">
	            			<button type="submit" name="connect" class="form-control btn btn-primary submit px-3">Sign In</button>
	            		</div>
	     			</form>
		      		</div>
				</div>
			</div>
		</div>
	</section>

	<?php
		if(isset($_POST['disconnect'])) { 
			echo "Clossing session and redirecting to start page"; 
			session_unset();
			session_destroy();
			die('<meta http-equiv="refresh" content="2; url=index.php" />');
		} 
	?> 
	
	<!--<form method="post"> 
		<input type="submit" name="disconnect" value="Disconnect"/> 
	</form> -->
</body>

</html>
