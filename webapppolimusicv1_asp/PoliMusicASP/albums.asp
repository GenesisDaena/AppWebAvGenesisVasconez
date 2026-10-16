<%@ Language="VBScript" CodePage=65001 %>
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001
%>
<!--#include file="includes/conexion.asp" -->
<!--#include file="includes/seguridad.asp" -->
<%
' =====================================================================
'  albums.asp  -  Listado de albumes (migrado de Albums.aspx)
' =====================================================================
ExigirSesion

Dim accion
accion = LCase(Trim("" & Request.Form("accion")))

If accion = "delete" Then
    If Not EsAdmin() Then Response.Redirect "albums.asp?msg=noperm"
    Dim idDel
    idDel = ToInt(Request.Form("idAlbum"))
    If idDel > 0 Then
        EliminarAlbum idDel
        Response.Redirect "albums.asp?msg=deleted"
    End If
    Response.Redirect "albums.asp?msg=error"
End If

Dim rsAlb
Set rsAlb = ObtenerTodosAlbumes()
%>
<!--#include file="includes/header.asp" -->

<div class="page-header">
    <div class="page-header-main">
        <h1>Albumes</h1>
        <p class="page-subtitle">Explora todos los albumes disponibles</p>
    </div>
    <div class="page-header-actions">
        <% If EsAdmin() Then %>
            <a href="albumedit.asp" class="btn btn-primary">+ Nuevo album</a>
        <% End If %>
    </div>
</div>

<%= MensajeAlerta() %>

<div class="cards-grid">
    <% If rsAlb.EOF Then %>
        <div class="empty-state">No hay albumes registrados.</div>
    <% Else
        Do While Not rsAlb.EOF
            Dim alId, alImg
            alId = ToInt(rsAlb("ID_ALBUM"))
            alImg = RutaRelativa("" & rsAlb("ALBUM_IMAGE"), "AlbumImages/default.png")
    %>
        <div class="card">
            <a href="albumdetail.asp?id=<%= alId %>" class="card-link-inner">
                <img src="<%= HtmlEnc(alImg) %>" alt="Album" class="card-image" onerror="this.style.display='none'">
                <div class="card-title"><%= HtmlEnc("" & rsAlb("ALBUM_NAME")) %></div>
                <div class="card-subtitle"><%= FechaCorta(rsAlb("ALBUM_YEAR")) %></div>
            </a>
            <% If EsAdmin() Then %>
            <div class="card-actions">
                <a href="albumedit.asp?id=<%= alId %>" class="btn btn-secondary btn-sm">Editar</a>
                <form method="post" action="albums.asp" class="inline-form" onsubmit="return confirmDelete('Eliminar este album?');">
                    <input type="hidden" name="accion" value="delete">
                    <input type="hidden" name="idAlbum" value="<%= alId %>">
                    <button type="submit" class="btn btn-danger btn-sm">Eliminar</button>
                </form>
            </div>
            <% End If %>
        </div>
    <%      rsAlb.MoveNext
        Loop
       End If
       rsAlb.Close
       Set rsAlb = Nothing %>
</div>

<!--#include file="includes/footer.asp" -->
