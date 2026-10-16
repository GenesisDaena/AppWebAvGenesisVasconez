<%@ Language="VBScript" CodePage=65001 %>
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001
%>
<%
' =====================================================================
'  logout.asp  -  Cierre de sesion (migrado de Logout.aspx)
' =====================================================================
Session.Contents.RemoveAll()
Session.Abandon()
Response.Redirect "login.asp?msg=logout"
%>
