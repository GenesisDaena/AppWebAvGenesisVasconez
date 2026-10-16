            </div><!-- /content-wrapper -->
        </div><!-- /main-content -->
    </div><!-- /app-container -->

    <!-- Barra de reproduccion inferior -->
    <div class="player-bar" id="playerBar">
        <div class="player-info">
            <img src="UserImages/default.jpg" alt="Portada" id="playerCover" class="player-cover">
            <div class="player-text">
                <span class="player-song-name" id="playerSongName">Sin reproduccion</span>
                <span class="player-status" id="playerStatus">Selecciona una cancion</span>
            </div>
        </div>

        <div class="player-controls">
            <button type="button" class="btn-play" id="btnPlayPause" onclick="togglePlay()">&#9654;</button>
            <div class="player-progress">
                <span id="currentTime">0:00</span>
                <input type="range" id="seekBar" class="seek-bar" min="0" max="100" value="0">
                <span id="duration">0:00</span>
            </div>
        </div>

        <div class="player-volume">
            <span class="player-volume-icon">&#128266;</span>
        </div>

        <audio id="audioPlayer"></audio>
    </div>

    <script src="Scripts/Site.js"></script>
</body>
</html>
