<%@ Language="VBScript" CodePage=65001 %>
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001
%>
<!--#include file="includes/conexion.asp" -->
<!--#include file="includes/seguridad.asp" -->
<%
' =====================================================================
'  albumedit.asp  -  Crear / editar album (migrado de AlbumEdit.aspx)
'  Solo administrador
' =====================================================================
ExigirAdmin

Dim idAlbum, txtName, txtYear, txtImage, ddlArtist, errorMsg, esEdicion
idAlbum = ToInt(Request.QueryString("id"))
If idAlbum = 0 Then idAlbum = ToInt(Request.Form("idAlbum"))
esEdicion = (idAlbum > 0)
errorMsg = ""
txtName = ""
txtYear = ""
txtImage = ""
ddlArtist = 0

If Request.ServerVariables("REQUEST_METHOD") = "POST" And Trim("" & Request.Form("accion")) = "save" Then
    txtName  = Trim("" & Request.Form("txtName"))
    txtYear  = Trim("" & Request.Form("txtYear"))
    txtImage = Trim("" & Request.Form("txtImage"))
    ddlArtist = ToInt(Request.Form("ddlArtist"))

    If txtName = "" Then
        errorMsg = "El nombre del album es obligatorio."
    Else
        Dim anio, img
        If txtYear = "" Or Not IsNumeric(txtYear) Then
            anio = Null
        Else
            anio = CDate("1/1/" & ToInt(txtYear))
        End If
        If txtImage = "" Then
            img = "~/AlbumImages/default.png"
        Else
            img = txtImage
        End If

        Dim idArtista
        If ddlArtist > 0 Then
            idArtista = ddlArtist
        Else
            idArtista = Null
        End If

        If esEdicion Then
            ActualizarAlbum idAlbum, txtName, anio, img, idArtista
            Response.Redirect "albums.asp?msg=updated"
        Else
            CrearAlbum txtName, anio, img, idArtista
            Response.Redirect "albums.asp?msg=created"
        End If
    End If
End If

If esEdicion And Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
    Dim rs
    Set rs = ObtenerAlbumPorId(idAlbum)
    If Not rs.EOF Then
        txtName = "" & rs("ALBUM_NAME")
        If Not IsNull(rs("ALBUM_YEAR")) Then txtYear = Year(rs("ALBUM_YEAR"))
        txtImage = "" & rs("ALBUM_IMAGE")
        ddlArtist = ToInt(rs("ID_ARTIST"))
    Else
        Response.Redirect "albums.asp?msg=error"
    End If
    rs.Close
    Set rs = Nothing
End If

Dim rsArt
Set rsArt = ObtenerTodosArtistas()
%>
<!--#include file="includes/header.asp" -->

<div class="page-header">
    <h1><% If esEdicion Then %>Editar album<% Else %>Nuevo album<% End If %></h1>
    <a href="albums.asp" class="btn btn-secondary">Volver al listado</a>
</div>

<% If errorMsg <> "" Then %>
    <div class="alert alert-error"><%= HtmlEnc(errorMsg) %></div>
<% End If %>

<div class="form-container">
    <form method="post" action="albumedit.asp">
        <input type="hidden" name="accion" value="save">
        <input type="hidden" name="idAlbum" value="<%= idAlbum %>">

        <div class="form-group">
            <label for="txtName">Nombre del album</label>
            <input type="text" id="txtName" name="txtName" class="form-control" value="<%= HtmlEnc(txtName) %>" required>
        </div>

        <div class="form-group">
            <label for="txtYear">Anio</label>
            <input type="number" id="txtYear" name="txtYear" class="form-control" value="<%= HtmlEnc(txtYear) %>" min="1900" max="2100">
        </div>

        <div class="form-group">
            <label for="txtImage">Imagen (ej: ~/AlbumImages/default.png)</label>
            <input type="text" id="txtImage" name="txtImage" class="form-control" value="<%= HtmlEnc(txtImage) %>">
        </div>

        <div class="form-group">
            <label for="ddlArtist">Artista</label>
            <select id="ddlArtist" name="ddlArtist" class="form-control">
                <option value="0">-- Sin artista --</option>
                <% Do While Not rsArt.EOF %>
                    <option value="<%= ToInt(rsArt("ID_ARTIST")) %>" <% If ToInt(rsArt("ID_ARTIST")) = ddlArtist Then Response.Write "selected" %>><%= HtmlEnc("" & rsArt("ARTIST_NAME")) %></option>
                <% rsArt.MoveNext
                   Loop
                   rsArt.Close
                   Set rsArt = Nothing %>
            </select>
        </div>

        <div class="form-actions">
            <button type="submit" class="btn btn-primary">Guardar</button>
            <a href="albums.asp" class="btn btn-secondary">Cancelar</a>
        </div>
    </form>
</div>

<!--#include file="includes/footer.asp" -->
