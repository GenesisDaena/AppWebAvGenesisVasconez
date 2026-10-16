// =====================================================================
//  PoliMusic - JavaScript del cliente
//  Version ASP Clasico (migrado desde la version de ASP.NET Web Forms)
//
//  Cambios respecto a la version original:
//   - playSong() ahora recibe tambien el id de la cancion (songId), que
//     las paginas .asp pasan desde el servidor. Ya no se intenta deducir
//     el id desde la URL como en ASP.NET.
//   - incrementPlayCount() deja de llamar a 'IncrementPlays.ashx' y
//     realiza un POST a 'incrementplays.asp'.
//   - La deteccion del item de menu activo trabaja con nombres .asp.
//  El resto del comportamiento (reproductor, seek bar, formatTime,
//  confirmDelete, toggleSidebar) se conserva tal cual.
// =====================================================================

// Toggle sidebar on mobile
function toggleSidebar() {
    var sidebar = document.getElementById('sidebar');
    if (sidebar) {
        sidebar.classList.toggle('open');
    }
}

// Audio player functionality
var audioPlayer = document.getElementById('audioPlayer');
var playerBar = document.getElementById('playerBar');
var playerSongName = document.getElementById('playerSongName');
var playerStatus = document.getElementById('playerStatus');
var playBtn = document.getElementById('btnPlayPause');
var seekBar = document.getElementById('seekBar');
var currentTimeEl = document.getElementById('currentTime');
var durationEl = document.getElementById('duration');

// Reproduce una cancion.
//   songPath : ruta relativa al mp3  (ej. "SongFiles/bensound-adventure.mp3")
//   songName : titulo a mostrar en la barra del reproductor
//   songId   : id de la cancion en la base (para sumar la reproduccion)
function playSong(songPath, songName, songId) {
    if (!audioPlayer) return;

    // Normaliza la ruta por si viene con el prefijo ~/ de ASP.NET
    var cleanPath = String(songPath || '').replace('~/', '');
    cleanPath = cleanPath.replace(/^\/+/, '');

    audioPlayer.src = cleanPath;
    audioPlayer.play();

    if (playerBar) {
        playerBar.style.display = 'flex';
    }
    if (playerSongName) {
        playerSongName.textContent = songName || 'Reproduciendo...';
    }
    if (playerStatus) {
        playerStatus.textContent = 'Reproduciendo ahora';
    }
    if (playBtn) {
        playBtn.innerHTML = '&#10074;&#10074;';
    }

    // Suma la reproduccion en el servidor (POST a incrementplays.asp)
    if (songId) {
        incrementPlayCount(songId);
    }
}

function togglePlay() {
    if (!audioPlayer) return;
    if (audioPlayer.paused) {
        audioPlayer.play();
        if (playBtn) {
            playBtn.innerHTML = '&#10074;&#10074;';
        }
    } else {
        audioPlayer.pause();
        if (playBtn) {
            playBtn.innerHTML = '&#9654;';
        }
    }
}

// Incrementa el contador de reproducciones mediante POST a incrementplays.asp
function incrementPlayCount(songId) {
    try {
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'incrementplays.asp', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.send('id=' + encodeURIComponent(songId));
    } catch (e) {
        // Respaldo silencioso si el navegador no soporta XHR
        var img = new Image();
        img.src = 'incrementplays.asp?id=' + encodeURIComponent(songId);
    }
}

// Update seek bar
if (audioPlayer) {
    audioPlayer.addEventListener('loadedmetadata', function () {
        if (durationEl) {
            durationEl.textContent = formatTime(audioPlayer.duration);
        }
        if (seekBar) {
            seekBar.max = Math.floor(audioPlayer.duration);
        }
    });

    audioPlayer.addEventListener('timeupdate', function () {
        if (seekBar) {
            seekBar.value = Math.floor(audioPlayer.currentTime);
        }
        if (currentTimeEl) {
            currentTimeEl.textContent = formatTime(audioPlayer.currentTime);
        }
    });

    audioPlayer.addEventListener('ended', function () {
        if (playBtn) {
            playBtn.innerHTML = '&#9654;';
        }
        if (playerStatus) {
            playerStatus.textContent = 'Reproduccion finalizada';
        }
    });
}

if (seekBar) {
    seekBar.addEventListener('input', function () {
        if (audioPlayer) {
            audioPlayer.currentTime = seekBar.value;
        }
    });
}

function formatTime(seconds) {
    if (!seconds || isNaN(seconds)) return '0:00';
    var mins = Math.floor(seconds / 60);
    var secs = Math.floor(seconds % 60);
    return mins + ':' + (secs < 10 ? '0' : '') + secs;
}

// Confirm delete
function confirmDelete(message) {
    return confirm(message || '\u00BFEst\u00E1 seguro de que desea eliminar este elemento?');
}

// Marca el item de menu activo segun la pagina .asp actual
(function () {
    var currentPage = window.location.pathname.split('/').pop().toLowerCase();
    if (!currentPage) {
        currentPage = 'default.asp';
    }
    var navItems = document.querySelectorAll('.nav-item');
    navItems.forEach(function (item) {
        var href = (item.getAttribute('href') || '').split('/').pop().toLowerCase();
        if (href === currentPage) {
            item.classList.add('active');
        }
    });
})();
