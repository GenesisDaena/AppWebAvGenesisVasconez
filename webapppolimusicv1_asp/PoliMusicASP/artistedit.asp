<%@ Language="VBScript" CodePage=65001 %>
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001
%>
<!--#include file="includes/conexion.asp" -->
<!--#include file="includes/seguridad.asp" -->
<%
' =====================================================================
'  artistedit.asp  -  Crear / editar artista (migrado de ArtistEdit.aspx)
'  Solo administrador
' =====================================================================
ExigirAdmin

Dim idArtist, txtName, txtImage, errorMsg, esEdicion
idArtist = ToInt(Request.QueryString("id"))
If idArtist = 0 Then idArtist = ToInt(Request.Form("idArtist"))
esEdicion = (idArtist > 0)
errorMsg = ""
txtName = ""
txtImage = ""

If Request.ServerVariables("REQUEST_METHOD") = "POST" And Trim("" & Request.Form("accion")) = "save" Then
    txtName  = Trim("" & Request.Form("txtName"))
    txtImage = Trim("" & Request.Form("txtImage"))

    If txtName = "" Then
        errorMsg = "El nombre del artista es obligatorio."
    Else
        Dim img
        If txtImage = "" Then
            img = "~/ArtistImages/default.png"
        Else
            img = txtImage
        End If

        If esEdicion Then
            ActualizarArtista idArtist, txtName, img
            Response.Redirect "artists.asp?msg=updated"
        Else
            CrearArtista txtName, img
            Response.Redirect "artists.asp?msg=created"
        End If
    End If
End If

If esEdicion And Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
    Dim rs
    Set rs = ObtenerArtistaPorId(idArtist)
    If Not rs.EOF Then
        txtName = "" & rs("ARTIST_NAME")
        txtImage = "" & rs("ARTIST_IMAGE")
    Else
        Response.Redirect "artists.asp?msg=error"
    End If
    rs.Close
    Set rs = Nothing
End If
%>
<!--#include file="includes/header.asp" -->

<div class="page-header">
    <h1><% If esEdicion Then %>Editar artista<% Else %>Nuevo artista<% End If %></h1>
    <a href="artists.asp" class="btn btn-secondary">Volver al listado</a>
</div>

<% If errorMsg <> "" Then %>
    <div class="alert alert-error"><%= HtmlEnc(errorMsg) %></div>
<% End If %>

<div class="form-container">
    <form method="post" action="artistedit.asp">
        <input type="hidden" name="accion" value="save">
        <input type="hidden" name="idArtist" value="<%= idArtist %>">

        <div class="form-group">
            <label for="txtName">Nombre del artista</label>
            <input type="text" id="txtName" name="txtName" class="form-control" value="<%= HtmlEnc(txtName) %>" required>
        </div>

        <div class="form-group">
            <label for="txtImage">Imagen (ej: ~/ArtistImages/default.png)</label>
            <input type="text" id="txtImage" name="txtImage" class="form-control" value="<%= HtmlEnc(txtImage) %>">
        </div>

        <div class="form-actions">
            <button type="submit" class="btn btn-primary">Guardar</button>
            <a href="artists.asp" class="btn btn-secondary">Cancelar</a>
        </div>
    </form>
</div>

<!--#include file="includes/footer.asp" -->
