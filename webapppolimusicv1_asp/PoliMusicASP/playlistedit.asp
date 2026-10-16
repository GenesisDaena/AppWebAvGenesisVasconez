<%@ Language="VBScript" CodePage=65001 %>
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001
%>
<!--#include file="includes/conexion.asp" -->
<!--#include file="includes/seguridad.asp" -->
<%
' =====================================================================
'  playlistedit.asp  -  Crear / editar playlist (de PlaylistEdit.aspx)
'  Disponible para cualquier usuario autenticado (sobre las suyas)
' =====================================================================
ExigirSesion

Dim idPlaylist, txtName, ddlType, txtImage, errorMsg, esEdicion, ownerId
idPlaylist = ToInt(Request.QueryString("id"))
If idPlaylist = 0 Then idPlaylist = ToInt(Request.Form("idPlaylist"))
esEdicion = (idPlaylist > 0)
errorMsg = ""
txtName = ""
txtImage = ""
ddlType = 0
ownerId = IdUsuarioActual()

' Verificar permisos sobre la playlist a editar
If esEdicion Then
    Dim rsOwn
    Set rsOwn = ObtenerPlaylistPorId(idPlaylist)
    If rsOwn.EOF Then
        rsOwn.Close : Set rsOwn = Nothing
        Response.Redirect "playlists.asp?msg=error"
    End If
    ownerId = ToInt(rsOwn("ID_USER"))
    If Not PuedeEditarPlaylist(ownerId) Then
        rsOwn.Close : Set rsOwn = Nothing
        Response.Redirect "playlists.asp?msg=denied"
    End If
    rsOwn.Close : Set rsOwn = Nothing
End If

If Request.ServerVariables("REQUEST_METHOD") = "POST" And Trim("" & Request.Form("accion")) = "save" Then
    txtName  = Trim("" & Request.Form("txtName"))
    ddlType  = ToInt(Request.Form("ddlType"))
    txtImage = Trim("" & Request.Form("txtImage"))

    If txtName = "" Then
        errorMsg = "El nombre de la playlist es obligatorio."
    Else
        Dim img
        If txtImage = "" Then
            img = "~/PlaylistImages/default.jpg"
        Else
            img = txtImage
        End If

        If esEdicion Then
            ActualizarPlaylist idPlaylist, txtName, ddlType, img
            Response.Redirect "playlists.asp?msg=updated"
        Else
            CrearPlaylist txtName, ddlType, img, IdUsuarioActual()
            Response.Redirect "playlists.asp?msg=created"
        End If
    End If
End If

If esEdicion And Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
    Dim rs
    Set rs = ObtenerPlaylistPorId(idPlaylist)
    If Not rs.EOF Then
        txtName = "" & rs("PLAYLIST_NAME")
        ddlType = ToInt(rs("PLAYLIST_TYPE"))
        txtImage = "" & rs("PLAYLIST_IMAGE")
    End If
    rs.Close
    Set rs = Nothing
End If
%>
<!--#include file="includes/header.asp" -->

<div class="page-header">
    <h1><% If esEdicion Then %>Editar playlist<% Else %>Nueva playlist<% End If %></h1>
    <a href="playlists.asp" class="btn btn-secondary">Volver al listado</a>
</div>

<% If errorMsg <> "" Then %>
    <div class="alert alert-error"><%= HtmlEnc(errorMsg) %></div>
<% End If %>

<div class="form-container">
    <form method="post" action="playlistedit.asp">
        <input type="hidden" name="accion" value="save">
        <input type="hidden" name="idPlaylist" value="<%= idPlaylist %>">

        <div class="form-group">
            <label for="txtName">Nombre de la playlist</label>
            <input type="text" id="txtName" name="txtName" class="form-control" value="<%= HtmlEnc(txtName) %>" required>
        </div>

        <div class="form-group">
            <label for="ddlType">Tipo</label>
            <select id="ddlType" name="ddlType" class="form-control">
                <option value="0" <% If ddlType = 0 Then Response.Write "selected" %>>Publica</option>
                <option value="1" <% If ddlType = 1 Then Response.Write "selected" %>>Privada</option>
            </select>
        </div>

        <div class="form-group">
            <label for="txtImage">Imagen (ej: ~/PlaylistImages/default.jpg)</label>
            <input type="text" id="txtImage" name="txtImage" class="form-control" value="<%= HtmlEnc(txtImage) %>">
        </div>

        <div class="form-actions">
            <button type="submit" class="btn btn-primary">Guardar</button>
            <a href="playlists.asp" class="btn btn-secondary">Cancelar</a>
        </div>
    </form>
</div>

<!--#include file="includes/footer.asp" -->
