<%@ Language="VBScript" CodePage=65001 %>
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001
%>
<!--#include file="includes/conexion.asp" -->
<!--#include file="includes/seguridad.asp" -->
<%
' =====================================================================
'  playlistdetail.asp  -  Detalle de playlist (de PlaylistDetail.aspx)
'  Permite quitar canciones al propietario (o al admin)
' =====================================================================
ExigirSesion

Dim idPlaylist, rsPl, rsSongs, plName, plImage, plTipo, ownerId, puedeEditar
idPlaylist = ToInt(Request.QueryString("id"))
If idPlaylist = 0 Then Response.Redirect "playlists.asp"

Set rsPl = ObtenerPlaylistPorId(idPlaylist)
If rsPl.EOF Then
    rsPl.Close : Set rsPl = Nothing
    Response.Redirect "playlists.asp?msg=error"
End If

plName  = "" & rsPl("PLAYLIST_NAME")
plImage = RutaRelativa("" & rsPl("PLAYLIST_IMAGE"), "PlaylistImages/default.jpg")
ownerId = ToInt(rsPl("ID_USER"))
If ToInt(rsPl("PLAYLIST_TYPE")) = 1 Then
    plTipo = "Privada"
Else
    plTipo = "Publica"
End If
puedeEditar = PuedeEditarPlaylist(ownerId)
rsPl.Close
Set rsPl = Nothing

' --- Quitar cancion (POST, con validacion de permisos) ---
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    If LCase(Trim("" & Request.Form("accion"))) = "removesong" Then
        If Not puedeEditar Then
            Response.Redirect "playlistdetail.asp?id=" & idPlaylist & "&msg=denied"
        End If
        Dim idSongDel
        idSongDel = ToInt(Request.Form("idSong"))
        If idSongDel > 0 Then
            QuitarCancionDePlaylist idPlaylist, idSongDel
            Response.Redirect "playlistdetail.asp?id=" & idPlaylist & "&msg=removed"
        End If
    End If
End If

Set rsSongs = ObtenerCancionesDePlaylist(idPlaylist)
%>
<!--#include file="includes/header.asp" -->

<div class="detail-header">
    <img src="<%= HtmlEnc(plImage) %>" alt="Playlist" class="detail-image" onerror="this.src='PlaylistImages/default.jpg'">
    <div class="detail-info">
        <span class="detail-type">Playlist &middot; <%= plTipo %></span>
        <h1 class="detail-title"><%= HtmlEnc(plName) %></h1>
        <p class="detail-subtitle">Canciones de la playlist</p>
        <div class="detail-actions">
            <button type="button" class="btn btn-primary" onclick="playAllFromPlaylist()">Reproducir todo</button>
            <a href="addtoplaylist.asp?idPlaylist=<%= idPlaylist %>" class="btn btn-secondary">Agregar canciones</a>
            <% If puedeEditar Then %>
                <a href="playlistedit.asp?id=<%= idPlaylist %>" class="btn btn-secondary">Editar</a>
            <% End If %>
            <a href="playlists.asp" class="btn btn-secondary">Volver</a>
        </div>
    </div>
</div>

<%= MensajeAlerta() %>

<div class="song-list">
    <div class="song-list-header">
        <span class="col-index">#</span>
        <span class="col-title">Titulo</span>
        <span class="col-plays">Reproducciones</span>
        <span class="col-actions">Acciones</span>
    </div>

    <% 
    Dim idx, plSongsJson
    idx = 0
    plSongsJson = ""
    If rsSongs.EOF Then %>
        <div class="empty-state">Esta playlist no tiene canciones. <a href="addtoplaylist.asp?idPlaylist=<%= idPlaylist %>">Agrega algunas</a>.</div>
    <% Else
        Do While Not rsSongs.EOF
            idx = idx + 1
            Dim sId, sName, sPath, sArt
            sId = ToInt(rsSongs("ID_SONG"))
            sName = "" & rsSongs("SONG_NAME")
            sArt = "" & rsSongs("ARTIST_NAME")
            sPath = RutaRelativa("" & rsSongs("SONG_PATH"), "SongFiles/bensound-adventure.mp3")

            If plSongsJson <> "" Then plSongsJson = plSongsJson & ","
            plSongsJson = plSongsJson & "{""path"":""" & HtmlEnc(Replace(sPath, "\", "/")) & """,""name"":""" & HtmlEnc(Replace(sName, """", "'")) & """,""id"":" & sId & "}"
    %>
        <div class="song-row">
            <span class="song-index"><%= idx %></span>
            <div class="song-info" onclick="playSong('<%= HtmlEnc(sPath) %>', '<%= HtmlEnc(Replace(sName, "'", "\'")) %>', <%= sId %>)">
                <span class="song-title"><%= HtmlEnc(sName) %></span>
                <% If sArt <> "" Then %><span class="song-artist"><%= HtmlEnc(sArt) %></span><% End If %>
            </div>
            <span class="song-plays"><%= ToInt(rsSongs("PLAYS")) %></span>
            <div class="song-action">
                <% If puedeEditar Then %>
                <form method="post" action="playlistdetail.asp?id=<%= idPlaylist %>" class="inline-form" onsubmit="return confirmDelete('Quitar esta cancion de la playlist?');">
                    <input type="hidden" name="accion" value="removesong">
                    <input type="hidden" name="idSong" value="<%= sId %>">
                    <button type="submit" class="btn btn-danger btn-sm">Quitar</button>
                </form>
                <% End If %>
            </div>
        </div>
    <%      rsSongs.MoveNext
        Loop
    End If
    rsSongs.Close
    Set rsSongs = Nothing %>
</div>

<script>
    var playlistSongs = [<%= plSongsJson %>];
    function playAllFromPlaylist() {
        if (playlistSongs.length === 0) { alert('Esta playlist no tiene canciones.'); return; }
        playSong(playlistSongs[0].path, playlistSongs[0].name, playlistSongs[0].id);
    }
</script>

<!--#include file="includes/footer.asp" -->
