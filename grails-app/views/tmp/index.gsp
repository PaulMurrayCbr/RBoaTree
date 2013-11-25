<%--
  Created by IntelliJ IDEA.
  User: ibis
  Date: 29/05/13
  Time: 2:17 PM
  To change this template use File | Settings | File Templates.
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
  <title>TMP</title>
  <meta name="layout" content="main"/>
</head>
<body>
<div  style="border: thin solid darkgrey; padding: 2px; margin: 2px;" id="tmpBody">tmpBody
    Spring security service is ${sec}          <br>
    Msg ${msg}<br>

    <sec:ifLoggedIn>sec:ifLoggedIn<br></sec:ifLoggedIn>
    <sec:ifNotLoggedIn>sec:ifNotLoggedIn<br></sec:ifNotLoggedIn>
    <sec:ifAllGranted roles="NO_ROLES">ifAllGranted NO_ROLES<br></sec:ifAllGranted>
    <sec:ifAnyGranted roles="NO_ROLES">ifAnyGranted NO_ROLES<br></sec:ifAnyGranted>
    <sec:ifNotGranted roles="NO_ROLES">ifNotGranted NO_ROLES<br></sec:ifNotGranted>
    Username <sec:loggedInUserInfo field="username"/><br>
</div>
</body>
</html>