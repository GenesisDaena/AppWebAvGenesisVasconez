<%@ Language="VBScript" CodePage=65001 %>
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001
%>
<!--#include file="includes/conexion.asp" -->
<!--#include file="includes/seguridad.asp" -->
<%
' =====================================================================
'  register.asp  -  Registro / enrolamiento de usuarios (de Register.aspx)
' =====================================================================
Dim errorMsg, txtUsername, txtEmail, txtPassword, txtBirthday

If HaySesion() Then
    Response.Redirect "default.asp"
End If

errorMsg = ""
txtUsername = ""
txtEmail = ""
txtBirthday = ""

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    txtUsername = Trim("" & Request.Form("txtUsername"))
    txtEmail    = Trim("" & Request.Form("txtEmail"))
    txtPassword = Trim("" & Request.Form("txtPassword"))
    txtBirthday = Trim("" & Request.Form("txtBirthday"))

    If txtUsername = "" Or txtEmail = "" Or txtPassword = "" Then
        errorMsg = "Usuario, correo y contrasena son obligatorios."
    ElseIf Len(txtPassword) < 6 Then
        errorMsg = "La contrasena debe tener al menos 6 caracteres."
    ElseIf ExisteUsuario(txtUsername) Then
        errorMsg = "El nombre de usuario ya esta en uso."
    Else
        Dim fechaNac, foto
        If txtBirthday = "" Or Not IsDate(txtBirthday) Then
            fechaNac = Null
        Else
            fechaNac = CDate(txtBirthday)
        End If
        foto = "~/UserImages/default.jpg"

        ' Los usuarios nuevos se registran siempre como tipo 0 (usuario normal)
        RegistrarUsuario txtUsername, txtPassword, txtEmail, fechaNac, foto, 0

        ' Auto-login tras registrarse
        Dim rs
        Set rs = ValidarUsuario(txtUsername, txtPassword)
        If Not rs.EOF Then
            Session("idUsuario") = ToInt(rs("ID_USER"))
            Session("usuario")   = "" & rs("USERNAME")
            Session("rol")       = ToInt(rs("USER_TYPE"))
            Session("email")     = "" & rs("EMAIL")
            Session("userPhoto") = "" & rs("USER_PHOTO")
            rs.Close
            Set rs = Nothing
            Response.Redirect "default.asp"
        End If
        rs.Close
        Set rs = Nothing
        Response.Redirect "login.asp"
    End If
End If
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro - PoliMusic</title>
    <link rel="stylesheet" href="Content/Site.css">
</head>
<body>
    <div class="auth-page">
        <div class="auth-container">
            <div class="auth-logo">
                <span class="logo-icon">&#9835;</span>
                <h1>PoliMusic</h1>
            </div>

            <h2 class="auth-title">Crear cuenta</h2>

            <% If errorMsg <> "" Then %>
                <div class="alert alert-error"><%= HtmlEnc(errorMsg) %></div>
            <% End If %>

            <form method="post" action="register.asp" class="auth-form">
                <div class="form-group">
                    <label for="txtUsername">Usuario</label>
                    <input type="text" id="txtUsername" name="txtUsername" class="form-control" value="<%= HtmlEnc(txtUsername) %>" required>
                </div>

                <div class="form-group">
                    <label for="txtEmail">Correo electronico</label>
                    <input type="email" id="txtEmail" name="txtEmail" class="form-control" value="<%= HtmlEnc(txtEmail) %>" required>
                </div>

                <div class="form-group">
                    <label for="txtPassword">Contrasena (minimo 6 caracteres)</label>
                    <input type="password" id="txtPassword" name="txtPassword" class="form-control" minlength="6" required>
                </div>

                <div class="form-group">
                    <label for="txtBirthday">Fecha de nacimiento</label>
                    <input type="date" id="txtBirthday" name="txtBirthday" class="form-control" value="<%= HtmlEnc(txtBirthday) %>">
                </div>

                <button type="submit" class="btn btn-primary btn-block">Registrarme</button>
            </form>

            <p class="auth-footer">
                Ya tienes cuenta? <a href="login.asp">Inicia sesion</a>
            </p>
        </div>
    </div>
</body>
</html>
