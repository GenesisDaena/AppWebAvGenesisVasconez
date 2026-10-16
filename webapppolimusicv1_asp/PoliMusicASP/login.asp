<%@ Language="VBScript" CodePage=65001 %>
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001
%>
<!--#include file="includes/conexion.asp" -->
<!--#include file="includes/seguridad.asp" -->
<%
' =====================================================================
'  login.asp  -  Inicio de sesion (migrado de Login.aspx)
' =====================================================================
Dim errorMsg, username, password

' Ya logueado -> al inicio
If HaySesion() Then
    Response.Redirect "default.asp"
End If

errorMsg = ""
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    username = Trim("" & Request.Form("txtUsername"))
    password = Trim("" & Request.Form("txtPassword"))

    If username = "" Or password = "" Then
        errorMsg = "Debe completar usuario y contrasena."
    Else
        Dim rs
        Set rs = ValidarUsuario(username, password)
        If Not rs.EOF Then
            Session("idUsuario") = ToInt(rs("ID_USER"))
            Session("usuario")   = "" & rs("USERNAME")
            Session("rol")       = ToInt(rs("USER_TYPE"))
            Session("email")     = "" & rs("EMAIL")
            Session("userPhoto") = "" & rs("USER_PHOTO")
            rs.Close
            Set rs = Nothing
            Response.Redirect "default.asp"
        Else
            rs.Close
            Set rs = Nothing
            errorMsg = "Usuario o contrasena incorrectos."
        End If
    End If
End If
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar sesion - PoliMusic</title>
    <link rel="stylesheet" href="Content/Site.css">
</head>
<body>
    <div class="auth-page">
        <div class="auth-container">
            <div class="auth-logo">
                <span class="logo-icon">&#9835;</span>
                <h1>PoliMusic</h1>
            </div>

            <h2 class="auth-title">Iniciar sesion</h2>

            <% If errorMsg <> "" Then %>
                <div class="alert alert-error"><%= HtmlEnc(errorMsg) %></div>
            <% End If %>
            <% If Request.QueryString("msg") = "auth" Then %>
                <div class="alert alert-error">Debe iniciar sesion para continuar.</div>
            <% End If %>

            <form method="post" action="login.asp" class="auth-form">
                <div class="form-group">
                    <label for="txtUsername">Usuario</label>
                    <input type="text" id="txtUsername" name="txtUsername" class="form-control" autocomplete="username" required>
                </div>

                <div class="form-group">
                    <label for="txtPassword">Contrasena</label>
                    <input type="password" id="txtPassword" name="txtPassword" class="form-control" autocomplete="current-password" required>
                </div>

                <button type="submit" class="btn btn-primary btn-block">Ingresar</button>
            </form>

            <p class="auth-footer">
                No tienes cuenta? <a href="register.asp">Registrate aqui</a>
            </p>
            <p class="auth-footer">
                <a href="default.asp">Volver al inicio</a>
            </p>
        </div>
    </div>
</body>
</html>
