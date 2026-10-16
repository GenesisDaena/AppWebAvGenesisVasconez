<%
' =====================================================================
'  seguridad.asp  -  Validacion de sesion y roles
'  Migrado de la logica de Session[] de ASP.NET Web Forms
'     Session("UserId")   -> Session("idUsuario")
'     Session("Username") -> Session("usuario")
'     Session("UserType") -> Session("rol")   (0 = USER, 1 = ADMIN)
'  Incluir este archivo DESPUES de conexion.asp en toda pagina protegida.
' =====================================================================

Function HaySesion()
    HaySesion = (Trim("" & Session("usuario")) <> "" And ToInt(Session("idUsuario")) > 0)
End Function

Function EsAdmin()
    EsAdmin = (ToInt(Session("rol")) = 1)
End Function

Function NombreUsuario()
    NombreUsuario = "" & Session("usuario")
End Function

Function IdUsuarioActual()
    IdUsuarioActual = ToInt(Session("idUsuario"))
End Function

Function FotoUsuarioActual()
    Dim f
    f = RutaRelativa("" & Session("userPhoto"), "UserImages/default.jpg")
    FotoUsuarioActual = f
End Function

' Exige sesion activa; si no existe redirige al login
Sub ExigirSesion()
    If Not HaySesion() Then
        Response.Redirect "login.asp?msg=auth"
    End If
End Sub

' Exige rol administrador (ademas de sesion valida)
Sub ExigirAdmin()
    If Not HaySesion() Then
        Response.Redirect "login.asp?msg=auth"
    End If
    If Not EsAdmin() Then
        Response.Redirect "default.asp?msg=denied"
    End If
End Sub

' Verifica que el usuario actual sea propietario de la playlist (o admin)
Function PuedeEditarPlaylist(ownerId)
    If Not HaySesion() Then
        PuedeEditarPlaylist = False
    ElseIf EsAdmin() Then
        PuedeEditarPlaylist = True
    Else
        PuedeEditarPlaylist = (ToInt(ownerId) = IdUsuarioActual())
    End If
End Function

' Muestra un mensaje de alerta segun el parametro msg de la URL
Function MensajeAlerta()
    Dim m
    m = LCase(Trim("" & Request.QueryString("msg")))
    Select Case m
        Case "created"  : MensajeAlerta = "<div class=""alert alert-success"">Registro creado correctamente.</div>"
        Case "updated"  : MensajeAlerta = "<div class=""alert alert-success"">Registro actualizado correctamente.</div>"
        Case "deleted"  : MensajeAlerta = "<div class=""alert alert-success"">Registro eliminado correctamente.</div>"
        Case "added"    : MensajeAlerta = "<div class=""alert alert-success"">Cancion agregada a la playlist.</div>"
        Case "removed"  : MensajeAlerta = "<div class=""alert alert-success"">Cancion quitada de la playlist.</div>"
        Case "denied"   : MensajeAlerta = "<div class=""alert alert-error"">No tiene permisos para realizar esta accion.</div>"
        Case "auth"     : MensajeAlerta = "<div class=""alert alert-error"">Debe iniciar sesion para continuar.</div>"
        Case "noperm"   : MensajeAlerta = "<div class=""alert alert-error"">Solo el administrador puede gestionar este recurso.</div>"
        Case "error"    : MensajeAlerta = "<div class=""alert alert-error"">Ocurrio un error al procesar la solicitud.</div>"
        Case Else       : MensajeAlerta = ""
    End Select
End Function
%>
