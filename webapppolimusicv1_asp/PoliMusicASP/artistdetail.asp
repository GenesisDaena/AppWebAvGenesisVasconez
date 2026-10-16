<%@ Language="VBScript" CodePage=65001 %>
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001
%>
<!--#include file="includes/conexion.asp" -->
<!--#include file="includes/seguridad.asp" -->
<%
' =====================================================================
'  artistdetail.asp  -  Detalle de artista (migrado de ArtistDetail.aspx)
' =====================================================================
ExigirSesion

Dim idArtist, rsArt, rsSongs, artName, artImage
idArtist = ToInt(Request.QueryString("id"))
If idArtist = 0 Then Response.Redirect "artists.asp"

Set rsArt = ObtenerArtistaPorId(idArtist)
If rsArt.EOF Then
    rsArt.Close
    Set rsArt = Nothing
    Response.Redirect "artists.asp?msg=error"
End If

artName = "" & rsArt("ARTIST_NAME")
artImage = RutaRelativa("" & rsArt("ARTIST_IMAGE"), "ArtistImages/default.png")
rsArt.Close
Set rsArt = Nothing

Set rsSongs = ObtenerCancionesPorArtista(idArtist)
%>
<!--#include file="includes/header.asp" -->

<div class="detail-header">
    <img src="<%= HtmlEnc(artImage) %>" alt="Artista" class="detail-image" onerror="this.src='ArtistImages/default.png'">
    <div class="detail-info">
        <span class="detail-type">Artista</span>
        <h1 class="detail-title"><%= HtmlEnc(artName) %></h1>
        <p class="detail-subtitle">Canciones del artista</p>
        <div class="detail-actions">
            <button type="button" class="btn btn-primary" onclick="playAllFromArtist()">Reproducir todo</button>
            <a href="artists.asp" class="btn btn-secondary">Volver</a>
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
    Dim idx, artSongsJson
    idx = 0
    artSongsJson = ""
    If rsSongs.EOF Then %>
        <div class="empty-state">Este artista no tiene canciones registradas.</div>
    <% Else
        Do While Not rsSongs.EOF
            idx = idx + 1
            Dim sId, sName, sPath
            sId = ToInt(rsSongs("ID_SONG"))
            sName = "" & rsSongs("SONG_NAME")
            sPath = RutaRelativa("" & rsSongs("SONG_PATH"), "SongFiles/bensound-adventure.mp3")

            If artSongsJson <> "" Then artSongsJson = artSongsJson & ","
            artSongsJson = artSongsJson & "{""path"":""" & HtmlEnc(Replace(sPath, "\", "/")) & """,""name"":""" & HtmlEnc(Replace(sName, """", "'")) & """,""id"":" & sId & "}"
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
    var artistSongs = [<%= artSongsJson %>];
    function playAllFromArtist() {
        if (artistSongs.length === 0) { alert('Este artista no tiene canciones.'); return; }
        playSong(artistSongs[0].path, artistSongs[0].name, artistSongs[0].id);
    }
</script>

<!--#include file="includes/footer.asp" -->
