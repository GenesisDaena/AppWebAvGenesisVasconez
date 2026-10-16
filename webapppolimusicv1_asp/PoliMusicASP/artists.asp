<%@ Language="VBScript" CodePage=65001 %>
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001
%>
<!--#include file="includes/conexion.asp" -->
<!--#include file="includes/seguridad.asp" -->
<%
' =====================================================================
'  artists.asp  -  Listado de artistas (migrado de Artists.aspx)
' =====================================================================
ExigirSesion

Dim accion
accion = LCase(Trim("" & Request.Form("accion")))

If accion = "delete" Then
    If Not EsAdmin() Then Response.Redirect "artists.asp?msg=noperm"
    Dim idDel
    idDel = ToInt(Request.Form("idArtist"))
    If idDel > 0 Then
        EliminarArtista idDel
        Response.Redirect "artists.asp?msg=deleted"
    End If
    Response.Redirect "artists.asp?msg=error"
End If

Dim rsArt
Set rsArt = ObtenerTodosArtistas()
%>
<!--#include file="includes/header.asp" -->

<div class="page-header">
    <div class="page-header-main">
        <h1>Artistas</h1>
        <p class="page-subtitle">Todos los artistas disponibles</p>
    </div>
    <div class="page-header-actions">
        <% If EsAdmin() Then %>
            <a href="artistedit.asp" class="btn btn-primary">+ Nuevo artista</a>
        <% End If %>
    </div>
</div>

<%= MensajeAlerta() %>

<div class="cards-grid">
    <% If rsArt.EOF Then %>
        <div class="empty-state">No hay artistas registrados.</div>
    <% Else
        Do While Not rsArt.EOF
            Dim arId, arImg
            arId = ToInt(rsArt("ID_ARTIST"))
            arImg = RutaRelativa("" & rsArt("ARTIST_IMAGE"), "ArtistImages/default.png")
    %>
        <div class="card">
            <a href="artistdetail.asp?id=<%= arId %>" class="card-link-inner">
                <img src="<%= HtmlEnc(arImg) %>" alt="Artista" class="card-image" onerror="this.style.display='none'">
                <div class="card-title"><%= HtmlEnc("" & rsArt("ARTIST_NAME")) %></div>
            </a>
            <% If EsAdmin() Then %>
            <div class="card-actions">
                <a href="artistedit.asp?id=<%= arId %>" class="btn btn-secondary btn-sm">Editar</a>
                <form method="post" action="artists.asp" class="inline-form" onsubmit="return confirmDelete('Eliminar este artista?');">
                    <input type="hidden" name="accion" value="delete">
                    <input type="hidden" name="idArtist" value="<%= arId %>">
                    <button type="submit" class="btn btn-danger btn-sm">Eliminar</button>
                </form>
            </div>
            <% End If %>
        </div>
    <%      rsArt.MoveNext
        Loop
       End If
       rsArt.Close
       Set rsArt = Nothing %>
</div>

<!--#include file="includes/footer.asp" -->
