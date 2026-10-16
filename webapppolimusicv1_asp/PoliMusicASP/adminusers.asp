<%@ Language="VBScript" CodePage=65001 %>
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001
%>
<!--#include file="includes/conexion.asp" -->
<!--#include file="includes/seguridad.asp" -->
<%
' =====================================================================
'  adminusers.asp  -  Gestion de usuarios (migrado de AdminUsers.aspx)
'  Solo administrador
' =====================================================================
ExigirAdmin

Dim accion, errorMsg
accion = LCase(Trim("" & Request.Form("accion")))
errorMsg = ""

If accion = "delete" Then
    Dim idDel
    idDel = ToInt(Request.Form("idUser"))

    If idDel = IdUsuarioActual() Then
        errorMsg = "No puede eliminar su propio usuario."
    ElseIf idDel > 0 Then
        EliminarUsuario idDel
        Response.Redirect "adminusers.asp?msg=deleted"
    End If
End If

Dim rsUsers
Set rsUsers = ObtenerTodosUsuarios()
%>
<!--#include file="includes/header.asp" -->

<div class="page-header">
    <div class="page-header-main">
        <h1>Usuarios</h1>
        <p class="page-subtitle">Administracion de usuarios del sistema</p>
    </div>
    <div class="page-header-actions">
        <a href="useredit.asp" class="btn btn-primary">+ Nuevo usuario</a>
    </div>
</div>

<%= MensajeAlerta() %>
<% If errorMsg <> "" Then %>
    <div class="alert alert-error"><%= HtmlEnc(errorMsg) %></div>
<% End If %>

<table class="data-table">
    <thead>
        <tr>
            <th>ID</th>
            <th>Usuario</th>
            <th>Correo</th>
            <th>Cumpleanios</th>
            <th>Rol</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <% If rsUsers.EOF Then %>
            <tr><td colspan="6" class="text-center">No hay usuarios registrados.</td></tr>
        <% Else
            Do While Not rsUsers.EOF
                Dim uId, uRol
                uId  = ToInt(rsUsers("ID_USER"))
                uRol = ToInt(rsUsers("USER_TYPE"))
        %>
            <tr>
                <td><%= uId %></td>
                <td><%= HtmlEnc("" & rsUsers("USERNAME")) %></td>
                <td><%= HtmlEnc("" & rsUsers("EMAIL")) %></td>
                <td><%= FechaCorta(rsUsers("BIRTHDAY")) %></td>
                <td>
                    <% If uRol = 1 Then %>
                        <span class="badge badge-admin">Administrador</span>
                    <% Else %>
                        <span class="badge">Usuario</span>
                    <% End If %>
                </td>
                <td>
                    <a href="useredit.asp?id=<%= uId %>" class="btn btn-secondary btn-sm">Editar</a>
                    <% If uId <> IdUsuarioActual() Then %>
                    <form method="post" action="adminusers.asp" class="inline-form" onsubmit="return confirmDelete('Eliminar este usuario?');">
                        <input type="hidden" name="accion" value="delete">
                        <input type="hidden" name="idUser" value="<%= uId %>">
                        <button type="submit" class="btn btn-danger btn-sm">Eliminar</button>
                    </form>
                    <% End If %>
                </td>
            </tr>
        <%      rsUsers.MoveNext
            Loop
           End If
           rsUsers.Close
           Set rsUsers = Nothing %>
    </tbody>
</table>

<!--#include file="includes/footer.asp" -->
