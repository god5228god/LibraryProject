<%@page import="com.doit.util.DBConn"%>
<%@page import="java.sql.Connection"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>index.jsp</title>
<link rel="stylesheet" href="css/main.css" />
<link rel="stylesheet" href="css/util.css" />
</head>
</head>
<body>
<main class="flex">
	<section class="sect01">a</section>
	<section class="sect02">
		<form action="" method="post" name="loginForm">
			<div class="loginBox p-16">
				<h2>Welcome</h2>
				<p>please select your portal to continue</p>
				<div class="switchRole">
					<div class="memberTab">
						<button type="button" class="btnAct">Member</button>
					</div>
					<div class="librarianTab">
						<button type="button">Librarian</button>
					</div>
				</div>
				<div class="loginInputBox">
					<label for="userId">USER ID</label>
					<input type="text" id="userId" name="userId" />
					<label for="userPw">PASSWORD</label>
					<input type="password" id="userPw" name="userPw" />
					<div class="rememberCheck mt-8">
						<input type="checkbox" id="remeberId" />
						<label for="remeberId">Remember your Id</label>
					</div>
					<button type="submit" class="btn mt-2">Sign In</button>
				</div>
				<div class="signInBox">
					<p>
						Not a member yet?
						<a href="" class="membership">Apply for membership</a>
					</p>
				</div>
			</div>
		</form>
	</section>
</main>
<footer>

</footer>
</body>
</html>