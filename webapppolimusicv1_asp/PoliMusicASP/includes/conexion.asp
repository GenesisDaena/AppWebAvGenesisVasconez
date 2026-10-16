<%
' =====================================================================
'  conexion.asp  -  Capa de acceso a datos (Version ASP Clasico)
'  Migrado desde App_Code/DatabaseHelper.cs (ASP.NET Web Forms / C#)
'  Proveedor : MSOLEDBSQL (Microsoft OLE DB Driver for SQL Server)
'  Base      : BDD_PoliMusic
' =====================================================================

Const CONN_STRING = "Provider=SQLOLEDB;Data Source=localhost,14333;Initial Catalog=BDD_PoliMusic;User ID=sa;Password=Politecnica1;"

' Crea y abre una conexion nueva. El llamador es responsable de cerrarla.
Function AbrirConexion()
    Dim cn
    Set cn = Server.CreateObject("ADODB.Connection")
    cn.ConnectionTimeout = 15
    cn.CommandTimeout = 30
    cn.Open CONN_STRING
    Set AbrirConexion = cn
End Function

' Ejecuta una consulta con parametros y devuelve un Recordset abierto (client-side)
' arrParams: Array de valores. arrTypes: Array opcional de tipos ADODB (adInteger, adVarWChar, ...)
Function EjecutarQuery(sql, arrParams, arrTypes)
    Dim cn, cmd, i
    Set cn = AbrirConexion()
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = cn
    cmd.CommandType = 1 ' adCmdText
    cmd.CommandText = sql

    If IsArray(arrParams) Then
        For i = 0 To UBound(arrParams)
            If IsArray(arrTypes) Then
                cmd.Parameters.Append cmd.CreateParameter("p" & i, arrTypes(i), 1, 4000, arrParams(i))
            Else
                cmd.Parameters.Append cmd.CreateParameter("p" & i, 200, 1, 4000, arrParams(i)) ' adVarWChar
            End If
        Next
    End If

    Dim rs
    Set rs = Server.CreateObject("ADODB.Recordset")
    rs.CursorLocation = 3 ' adUseClient
    rs.Open cmd, , 3, 1  ' adOpenStatic, adLockReadOnly
    Set rs.ActiveConnection = Nothing
    cn.Close
    Set cn = Nothing
    Set cmd = Nothing
    Set EjecutarQuery = rs
End Function

' Ejecuta una sentencia de accion (INSERT/UPDATE/DELETE) y devuelve filas afectadas
Function EjecutarComando(sql, arrParams, arrTypes)
    Dim cn, cmd, i, afectadas
    Set cn = AbrirConexion()
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = cn
    cmd.CommandType = 1
    cmd.CommandText = sql

    If IsArray(arrParams) Then
        For i = 0 To UBound(arrParams)
            If IsArray(arrTypes) Then
                cmd.Parameters.Append cmd.CreateParameter("p" & i, arrTypes(i), 1, 4000, arrParams(i))
            Else
                cmd.Parameters.Append cmd.CreateParameter("p" & i, 200, 1, 4000, arrParams(i))
            End If
        Next
    End If

    cmd.Execute afectadas
    cn.Close
    Set cn = Nothing
    Set cmd = Nothing
    EjecutarComando = afectadas
End Function

' Ejecuta un INSERT y devuelve el SCOPE_IDENTITY() generado
Function EjecutarInsertIdentity(sql, arrParams, arrTypes)
    Dim cn, cmd, i, rs, nuevoId
    Set cn = AbrirConexion()
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = cn
    cmd.CommandType = 1
    cmd.CommandText = sql & "; SELECT SCOPE_IDENTITY() AS NUEVO_ID;"

    If IsArray(arrParams) Then
        For i = 0 To UBound(arrParams)
            If IsArray(arrTypes) Then
                cmd.Parameters.Append cmd.CreateParameter("p" & i, arrTypes(i), 1, 4000, arrParams(i))
            Else
                cmd.Parameters.Append cmd.CreateParameter("p" & i, 200, 1, 4000, arrParams(i))
            End If
        Next
    End If

    nuevoId = 0
    Set rs = cmd.Execute
    If Not rs.EOF Then
        If Not IsNull(rs("NUEVO_ID")) Then nuevoId = CLng(rs("NUEVO_ID"))
    End If
    rs.Close
    cn.Close
    Set rs = Nothing
    Set cn = Nothing
    Set cmd = Nothing
    EjecutarInsertIdentity = nuevoId
End Function

' Devuelve un unico valor (primera columna de la primera fila) o "" si no hay datos
Function EjecutarEscalar(sql, arrParams, arrTypes)
    Dim rs, valor
    valor = ""
    Set rs = EjecutarQuery(sql, arrParams, arrTypes)
    If Not rs.EOF Then
        If Not IsNull(rs(0)) Then valor = rs(0)
    End If
    rs.Close
    Set rs = Nothing
    EjecutarEscalar = valor
End Function

' =====================================================================
'  UTILIDADES GENERALES
' =====================================================================

' Escapa comillas simples para uso en SQL dinamico (solo cuando NO se puedan usar parametros)
Function SqlEsc(valor)
    If IsNull(valor) Then
        SqlEsc = ""
    Else
        SqlEsc = Replace(CStr(valor), "'", "''")
    End If
End Function

' Codifica HTML para evitar XSS al imprimir datos en la pagina
Function HtmlEnc(valor)
    Dim s
    If IsNull(valor) Then
        HtmlEnc = ""
        Exit Function
    End If
    s = CStr(valor)
    s = Replace(s, "&", "&amp;")
    s = Replace(s, "<", "&lt;")
    s = Replace(s, ">", "&gt;")
    s = Replace(s, Chr(34), "&quot;")
    s = Replace(s, "'", "&#39;")
    HtmlEnc = s
End Function

' Fecha corta segura para mostrar
Function FechaCorta(valor)
    If IsNull(valor) Then
        FechaCorta = "-"
    ElseIf IsDate(valor) Then
        FechaCorta = Year(valor) & "-" & Right("0" & Month(valor), 2) & "-" & Right("0" & Day(valor), 2)
    Else
        FechaCorta = "-"
    End If
End Function

' Convierte el valor de un formulario a entero seguro
Function ToInt(valor)
    If IsNull(valor) Then
        ToInt = 0
    ElseIf IsNumeric(valor) Then
        ToInt = CLng(valor)
    Else
        ToInt = 0
    End If
End Function

' Normaliza la ruta de un archivo almacenado con el prefijo ~/ de ASP.NET
' Ej: "~/SongFiles/x.mp3"  ->  "SongFiles/x.mp3"
Function RutaRelativa(valor, valorPorDefecto)
    Dim s
    If IsNull(valor) Or Trim(CStr(valor)) = "" Then
        RutaRelativa = valorPorDefecto
        Exit Function
    End If
    s = Trim(CStr(valor))
    s = Replace(s, "\", "/")
    Do While Left(s, 2) = "~/"
        s = Mid(s, 3)
    Loop
    If Left(s, 1) = "/" Then s = Mid(s, 2)
    RutaRelativa = s
End Function

' =====================================================================
'  USUARIOS
' =====================================================================

Function ValidarUsuario(username, password)
    Dim sql
    sql = "SELECT u.ID_USER, u.USERNAME, u.PASSWORD, u.EMAIL, u.BIRTHDAY, u.USER_PHOTO, u.USER_TYPE, " & _
          "       c.VALUE AS USER_TYPE_NAME " & _
          "FROM TBL_USER u " & _
          "LEFT JOIN TBL_CATALOG c ON c.COD_CATALOG = CAST(u.USER_TYPE AS varchar(8)) AND c.COD_CATALOG_PARENT = '1' " & _
          "WHERE u.USERNAME = ? AND u.PASSWORD = ?"
    Set ValidarUsuario = EjecutarQuery(sql, Array(username, password), Array(200, 200))
End Function

' Registra un usuario nuevo (operacion sin valor de retorno)
Sub RegistrarUsuario(username, password, email, birthday, userPhoto, userType)
    Dim sql, arrP, arr
    sql = "INSERT INTO TBL_USER (USERNAME, PASSWORD, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE) " & _
          "VALUES (?, ?, ?, ?, ?, ?)"
    arrP = Array(username, password, email, birthday, userPhoto, userType)

    arr = Array(200, 200, 200, 7, 200, 3) ' adVarWChar x3, adDate, adVarWChar, adInteger
    EjecutarComando sql, arrP, arr
End Sub

Function ExisteUsuario(username)
    Dim sql, total
    sql = "SELECT COUNT(*) FROM TBL_USER WHERE USERNAME = ?"
    total = EjecutarEscalar(sql, Array(username), Array(200))
    ExisteUsuario = (ToInt(total) > 0)
End Function

Function ObtenerTodosUsuarios()
    Dim sql
    sql = "SELECT u.ID_USER, u.USERNAME, u.PASSWORD, u.EMAIL, u.BIRTHDAY, u.USER_PHOTO, u.USER_TYPE, " & _
          "       c.VALUE AS USER_TYPE_NAME " & _
          "FROM TBL_USER u " & _
          "LEFT JOIN TBL_CATALOG c ON c.COD_CATALOG = CAST(u.USER_TYPE AS varchar(8)) AND c.COD_CATALOG_PARENT = '1' " & _
          "ORDER BY u.ID_USER"
    Set ObtenerTodosUsuarios = EjecutarQuery(sql, Empty, Empty)
End Function

Function ObtenerUsuarioPorId(id)
    Dim sql
    sql = "SELECT u.ID_USER, u.USERNAME, u.PASSWORD, u.EMAIL, u.BIRTHDAY, u.USER_PHOTO, u.USER_TYPE, " & _
          "       c.VALUE AS USER_TYPE_NAME " & _
          "FROM TBL_USER u " & _
          "LEFT JOIN TBL_CATALOG c ON c.COD_CATALOG = CAST(u.USER_TYPE AS varchar(8)) AND c.COD_CATALOG_PARENT = '1' " & _
          "WHERE u.ID_USER = ?"
    Set ObtenerUsuarioPorId = EjecutarQuery(sql, Array(id), Array(3))
End Function

Sub CrearUsuario(username, password, email, birthday, userPhoto, userType)
    Dim sql
    sql = "INSERT INTO TBL_USER (USERNAME, PASSWORD, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE) " & _
          "VALUES (?, ?, ?, ?, ?, ?)"
    EjecutarComando sql, Array(username, password, email, birthday, userPhoto, userType), Array(200, 200, 200, 7, 200, 3)
End Sub

Sub ActualizarUsuario(id, username, password, email, birthday, userPhoto, userType)
    Dim sql, sqlBase, arrP, arrT

    If Trim(CStr(password)) = "" Then
        ' No se cambia la contraseña
        sql = "UPDATE TBL_USER SET USERNAME=?, EMAIL=?, BIRTHDAY=?, USER_PHOTO=?, USER_TYPE=? WHERE ID_USER=?"
        EjecutarComando sql, Array(username, email, birthday, userPhoto, userType, id), Array(200, 200, 7, 200, 3, 3)
    Else
        sql = "UPDATE TBL_USER SET USERNAME=?, PASSWORD=?, EMAIL=?, BIRTHDAY=?, USER_PHOTO=?, USER_TYPE=? WHERE ID_USER=?"
        EjecutarComando sql, Array(username, password, email, birthday, userPhoto, userType, id), Array(200, 200, 200, 7, 200, 3, 3)
    End If
End Sub

' Elimina un usuario y todos sus registros dependientes
Sub EliminarUsuario(id)
    ' Esquema real: TBL_PLAYLIST -> TBL_PLAYLIST_SONG
    EliminarPlaylistsPorUsuario id
    EjecutarComando "DELETE FROM TBL_USER WHERE ID_USER = ?", Array(id), Array(3)
End Sub

' =====================================================================
'  CANCIONES
' =====================================================================

Function ObtenerTodasCanciones()
    Dim sql
    sql = "SELECT ID_SONG, SONG_NAME, SONG_PATH, PLAYS FROM TBL_SONG ORDER BY ID_SONG"
    Set ObtenerTodasCanciones = EjecutarQuery(sql, Empty, Empty)
End Function

Function ObtenerCancionPorId(id)
    Dim sql
    sql = "SELECT ID_SONG, SONG_NAME, SONG_PATH, PLAYS FROM TBL_SONG WHERE ID_SONG = ?"
    Set ObtenerCancionPorId = EjecutarQuery(sql, Array(id), Array(3))
End Function

Sub CrearCancion(songName, songPath)
    Dim sql
    sql = "INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS) VALUES (?, ?, 0)"
    EjecutarComando sql, Array(songName, songPath), Array(200, 200)
End Sub

Sub ActualizarCancion(id, songName, songPath)
    Dim sql
    sql = "UPDATE TBL_SONG SET SONG_NAME=?, SONG_PATH=? WHERE ID_SONG=?"
    EjecutarComando sql, Array(songName, songPath, id), Array(200, 200, 3)
End Sub

Sub EliminarCancion(id)
    EjecutarComando "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_SONG = ?", Array(id), Array(3)
    EjecutarComando "DELETE FROM TBL_TRACKLIST WHERE ID_SONG = ?", Array(id), Array(3)
    EjecutarComando "DELETE FROM TBL_PLAYER WHERE ID_SONG = ?", Array(id), Array(3)
    EjecutarComando "DELETE FROM TBL_SONG WHERE ID_SONG = ?", Array(id), Array(3)
End Sub

Sub IncrementarReproducciones(songId)
    Dim sql
    sql = "UPDATE TBL_SONG SET PLAYS = PLAYS + 1 WHERE ID_SONG = ?"
    EjecutarComando sql, Array(songId), Array(3)
End Sub

' =====================================================================
'  ALBUMES
' =====================================================================

Function ObtenerTodosAlbumes()
    Dim sql
    sql = "SELECT a.ID_ALBUM, a.TITLE_ALBUM AS ALBUM_NAME, CASE WHEN a.RELEASE_YEAR IS NULL THEN NULL ELSE DATEFROMPARTS(a.RELEASE_YEAR, 1, 1) END AS ALBUM_YEAR, a.ALBUM_IMAGE_PATH AS ALBUM_IMAGE, (SELECT TOP 1 p.ID_ARTIST FROM TBL_TRACKLIST t INNER JOIN TBL_PLAYER p ON p.ID_SONG = t.ID_SONG WHERE t.ID_ALBUM = a.ID_ALBUM ORDER BY p.ID_ARTIST) AS ID_ARTIST FROM TBL_ALBUM a ORDER BY a.ID_ALBUM"
    Set ObtenerTodosAlbumes = EjecutarQuery(sql, Empty, Empty)
End Function

Function ObtenerAlbumPorId(id)
    Dim sql
    sql = "SELECT x.*, LTRIM(RTRIM(ar.ARTIST_NAME + ' ' + ISNULL(ar.ARTIST_LASTNAME, ''))) AS ARTIST_NAME " & _
          "FROM (SELECT a.ID_ALBUM, a.TITLE_ALBUM AS ALBUM_NAME, CASE WHEN a.RELEASE_YEAR IS NULL THEN NULL ELSE DATEFROMPARTS(a.RELEASE_YEAR, 1, 1) END AS ALBUM_YEAR, a.ALBUM_IMAGE_PATH AS ALBUM_IMAGE, (SELECT TOP 1 p.ID_ARTIST FROM TBL_TRACKLIST t INNER JOIN TBL_PLAYER p ON p.ID_SONG = t.ID_SONG WHERE t.ID_ALBUM = a.ID_ALBUM ORDER BY p.ID_ARTIST) AS ID_ARTIST FROM TBL_ALBUM a WHERE a.ID_ALBUM = ?) x " & _
          "LEFT JOIN TBL_ARTIST ar ON ar.ID_ARTIST = x.ID_ARTIST"
    Set ObtenerAlbumPorId = EjecutarQuery(sql, Array(id), Array(3))
End Function

Function AnioAlbum(valor)
    ' La pagina envia una fecha (1/1/AAAA); la tabla guarda solo el anio (RELEASE_YEAR int)
    If IsNull(valor) Or IsEmpty(valor) Then
        AnioAlbum = Null
    ElseIf IsDate(valor) Then
        AnioAlbum = Year(valor)
    Else
        AnioAlbum = ToInt(valor)
    End If
End Function

Sub CrearAlbum(albumName, albumYear, albumImage, idArtist)
    ' TBL_ALBUM no tiene ID_ARTIST: el artista se relaciona por TBL_TRACKLIST + TBL_PLAYER
    Dim sql
    sql = "INSERT INTO TBL_ALBUM (TITLE_ALBUM, RELEASE_YEAR, ALBUM_IMAGE_PATH) VALUES (?, ?, ?)"
    EjecutarComando sql, Array(albumName, AnioAlbum(albumYear), albumImage), Array(200, 3, 200)
End Sub

Sub ActualizarAlbum(id, albumName, albumYear, albumImage, idArtist)
    Dim sql
    sql = "UPDATE TBL_ALBUM SET TITLE_ALBUM=?, RELEASE_YEAR=?, ALBUM_IMAGE_PATH=? WHERE ID_ALBUM=?"
    EjecutarComando sql, Array(albumName, AnioAlbum(albumYear), albumImage, id), Array(200, 3, 200, 3)
End Sub

Sub EliminarAlbum(id)
    EjecutarComando "DELETE FROM TBL_TRACKLIST WHERE ID_ALBUM = ?", Array(id), Array(3)
    EjecutarComando "DELETE FROM TBL_ALBUM WHERE ID_ALBUM = ?", Array(id), Array(3)
End Sub

Function ObtenerCancionesPorAlbum(albumId)
    Dim sql
    sql = "SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, s.PLAYS " & _
          "FROM TBL_SONG s " & _
          "INNER JOIN TBL_TRACKLIST t ON t.ID_SONG = s.ID_SONG " & _
          "WHERE t.ID_ALBUM = ? " & _
          "ORDER BY s.ID_SONG"
    Set ObtenerCancionesPorAlbum = EjecutarQuery(sql, Array(albumId), Array(3))
End Function

' =====================================================================
'  ARTISTAS
' =====================================================================

Function ObtenerTodosArtistas()
    Dim sql
    sql = "SELECT ar.ID_ARTIST, LTRIM(RTRIM(ar.ARTIST_NAME + ' ' + ISNULL(ar.ARTIST_LASTNAME, ''))) AS ARTIST_NAME, ar.ARTIST_LASTNAME, ar.ARTIST_IMAGE FROM TBL_ARTIST ar ORDER BY ar.ID_ARTIST"
    Set ObtenerTodosArtistas = EjecutarQuery(sql, Empty, Empty)
End Function

Function ObtenerArtistaPorId(id)
    Dim sql
    sql = "SELECT ID_ARTIST, ARTIST_NAME, ARTIST_LASTNAME, ARTIST_IMAGE FROM TBL_ARTIST WHERE ID_ARTIST = ?"
    Set ObtenerArtistaPorId = EjecutarQuery(sql, Array(id), Array(3))
End Function

Sub CrearArtista(artistName, artistImage)
    Dim sql
    sql = "INSERT INTO TBL_ARTIST (ARTIST_NAME, ARTIST_IMAGE) VALUES (?, ?)"
    EjecutarComando sql, Array(artistName, artistImage), Array(200, 200)
End Sub

Sub ActualizarArtista(id, artistName, artistImage)
    Dim sql
    sql = "UPDATE TBL_ARTIST SET ARTIST_NAME=?, ARTIST_IMAGE=? WHERE ID_ARTIST=?"
    EjecutarComando sql, Array(artistName, artistImage, id), Array(200, 200, 3)
End Sub

Sub EliminarArtista(id)
    EjecutarComando "DELETE FROM TBL_PLAYER WHERE ID_ARTIST = ?", Array(id), Array(3)
    EjecutarComando "DELETE FROM TBL_ARTIST WHERE ID_ARTIST = ?", Array(id), Array(3)
End Sub

' Canciones de un artista = canciones en los tracklist de sus albums
Function ObtenerCancionesPorArtista(artistId)
    ' Relacion cancion-artista: TBL_PLAYER (ID_SONG, ID_ARTIST)
    Dim sql
    sql = "SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, s.PLAYS " & _
          "FROM TBL_SONG s " & _
          "INNER JOIN TBL_PLAYER p ON p.ID_SONG = s.ID_SONG " & _
          "WHERE p.ID_ARTIST = ? " & _
          "ORDER BY s.ID_SONG"
    Set ObtenerCancionesPorArtista = EjecutarQuery(sql, Array(artistId), Array(3))
End Function

' =====================================================================
'  PLAYLISTS
' =====================================================================

Function ObtenerPlaylistsPorUsuario(userId)
    Dim sql
    sql = "SELECT p.ID_PLAYLIST, p.TITLE AS PLAYLIST_NAME, p.TYPE AS PLAYLIST_TYPE, p.PHOTO AS PLAYLIST_IMAGE, p.ID_USER, p.CREATION_DATE, c.VALUE AS PLAYLIST_TYPE_NAME " & _
          "FROM TBL_PLAYLIST p " & _
          "LEFT JOIN TBL_CATALOG c ON c.COD_CATALOG = CAST(p.TYPE AS varchar(8)) AND c.COD_CATALOG_PARENT = '2' " & _
          "WHERE p.ID_USER = ? ORDER BY p.ID_PLAYLIST"
    Set ObtenerPlaylistsPorUsuario = EjecutarQuery(sql, Array(userId), Array(3))
End Function

Function ObtenerTodasPlaylists()
    Dim sql
    sql = "SELECT p.ID_PLAYLIST, p.TITLE AS PLAYLIST_NAME, p.TYPE AS PLAYLIST_TYPE, p.PHOTO AS PLAYLIST_IMAGE, p.ID_USER, p.CREATION_DATE, c.VALUE AS PLAYLIST_TYPE_NAME, u.USERNAME " & _
          "FROM TBL_PLAYLIST p " & _
          "LEFT JOIN TBL_CATALOG c ON c.COD_CATALOG = CAST(p.TYPE AS varchar(8)) AND c.COD_CATALOG_PARENT = '2' " & _
          "LEFT JOIN TBL_USER u ON u.ID_USER = p.ID_USER " & _
          "ORDER BY p.ID_PLAYLIST"
    Set ObtenerTodasPlaylists = EjecutarQuery(sql, Empty, Empty)
End Function

Function ObtenerPlaylistPorId(id)
    Dim sql
    sql = "SELECT p.ID_PLAYLIST, p.TITLE AS PLAYLIST_NAME, p.TYPE AS PLAYLIST_TYPE, p.PHOTO AS PLAYLIST_IMAGE, p.ID_USER, p.CREATION_DATE, c.VALUE AS PLAYLIST_TYPE_NAME, u.USERNAME " & _
          "FROM TBL_PLAYLIST p " & _
          "LEFT JOIN TBL_CATALOG c ON c.COD_CATALOG = CAST(p.TYPE AS varchar(8)) AND c.COD_CATALOG_PARENT = '2' " & _
          "LEFT JOIN TBL_USER u ON u.ID_USER = p.ID_USER " & _
          "WHERE p.ID_PLAYLIST = ?"
    Set ObtenerPlaylistPorId = EjecutarQuery(sql, Array(id), Array(3))
End Function

Sub CrearPlaylist(playlistName, playlistType, playlistImage, idUser)
    Dim sql
    sql = "INSERT INTO TBL_PLAYLIST (ID_USER, TITLE, CREATION_DATE, TYPE, PHOTO) VALUES (?, ?, GETDATE(), ?, ?)"
    EjecutarComando sql, Array(idUser, playlistName, playlistType, playlistImage), Array(3, 200, 3, 200)
End Sub

Sub ActualizarPlaylist(id, playlistName, playlistType, playlistImage)
    Dim sql
    sql = "UPDATE TBL_PLAYLIST SET TITLE=?, TYPE=?, PHOTO=? WHERE ID_PLAYLIST=?"
    EjecutarComando sql, Array(playlistName, playlistType, playlistImage, id), Array(200, 3, 200, 3)
End Sub

Sub EliminarPlaylist(id)
    EjecutarComando "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ?", Array(id), Array(3)
    EjecutarComando "DELETE FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ?", Array(id), Array(3)
End Sub

Sub EliminarPlaylistsPorUsuario(userId)
    EjecutarComando "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST IN (SELECT ID_PLAYLIST FROM TBL_PLAYLIST WHERE ID_USER = ?)", Array(userId), Array(3)
    EjecutarComando "DELETE FROM TBL_PLAYLIST WHERE ID_USER = ?", Array(userId), Array(3)
End Sub

' Canciones dentro de una playlist (via TBL_PLAYLIST_SONG)
Function ObtenerCancionesDePlaylist(playlistId)
    Dim sql
    sql = "SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, s.PLAYS, " & _
          "       (SELECT TOP 1 LTRIM(RTRIM(ar.ARTIST_NAME + ' ' + ISNULL(ar.ARTIST_LASTNAME, ''))) FROM TBL_PLAYER pl INNER JOIN TBL_ARTIST ar ON ar.ID_ARTIST = pl.ID_ARTIST WHERE pl.ID_SONG = s.ID_SONG ORDER BY ar.ID_ARTIST) AS ARTIST_NAME " & _
          "FROM TBL_SONG s " & _
          "INNER JOIN TBL_PLAYLIST_SONG ps ON ps.ID_SONG = s.ID_SONG " & _
          "WHERE ps.ID_PLAYLIST = ? " & _
          "ORDER BY s.ID_SONG"
    Set ObtenerCancionesDePlaylist = EjecutarQuery(sql, Array(playlistId), Array(3))
End Function

Function ExisteCancionEnPlaylist(playlistId, songId)
    Dim sql, total
    sql = "SELECT COUNT(*) FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ? AND ID_SONG = ?"
    total = EjecutarEscalar(sql, Array(playlistId, songId), Array(3, 3))
    ExisteCancionEnPlaylist = (ToInt(total) > 0)
End Function

Sub AgregarCancionAPlaylist(playlistId, songId)
    Dim sql
    sql = "INSERT INTO TBL_PLAYLIST_SONG (ID_PLAYLIST, ID_SONG) VALUES (?, ?)"
    EjecutarComando sql, Array(playlistId, songId), Array(3, 3)
End Sub

Sub QuitarCancionDePlaylist(playlistId, songId)
    Dim sql
    sql = "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ? AND ID_SONG = ?"
    EjecutarComando sql, Array(playlistId, songId), Array(3, 3)
End Sub

' =====================================================================
'  CATALOGOS / AUXILIARES
' =====================================================================

Function ObtenerCatalogoPorPadre(parentCode)
    Dim sql
    sql = "SELECT COD_CATALOG, VALUE, COD_CATALOG_PARENT FROM TBL_CATALOG WHERE COD_CATALOG_PARENT = ? ORDER BY COD_CATALOG"
    Set ObtenerCatalogoPorPadre = EjecutarQuery(sql, Array(parentCode), Array(200))
End Function

Sub AgregarATracklist(idSong, idAlbum)
    Dim sql
    sql = "INSERT INTO TBL_TRACKLIST (ID_ALBUM, ID_SONG) VALUES (?, ?)"
    EjecutarComando sql, Array(idAlbum, idSong), Array(3, 3)
End Sub

Sub AgregarAPlayer(idSong, idArtist)
    Dim sql
    sql = "INSERT INTO TBL_PLAYER (ID_SONG, ID_ARTIST) VALUES (?, ?)"
    EjecutarComando sql, Array(idSong, idArtist), Array(3, 3)
End Sub
%>
