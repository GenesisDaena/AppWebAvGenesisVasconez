<%@ Language="VBScript" CodePage=65001 %>
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001
Response.ContentType = "text/plain"
%>
<!--#include file="includes/conexion.asp" -->
<%
' =====================================================================
'  incrementplays.asp  -  Incrementa el contador PLAYS (de IncrementPlays.ashx)
'  Acepta el id de la cancion por POST (o por querystring como respaldo)
'  Devuelve "OK", "NO_ID" o "ERROR"
' =====================================================================
On Error Resume Next

Dim songId, metodo, valor
songId = 0

metodo = UCase("" & Request.ServerVariables("REQUEST_METHOD"))
If metodo = "POST" Then
    valor = Request.Form("id")
    If valor = "" Then valor = Request.Form("songId")
Else
    valor = Request.QueryString("id")
    If valor = "" Then valor = Request.QueryString("songId")
End If

songId = ToInt(valor)

If songId <= 0 Then
    Response.Write "NO_ID"
Else
    IncrementarReproducciones songId
    If Err.Number = 0 Then
        Response.Write "OK"
    Else
        Response.Write "ERROR"
    End If
End If
%>
