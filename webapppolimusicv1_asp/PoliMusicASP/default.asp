<%@ Language="VBScript" CodePage=65001 %>
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001
%>
<!--#include file="includes/conexion.asp" -->
<!--#include file="includes/seguridad.asp" -->
<%
' =====================================================================
'  default.asp  -  Pantalla principal (migrado de Default.aspx)
' =====================================================================
ExigirSesion

' Canciones mas populares (top 6)
Dim rsPop
Set rsPop = EjecutarQuery("SELECT TOP 6 ID_SONG, SONG_NAME, SONG_PATH, PLAYS FROM TBL_SONG ORDER BY PLAYS DESC", Empty, Empty)

' Albumes (6)
Dim rsAlb
Set rsAlb = EjecutarQuery("SELECT TOP 6 ID_ALBUM, TITLE_ALBUM AS ALBUM_NAME, CASE WHEN RELEASE_YEAR IS NULL THEN NULL ELSE DATEFROMPARTS(RELEASE_YEAR, 1, 1) END AS ALBUM_YEAR, ALBUM_IMAGE_PATH AS ALBUM_IMAGE FROM TBL_ALBUM ORDER BY ID_ALBUM", Empty, Empty)

' Artistas (6)
Dim rsArt
Set rsArt = EjecutarQuery("SELECT TOP 6 ID_ARTIST, ARTIST_NAME, ARTIST_IMAGE FROM TBL_ARTIST ORDER BY ID_ARTIST", Empty, Empty)

' Playlists del usuario
Dim rsPl
Set rsPl = ObtenerPlaylistsPorUsuario(IdUsuarioActual())
%>
<!--#include file="includes/header.asp" -->

<div class="page-header">
    <div class="page-header-main">
        <h1>Hola, <%= HtmlEnc(NombreUsuario()) %>!</h1>
        <p class="page-subtitle">Bienvenido a tu musica</p>
    </div>
    <div class="page-header-actions">
        <a href="logout.asp" class="btn btn-secondary">Cerrar sesion</a>
    </div>
</div>

<%= MensajeAlerta() %>

<!-- Canciones populares -->
<section class="content-section">
    <h2 class="section-title">Canciones populares</h2>
    <div class="cards-grid">
        <% If rsPop.EOF Then %>
            <div class="empty-state">Aun no hay canciones.</div>
        <% Else
            Do While Not rsPop.EOF
                Dim pId, pName, pPath
                pId = ToInt(rsPop("ID_SONG"))
                pName = "" & rsPop("SONG_NAME")
                pPath = RutaRelativa("" & rsPop("SONG_PATH"), "SongFiles/bensound-adventure.mp3")
        %>
            <div class="card" onclick="playSong('<%= HtmlEnc(pPath) %>', '<%= HtmlEnc(Replace(pName, "'", "\'")) %>', <%= pId %>)">
                <div class="card-icon">&#9835;</div>
                <div class="card-title"><%= HtmlEnc(pName) %></div>
                <div class="card-subtitle"><%= ToInt(rsPop("PLAYS")) %> reproducciones</div>
            </div>
        <%      rsPop.MoveNext
            Loop
           End If
           rsPop.Close
           Set rsPop = Nothing %>
    </div>
</section>

<!-- Albumes -->
<section class="content-section">
    <h2 class="section-title">Albumes</h2>
    <div class="cards-grid">
        <% 
        Dim prodCount
        prodCount = 0
        If Not rsAlb.EOF Then
            Do While Not rsAlb.EOF And prodCount < 6
                prodCount = prodCount + 1
                Dim alImg
                alImg = RutaRelativa("" & rsAlb("ALBUM_IMAGE"), "AlbumImages/default.png")
        %>
            <a class="card card-link" href="albumdetail.asp?id=<%= ToInt(rsAlb("ID_ALBUM")) %>">
                <img src="<%= HtmlEnc(alImg) %>" alt="Album" class="card-image" onerror="this.style.display='none'">
                <div class="card-title"><%= HtmlEnc("" & rsAlb("ALBUM_NAME")) %></div>
                <div class="card-subtitle"><%= FechaCorta(rsAlb("ALBUM_YEAR")) %></div>
            </a>
        <%      rsAlb.MoveNext
            Loop
        End If
        If rsAlb.EOF And prodCount = 0 Then %>
            <div class="empty-state">Aun no hay albumes.</div>
        <% End If
           rsAlb.Close
           Set rsAlb = Nothing %>
    </div>
</section>

<!-- Artistas -->
<section class="content-section">
    <h2 class="section-title">Artistas</h2>
    <div class="cards-grid">
        <% 
        Dim artCount
        artCount = 0
        If Not rsArt.EOF Then
            Do While Not rsArt.EOF And artCount < 6
                artCount = artCount + 1
                Dim arImg
                arImg = RutaRelativa("" & rsArt("ARTIST_IMAGE"), "ArtistImages/default.png")
        %>
            <a class="card card-link" href="artistdetail.asp?id=<%= ToInt(rsArt("ID_ARTIST")) %>">
                <img src="<%= HtmlEnc(arImg) %>" alt="Artista" class="card-image" onerror="this.style.display='none'">
                <div class="card-title"><%= HtmlEnc("" & rsArt("ARTIST_NAME")) %></div>
            </a>
        <%      rsArt.MoveNext
            Loop
        End If
        If rsArt.EOF And artCount = 0 Then %>
            <div class="empty-state">Aun no hay artistas.</div>
        <% End If
           rsArt.Close
           Set rsArt = Nothing %>
    </div>
</section>

<!-- Mis playlists -->
<section class="content-section">
    <div class="section-header-row">
        <h2 class="section-title">Mis playlists</h2>
        <a href="playlists.asp" class="btn btn-secondary btn-sm">Ver todas</a>
    </div>
    <div class="cards-grid">
        <% 
        Dim plCount
        plCount = 0
        If Not rsPl.EOF Then
            Do While Not rsPl.EOF
                plCount = plCount + 1
                Dim plImg, plTipo
                plImg = RutaRelativa("" & rsPl("PLAYLIST_IMAGE"), "PlaylistImages/default.jpg")
                If ToInt(rsPl("PLAYLIST_TYPE")) = 1 Then
                    plTipo = "Privada"
                Else
                    plTipo = "Publica"
                End If
        %>
            <a class="card card-link" href="playlistdetail.asp?id=<%= ToInt(rsPl("ID_PLAYLIST")) %>">
                <img src="<%= HtmlEnc(plImg) %>" alt="Playlist" class="card-image" onerror="this.style.display='none'">
                <div class="card-title"><%= HtmlEnc("" & rsPl("PLAYLIST_NAME")) %></div>
                <div class="card-subtitle"><%= plTipo %></div>
            </a>
        <%      rsPl.MoveNext
            Loop
        End If
        If plCount = 0 Then %>
            <div class="empty-state">No tienes playlists. <a href="playlistedit.asp">Crea una</a>.</div>
        <% End If
           rsPl.Close
           Set rsPl = Nothing %>
    </div>
</section>

<!--#include file="includes/footer.asp" -->
