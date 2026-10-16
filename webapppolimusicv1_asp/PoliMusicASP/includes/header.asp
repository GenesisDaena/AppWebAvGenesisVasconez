<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PoliMusic</title>
    <link rel="stylesheet" href="Content/Site.css">
</head>
<body>
    <div class="app-container">
        <!--#include file="sidebar.asp" -->

        <div class="main-content">
            <div class="topbar">
                <div class="topbar-left">
                    <button class="menu-toggle" onclick="toggleSidebar()" type="button">&#9776;</button>
                </div>
                <div class="topbar-right">
                    <% If HaySesion() Then %>
                        <div class="user-info">
                            <img src="<%= HtmlEnc(FotoUsuarioActual()) %>" alt="Avatar" class="user-avatar" onerror="this.src='UserImages/default.jpg'">
                            <span class="user-name"><%= HtmlEnc(NombreUsuario()) %></span>
                        </div>
                        <a href="logout.asp" class="btn-logout" title="Cerrar sesion">&#10162;</a>
                    <% Else %>
                        <a href="login.asp" class="btn-login">Iniciar sesion</a>
                        <a href="register.asp" class="btn-register">Registrarse</a>
                    <% End If %>
                </div>
            </div>

            <div class="content-wrapper">
