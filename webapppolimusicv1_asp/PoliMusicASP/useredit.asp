<%@ Language="VBScript" CodePage=65001 %>
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001
%>
<!--#include file="includes/conexion.asp" -->
<!--#include file="includes/seguridad.asp" -->
<%
' =====================================================================
'  useredit.asp  -  Crear / editar usuario (migrado de UserEdit.aspx)
'  Solo administrador
' =====================================================================
ExigirAdmin

Dim idUser, txtUsername, txtPassword, txtEmail, txtBirthday, txtPhoto, ddlType, errorMsg, esEdicion
idUser = ToInt(Request.QueryString("id"))
If idUser = 0 Then idUser = ToInt(Request.Form("idUser"))
esEdicion = (idUser > 0)
errorMsg = ""
txtUsername = ""
txtPassword = ""
txtEmail = ""
txtBirthday = ""
txtPhoto = ""
ddlType = 0

If Request.ServerVariables("REQUEST_METHOD") = "POST" And Trim("" & Request.Form("accion")) = "save" Then
    txtUsername = Trim("" & Request.Form("txtUsername"))
    txtPassword = Trim("" & Request.Form("txtPassword"))
    txtEmail    = Trim("" & Request.Form("txtEmail"))
    txtBirthday = Trim("" & Request.Form("txtBirthday"))
    txtPhoto    = Trim("" & Request.Form("txtPhoto"))
    ddlType     = ToInt(Request.Form("ddlType"))

    If txtUsername = "" Or txtEmail = "" Then
        errorMsg = "Usuario y correo son obligatorios."
    ElseIf (Not esEdicion) And Len(txtPassword) < 6 Then
        errorMsg = "La contrasena debe tener al menos 6 caracteres."
    ElseIf esEdicion And txtPassword <> "" And Len(txtPassword) < 6 Then
        errorMsg = "La contrasena debe tener al menos 6 caracteres."
    Else
        Dim fechaNac, foto
        If txtBirthday = "" Or Not IsDate(txtBirthday) Then
            fechaNac = Null
        Else
            fechaNac = CDate(txtBirthday)
        End If
        If txtPhoto = "" Then
            foto = "~/UserImages/default.jpg"
        Else
            foto = txtPhoto
        End If

        If esEdicion Then
            ActualizarUsuario idUser, txtUsername, txtPassword, txtEmail, fechaNac, foto, ddlType
            ' Si el admin se edita a si mismo, refrescar la sesion
            If idUser = IdUsuarioActual() Then
                Session("usuario") = txtUsername
                Session("rol") = ddlType
                Session("email") = txtEmail
                Session("userPhoto") = foto
            End If
            Response.Redirect "adminusers.asp?msg=updated"
        Else
            If ExisteUsuario(txtUsername) Then
                errorMsg = "El nombre de usuario ya esta en uso."
            Else
                CrearUsuario txtUsername, txtPassword, txtEmail, fechaNac, foto, ddlType
                Response.Redirect "adminusers.asp?msg=created"
            End If
        End If
    End If
End If

If esEdicion And Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
    Dim rs
    Set rs = ObtenerUsuarioPorId(idUser)
    If Not rs.EOF Then
        txtUsername = "" & rs("USERNAME")
        txtEmail = "" & rs("EMAIL")
        If Not IsNull(rs("BIRTHDAY")) Then txtBirthday = Year(rs("BIRTHDAY")) & "-" & Right("0" & Month(rs("BIRTHDAY")), 2) & "-" & Right("0" & Day(rs("BIRTHDAY")), 2)
        txtPhoto = "" & rs("USER_PHOTO")
        ddlType = ToInt(rs("USER_TYPE"))
    Else
        Response.Redirect "adminusers.asp?msg=error"
    End If
    rs.Close
    Set rs = Nothing
End If
%>
<!--#include file="includes/header.asp" -->

<div class="page-header">
    <h1><% If esEdicion Then %>Editar usuario<% Else %>Nuevo usuario<% End If %></h1>
    <a href="adminusers.asp" class="btn btn-secondary">Volver al listado</a>
</div>

<% If errorMsg <> "" Then %>
    <div class="alert alert-error"><%= HtmlEnc(errorMsg) %></div>
<% End If %>

<div class="form-container">
    <form method="post" action="useredit.asp">
        <input type="hidden" name="accion" value="save">
        <input type="hidden" name="idUser" value="<%= idUser %>">

        <div class="form-group">
            <label for="txtUsername">Usuario</label>
            <input type="text" id="txtUsername" name="txtUsername" class="form-control" value="<%= HtmlEnc(txtUsername) %>" required>
        </div>

        <div class="form-group">
            <label for="txtPassword">Contrasena <% If esEdicion Then %>(dejar vacio para no cambiar)<% End If %></label>
            <input type="password" id="txtPassword" name="txtPassword" class="form-control" <% If Not esEdicion Then %>required minlength="6"<% End If %>>
        </div>

        <div class="form-group">
            <label for="txtEmail">Correo electronico</label>
            <input type="email" id="txtEmail" name="txtEmail" class="form-control" value="<%= HtmlEnc(txtEmail) %>" required>
        </div>

        <div class="form-group">
            <label for="txtBirthday">Fecha de nacimiento</label>
            <input type="date" id="txtBirthday" name="txtBirthday" class="form-control" value="<%= HtmlEnc(txtBirthday) %>">
        </div>

        <div class="form-group">
            <label for="txtPhoto">Foto (ej: ~/UserImages/default.jpg)</label>
            <input type="text" id="txtPhoto" name="txtPhoto" class="form-control" value="<%= HtmlEnc(txtPhoto) %>">
        </div>

        <div class="form-group">
            <label for="ddlType">Rol</label>
            <select id="ddlType" name="ddlType" class="form-control">
                <option value="0" <% If ddlType = 0 Then Response.Write "selected" %>>Usuario</option>
                <option value="1" <% If ddlType = 1 Then Response.Write "selected" %>>Administrador</option>
            </select>
        </div>

        <div class="form-actions">
            <button type="submit" class="btn btn-primary">Guardar</button>
            <a href="adminusers.asp" class="btn btn-secondary">Cancelar</a>
        </div>
    </form>
</div>

<!--#include file="includes/footer.asp" -->
