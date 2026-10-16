<%@ Language="VBScript" CodePage=65001 %>
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001
%>
<!--#include file="includes/conexion.asp" -->
<!--#include file="includes/seguridad.asp" -->
<%
' =====================================================================
'  addtoplaylist.asp  -  Agregar canciones a una playlist
'  (migrado de AddToPlaylist.aspx)
'  - Con idPlaylist: muestra las canciones disponibles para agregar
'  - Con idSong: permite elegir la playlist destino
' =====================================================================
ExigirSesion

Dim idPlaylist, idSong, errorMsg
idPlaylist = ToInt(Request.QueryString("idPlaylist"))
idSong = ToInt(Request.QueryString("idSong"))
errorMsg = ""

If idPlaylist = 0 Then idPlaylist = ToInt(Request.Form("idPlaylist"))
If idSong = 0 Then idSong = ToInt(Request.Form("idSong"))

' --- Procesar agregar (POST) ---
If Request.ServerVariables("REQUEST_METHOD") = "POST" And LCase(Trim("" & Request.Form("accion"))) = "add" Then
    Dim plDest, songSel
    plDest  = ToInt(Request.Form("idPlaylist"))
    songSel = ToInt(Request.Form("idSong"))

    If plDest = 0 Or songSel = 0 Then
        errorMsg = "Debe seleccionar una playlist y una cancion."
    Else
        ' Validar que el usuario pueda editar la playlist destino
        Dim rsOwn, ownId
        Set rsOwn = ObtenerPlaylistPorId(plDest)
        If rsOwn.EOF Then
            errorMsg = "La playlist seleccionada no existe."
        Else
            ownId = ToInt(rsOwn("ID_USER"))
            rsOwn.Close : Set rsOwn = Nothing

            If Not PuedeEditarPlaylist(ownId) Then
                Response.Redirect "playlists.asp?msg=denied"
            ElseIf ExisteCancionEnPlaylist(plDest, songSel) Then
                Response.Redirect "playlistdetail.asp?id=" & plDest & "&msg=added"
            Else
                AgregarCancionAPlaylist plDest, songSel
                Response.Redirect "playlistdetail.asp?id=" & plDest & "&msg=added"
            End If
        End If
    End If
End If

' Playlists disponibles para el usuario actual (o todas si es admin)
Dim rsPls
If EsAdmin() Then
    Set rsPls = ObtenerTodasPlaylists()
Else
    Set rsPls = ObtenerPlaylistsPorUsuario(IdUsuarioActual())
End If

' Canciones disponibles
Dim rsSongs
Set rsSongs = ObtenerTodasCanciones()

' Nombre de la playlist destino si viene por querystring
Dim nomPlaylist
nomPlaylist = ""
If idPlaylist > 0 Then
    Dim rsN
    Set rsN = ObtenerPlaylistPorId(idPlaylist)
    If Not rsN.EOF Then nomPlaylist = "" & rsN("PLAYLIST_NAME")
    rsN.Close : Set rsN = Nothing
End If

' Nombre de la cancion si viene por querystring
Dim nomCancion
nomCancion = ""
If idSong > 0 Then
    Dim rsS
    Set rsS = ObtenerCancionPorId(idSong)
    If Not rsS.EOF Then nomCancion = "" & rsS("SONG_NAME")
    rsS.Close : Set rsS = Nothing
End If
%>
<!--#include file="includes/header.asp" -->

<div class="page-header">
    <div class="page-header-main">
        <h1>Agregar a playlist</h1>
        <p class="page-subtitle">
            <% If nomPlaylist <> "" Then %>
                Agregar una cancion a: <strong><%= HtmlEnc(nomPlaylist) %></strong>
            <% ElseIf nomCancion <> "" Then %>
                Agregar la cancion <strong><%= HtmlEnc(nomCancion) %></strong> a una playlist
            <% Else %>
                Selecciona la playlist y la cancion
            <% End If %>
        </p>
    </div>
    <div class="page-header-actions">
        <a href="playlists.asp" class="btn btn-secondary">Mis playlists</a>
    </div>
</div>

<% If errorMsg <> "" Then %>
    <div class="alert alert-error"><%= HtmlEnc(errorMsg) %></div>
<% End If %>
<%= MensajeAlerta() %>

<div class="form-container">
    <form method="post" action="addtoplaylist.asp">
        <input type="hidden" name="accion" value="add">

        <div class="form-group">
            <label for="idPlaylist">Playlist</label>
            <select id="idPlaylist" name="idPlaylist" class="form-control" required>
                <option value="">-- Seleccione una playlist --</option>
                <% If Not rsPls.EOF Then
                    Do While Not rsPls.EOF
                        Dim plId, plTipo
                        plId = ToInt(rsPls("ID_PLAYLIST"))
                        If ToInt(rsPls("PLAYLIST_TYPE")) = 1 Then
                            plTipo = "Privada"
                        Else
                            plTipo = "Publica"
                        End If
                %>
                    <option value="<%= plId %>" <% If plId = idPlaylist Then Response.Write "selected" %>>
                        <%= HtmlEnc("" & rsPls("PLAYLIST_NAME")) %> (<%= plTipo %>)<% If EsAdmin() Then Response.Write " - " & HtmlEnc("" & rsPls("USERNAME")) %>
                    </option>
                <%      rsPls.MoveNext
                    Loop
                End If
                rsPls.Close
                Set rsPls = Nothing %>
            </select>
        </div>

        <div class="form-group">
            <label for="idSong">Cancion</label>
            <select id="idSong" name="idSong" class="form-control" required>
                <option value="">-- Seleccione una cancion --</option>
                <% If Not rsSongs.EOF Then
                    Do While Not rsSongs.EOF
                        Dim sId
                        sId = ToInt(rsSongs("ID_SONG"))
                %>
                    <option value="<%= sId %>" <% If sId = idSong Then Response.Write "selected" %>><%= HtmlEnc("" & rsSongs("SONG_NAME")) %></option>
                <%      rsSongs.MoveNext
                    Loop
                End If
                rsSongs.Close
                Set rsSongs = Nothing %>
            </select>
        </div>

        <div class="form-actions">
            <button type="submit" class="btn btn-primary">Agregar</button>
            <a href="playlists.asp" class="btn btn-secondary">Cancelar</a>
        </div>
    </form>
</div>

<!--#include file="includes/footer.asp" -->
