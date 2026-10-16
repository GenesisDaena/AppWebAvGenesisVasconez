<%@ Language="VBScript" CodePage=65001 %>
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001
%>
<!--#include file="includes/conexion.asp" -->
<!--#include file="includes/seguridad.asp" -->
<%
' =====================================================================
'  albumdetail.asp  -  Detalle de album (migrado de AlbumDetail.aspx)
' =====================================================================
ExigirSesion

Dim idAlbum, sql, rsAlb, rsSongs, albName, albImage, albYear, artistName
idAlbum = ToInt(Request.QueryString("id"))
If idAlbum = 0 Then Response.Redirect "albums.asp"

Set rsAlb = ObtenerAlbumPorId(idAlbum)
If rsAlb.EOF Then
    rsAlb.Close
    Set rsAlb = Nothing
    Response.Redirect "albums.asp?msg=error"
End If

albName = "" & rsAlb("ALBUM_NAME")
albImage = RutaRelativa("" & rsAlb("ALBUM_IMAGE"), "AlbumImages/default.png")
If IsNull(rsAlb("ALBUM_YEAR")) Then
    albYear = ""
Else
    albYear = Year(rsAlb("ALBUM_YEAR"))
End If
artistName = "" & rsAlb("ARTIST_NAME")
rsAlb.Close
Set rsAlb = Nothing

Set rsSongs = ObtenerCancionesPorAlbum(idAlbum)
%>
<!--#include file="includes/header.asp" -->

<div class="detail-header">
    <img src="<%= HtmlEnc(albImage) %>" alt="Album" class="detail-image" onerror="this.src='AlbumImages/default.png'">
    <div class="detail-info">
        <span class="detail-type">Album</span>
        <h1 class="detail-title"><%= HtmlEnc(albName) %></h1>
        <p class="detail-subtitle">
            <% If artistName <> "" Then %><%= HtmlEnc(artistName) %> &middot; <% End If %>
            <% If albYear <> "" Then %><%= albYear %><% End If %>
        </p>
        <div class="detail-actions">
            <button type="button" class="btn btn-primary" onclick="playAllFromAlbum()">Reproducir todo</button>
            <a href="albums.asp" class="btn btn-secondary">Volver</a>
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
    Dim idx, albSongsJson
    idx = 0
    albSongsJson = ""
    If rsSongs.EOF Then %>
        <div class="empty-state">Este album no tiene canciones asignadas.</div>
    <% Else
        Do While Not rsSongs.EOF
            idx = idx + 1
            Dim sId, sName, sPath
            sId = ToInt(rsSongs("ID_SONG"))
            sName = "" & rsSongs("SONG_NAME")
            sPath = RutaRelativa("" & rsSongs("SONG_PATH"), "SongFiles/bensound-adventure.mp3")

            If albSongsJson <> "" Then albSongsJson = albSongsJson & ","
            albSongsJson = albSongsJson & "{""path"":""" & HtmlEnc(Replace(sPath, "\", "/")) & """,""name"":""" & HtmlEnc(Replace(sName, """", "'")) & """,""id"":" & sId & "}"
    %>
        <div class="song-row">
            <span class="song-index"><%= idx %></span>
            <div class="song-info" onclick="playSong('<%= HtmlEnc(sPath) %>', '<%= HtmlEnc(Replace(sName, "'", "\'")) %>', <%= sId %>)">
                <span class="song-title"><%= HtmlEnc(sName) %></span>
            </div>
            <span class="song-plays"><%= ToInt(rsSongs("PLAYS")) %></span>
            <div class="song-action">
                <a href="addtoplaylist.asp?idSong=<%= sId %>" class="btn btn-secondary btn-sm">+ Playlist</a>
            </div>
        </div>
    <%      rsSongs.MoveNext
        Loop
    End If
    rsSongs.Close
    Set rsSongs = Nothing %>
</div>

<script>
    var albumSongs = [<%= albSongsJson %>];
    var albumIndex = 0;
    function playAllFromAlbum() {
        if (albumSongs.length === 0) { alert('Este album no tiene canciones.'); return; }
        albumIndex = 0;
        playSong(albumSongs[0].path, albumSongs[0].name, albumSongs[0].id);
    }
</script>

<!--#include file="includes/footer.asp" -->
