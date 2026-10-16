<%@ Language="VBScript" CodePage=65001 %>
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001
%>
<!--#include file="includes/conexion.asp" -->
<!--#include file="includes/seguridad.asp" -->
<%
' =====================================================================
'  songs.asp  -  Lista de canciones (migrado de Songs.aspx)
'  - Mensaje de bienvenida con el usuario de la sesion
'  - Boton de cerrar sesion
'  - Tabla HTML de canciones
'  - Reproductor <audio> funcional
'  - CRUD solo para administrador (validado tambien en el servidor)
' =====================================================================
ExigirSesion

Dim accion, msgLocal
accion = LCase(Trim("" & Request.Form("accion")))

' --- CRUD protegido en el servidor: solo administrador ---
If accion <> "" Then
    If Not EsAdmin() Then
        Response.Redirect "songs.asp?msg=noperm"
    End If

    Select Case accion
        Case "delete"
            Dim idDel
            idDel = ToInt(Request.Form("idSong"))
            If idDel > 0 Then
                EliminarCancion idDel
                Response.Redirect "songs.asp?msg=deleted"
            Else
                Response.Redirect "songs.asp?msg=error"
            End If
        Case Else
            Response.Redirect "songs.asp"
    End Select
End If

Dim rsSongs
Set rsSongs = ObtenerTodasCanciones()
%>
<!--#include file="includes/header.asp" -->

<div class="page-header">
    <div class="page-header-main">
        <h1>Song List</h1>
        <p class="page-subtitle">Bienvenido, <%= HtmlEnc(NombreUsuario()) %></p>
    </div>
    <div class="page-header-actions">
        <% If EsAdmin() Then %>
            <a href="songedit.asp" class="btn btn-primary">+ Nueva cancion</a>
        <% End If %>
        <a href="logout.asp" class="btn btn-secondary">Cerrar sesion</a>
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
    Dim contador
    contador = 0
    If rsSongs.EOF Then %>
        <div class="empty-state">No hay canciones registradas.</div>
    <% Else
        Do While Not rsSongs.EOF
            contador = contador + 1
            Dim idS, sName, sPath
            idS   = ToInt(rsSongs("ID_SONG"))
            sName = "" & rsSongs("SONG_NAME")
            sPath = RutaRelativa("" & rsSongs("SONG_PATH"), "SongFiles/bensound-adventure.mp3")
    %>
        <div class="song-row">
            <span class="song-index"><%= contador %></span>
            <div class="song-info" onclick="playSong('<%= HtmlEnc(sPath) %>', '<%= HtmlEnc(Replace(sName, "'", "\'")) %>', <%= idS %>)">
                <span class="song-title"><%= HtmlEnc(sName) %></span>
                <span class="song-artist">PoliMusic</span>
            </div>
            <span class="song-plays"><%= ToInt(rsSongs("PLAYS")) %></span>
            <div class="song-action">
                <a href="addtoplaylist.asp?idSong=<%= idS %>" class="btn btn-secondary btn-sm">+ Playlist</a>
                <% If EsAdmin() Then %>
                    <a href="songedit.asp?id=<%= idS %>" class="btn btn-secondary btn-sm">Editar</a>
                    <form method="post" action="songs.asp" class="inline-form" onsubmit="return confirmDelete('Esta seguro de eliminar la cancion?');">
                        <input type="hidden" name="accion" value="delete">
                        <input type="hidden" name="idSong" value="<%= idS %>">
                        <button type="submit" class="btn btn-danger btn-sm">Eliminar</button>
                    </form>
                <% End If %>
            </div>
        </div>
    <% 
            rsSongs.MoveNext
        Loop
    End If
    rsSongs.Close
    Set rsSongs = Nothing
    %>
</div>

<!--#include file="includes/footer.asp" -->
