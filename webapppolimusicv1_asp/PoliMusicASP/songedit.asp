<%@ Language="VBScript" CodePage=65001 %>
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001
%>
<!--#include file="includes/conexion.asp" -->
<!--#include file="includes/seguridad.asp" -->
<%
' =====================================================================
'  songedit.asp  -  Crear / editar cancion (migrado de SongEdit.aspx)
'  Solo administrador
' =====================================================================
ExigirAdmin

Dim idSong, txtName, txtPath, errorMsg, esEdicion
idSong = ToInt(Request.QueryString("id"))
If idSong = 0 Then idSong = ToInt(Request.Form("idSong"))
esEdicion = (idSong > 0)
errorMsg = ""
txtName = ""
txtPath = ""

If Request.ServerVariables("REQUEST_METHOD") = "POST" And Trim("" & Request.Form("accion")) = "save" Then
    txtName = Trim("" & Request.Form("txtName"))
    txtPath = Trim("" & Request.Form("txtPath"))

    If txtName = "" Or txtPath = "" Then
        errorMsg = "El nombre y la ruta del archivo son obligatorios."
    Else
        If esEdicion Then
            ActualizarCancion idSong, txtName, txtPath
            Response.Redirect "songs.asp?msg=updated"
        Else
            CrearCancion txtName, txtPath
            Response.Redirect "songs.asp?msg=created"
        End If
    End If
End If

' Si es edicion y no es POST, cargar datos actuales
If esEdicion And Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
    Dim rs
    Set rs = ObtenerCancionPorId(idSong)
    If Not rs.EOF Then
        txtName = "" & rs("SONG_NAME")
        txtPath = "" & rs("SONG_PATH")
    Else
        Response.Redirect "songs.asp?msg=error"
    End If
    rs.Close
    Set rs = Nothing
End If
%>
<!--#include file="includes/header.asp" -->

<div class="page-header">
    <h1><% If esEdicion Then %>Editar cancion<% Else %>Nueva cancion<% End If %></h1>
    <a href="songs.asp" class="btn btn-secondary">Volver al listado</a>
</div>

<% If errorMsg <> "" Then %>
    <div class="alert alert-error"><%= HtmlEnc(errorMsg) %></div>
<% End If %>

<div class="form-container">
    <form method="post" action="songedit.asp">
        <input type="hidden" name="accion" value="save">
        <input type="hidden" name="idSong" value="<%= idSong %>">

        <div class="form-group">
            <label for="txtName">Nombre de la cancion</label>
            <input type="text" id="txtName" name="txtName" class="form-control" value="<%= HtmlEnc(txtName) %>" required>
        </div>

        <div class="form-group">
            <label for="txtPath">Ruta del archivo (ej: ~/SongFiles/bensound-adventure.mp3)</label>
            <input type="text" id="txtPath" name="txtPath" class="form-control" value="<%= HtmlEnc(txtPath) %>" required>
        </div>

        <div class="form-actions">
            <button type="submit" class="btn btn-primary">Guardar</button>
            <a href="songs.asp" class="btn btn-secondary">Cancelar</a>
        </div>
    </form>
</div>

<!--#include file="includes/footer.asp" -->
