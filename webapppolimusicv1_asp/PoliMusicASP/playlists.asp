<%@ Language="VBScript" CodePage=65001 %>
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001
%>
<!--#include file="includes/conexion.asp" -->
<!--#include file="includes/seguridad.asp" -->
<%
' =====================================================================
'  playlists.asp  -  Listado de playlists (migrado de Playlists.aspx)
'  - Administrador ve todas las playlists
'  - Usuario normal ve solo las suyas
'  - El usuario normal SI puede crear / actualizar / eliminar las suyas
' =====================================================================
ExigirSesion

Dim accion, idPl, rsPl, esAdmin
esAdmin = EsAdmin()
accion = LCase(Trim("" & Request.Form("accion")))

If accion = "delete" Then
    idPl = ToInt(Request.Form("idPlaylist"))
    If idPl > 0 Then
        Dim rsOwner
        Set rsOwner = ObtenerPlaylistPorId(idPl)
        If Not rsOwner.EOF Then
            If PuedeEditarPlaylist(rsOwner("ID_USER")) Then
                rsOwner.Close : Set rsOwner = Nothing
                EliminarPlaylist idPl
                Response.Redirect "playlists.asp?msg=deleted"
            Else
                rsOwner.Close : Set rsOwner = Nothing
                Response.Redirect "playlists.asp?msg=denied"
            End If
        Else
            rsOwner.Close : Set rsOwner = Nothing
            Response.Redirect "playlists.asp?msg=error"
        End If
    End If
    Response.Redirect "playlists.asp"
End If

If esAdmin Then
    Set rsPl = ObtenerTodasPlaylists()
Else
    Set rsPl = ObtenerPlaylistsPorUsuario(IdUsuarioActual())
End If
%>
<!--#include file="includes/header.asp" -->

<div class="page-header">
    <div class="page-header-main">
        <h1>Playlists</h1>
        <p class="page-subtitle"><% If esAdmin Then %>Todas las playlists del sistema<% Else %>Tus playlists personales<% End If %></p>
    </div>
    <div class="page-header-actions">
        <a href="playlistedit.asp" class="btn btn-primary">+ Nueva playlist</a>
    </div>
</div>

<%= MensajeAlerta() %>

<div class="cards-grid">
    <% If rsPl.EOF Then %>
        <div class="empty-state">No hay playlists. <a href="playlistedit.asp">Crea la primera</a>.</div>
    <% Else
        Do While Not rsPl.EOF
            Dim pId, pImg, pTipo, pOwnerId, pOwner, puedeEditar
            pId = ToInt(rsPl("ID_PLAYLIST"))
            pImg = RutaRelativa("" & rsPl("PLAYLIST_IMAGE"), "PlaylistImages/default.jpg")
            pOwnerId = ToInt(rsPl("ID_USER"))
            If ToInt(rsPl("PLAYLIST_TYPE")) = 1 Then
                pTipo = "Privada"
            Else
                pTipo = "Publica"
            End If
            puedeEditar = PuedeEditarPlaylist(pOwnerId)
            If esAdmin Then
                pOwner = "" & rsPl("USERNAME")
            Else
                pOwner = ""
            End If
    %>
        <div class="card">
            <a href="playlistdetail.asp?id=<%= pId %>" class="card-link-inner">
                <img src="<%= HtmlEnc(pImg) %>" alt="Playlist" class="card-image" onerror="this.style.display='none'">
                <div class="card-title"><%= HtmlEnc("" & rsPl("PLAYLIST_NAME")) %></div>
                <div class="card-subtitle">
                    <%= pTipo %><% If pOwner <> "" Then %> &middot; <%= HtmlEnc(pOwner) %><% End If %>
                </div>
            </a>
            <% If puedeEditar Then %>
            <div class="card-actions">
                <a href="playlistedit.asp?id=<%= pId %>" class="btn btn-secondary btn-sm">Editar</a>
                <form method="post" action="playlists.asp" class="inline-form" onsubmit="return confirmDelete('Eliminar esta playlist?');">
                    <input type="hidden" name="accion" value="delete">
                    <input type="hidden" name="idPlaylist" value="<%= pId %>">
                    <button type="submit" class="btn btn-danger btn-sm">Eliminar</button>
                </form>
            </div>
            <% End If %>
        </div>
    <%      rsPl.MoveNext
        Loop
       End If
       rsPl.Close
       Set rsPl = Nothing %>
</div>

<!--#include file="includes/footer.asp" -->
