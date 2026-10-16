<aside class="sidebar" id="sidebar">
    <div class="sidebar-logo">
        <i class="logo-icon">&#9835;</i>
        <span>PoliMusic</span>
    </div>

    <nav class="sidebar-nav">
        <a href="default.asp" class="nav-item">
            <i>&#8962;</i>
            <span>Inicio</span>
        </a>
        <a href="songs.asp" class="nav-item">
            <i>&#9835;</i>
            <span>Canciones</span>
        </a>
        <a href="albums.asp" class="nav-item">
            <i>&#9788;</i>
            <span>Albumes</span>
        </a>
        <a href="artists.asp" class="nav-item">
            <i>&#9737;</i>
            <span>Artistas</span>
        </a>
        <a href="playlists.asp" class="nav-item">
            <i>&#9776;</i>
            <span>Mis Playlists</span>
        </a>
    </nav>

    <% If EsAdmin() Then %>
    <div class="admin-section">
        <div class="admin-title">Administracion</div>
        <a href="adminusers.asp" class="nav-item">
            <i>&#9878;</i>
            <span>Usuarios</span>
        </a>
    </div>
    <% End If %>
</aside>
