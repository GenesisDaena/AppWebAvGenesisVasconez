<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV2.Song" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>PoliMusic &middot; Your music</title>
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
    <form id="form1" runat="server">

    <div class="app">

        <!-- ================= SIDEBAR ================= -->
        <aside class="sidebar">
            <div class="brand">
                <span class="mark">
                    <svg viewBox="0 0 24 24"><path d="M12 3v10.55A4 4 0 1 0 14 17V7h4V3h-6z" /></svg>
                </span>
                <span>PoliMusic</span>
            </div>

            <nav class="nav">
                <a class="nav-item active" href="#">
                    <svg viewBox="0 0 24 24"><path d="M12 3 2 12h3v8h6v-5h2v5h6v-8h3z" /></svg>
                    Home
                </a>
                <a class="nav-item" href="#catalog">
                    <svg viewBox="0 0 24 24"><path d="M10 18a4 4 0 1 1-2-3.46V4l12-2v13a4 4 0 1 1-2-3.46V6.4L10 7.8z" /></svg>
                    Songs
                </a>
                <a class="nav-item" href="#playlists">
                    <svg viewBox="0 0 24 24"><path d="M4 4h16v3H4zm0 6h10v3H4zm0 6h10v3H4z" /></svg>
                    Your Library
                </a>
            </nav>

            <div class="sidebar-block" id="playlists">
                <div class="sidebar-title">Your playlists</div>
                <div class="playlist-list">
                    <asp:Repeater ID="rptPlaylists" runat="server">
                        <ItemTemplate>
                            <a class="pl-item" href="#">
                                <span class="pl-cover <%# CoverClass(Container.ItemIndex) %>"><%# CoverHtml(Eval("PHOTO"), Eval("TITLE")) %></span>
                                <span class="pl-meta">
                                    <span class="pl-name"><%# Text(Eval("TITLE")) %></span>
                                    <span class="pl-sub"><%# Eval("SONG_COUNT") %> songs &middot; <%# TypeName(Eval("TYPE")) %></span>
                                </span>
                            </a>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <div class="sidebar-foot">
                <a class="logout-link" href="Logout.aspx">
                    <svg viewBox="0 0 24 24"><path d="M10 3H5v18h5v-2H7V5h3zm5.6 3.6L14.2 8l3 3H9v2h8.2l-3 3 1.4 1.4L21 12z" /></svg>
                    Log out
                </a>
            </div>
        </aside>

        <!-- ================= MAIN ================= -->
        <main class="main">

            <div class="topbar">
                <div class="searchbox">
                    <svg viewBox="0 0 24 24"><path d="M15.5 14h-.8l-.3-.3a6.5 6.5 0 1 0-.7.7l.3.3v.8l5 5 1.5-1.5zm-6 0A4.5 4.5 0 1 1 14 9.5 4.5 4.5 0 0 1 9.5 14z" /></svg>
                    <input type="text" id="txtSearch" placeholder="Search songs in your library..." autocomplete="off" />
                </div>

                <div class="user-chip">
                    <asp:Literal ID="litAvatar" runat="server" />
                    <span>
                        <span class="name"><asp:Label ID="lblUserName" runat="server" /></span><br />
                        <span class="role"><asp:Label ID="lblUserRole" runat="server" /></span>
                    </span>
                </div>
            </div>

            <section class="hero">
                <div>
                    <div class="eyebrow">Welcome back</div>
                    <h1>Good evening, <em><asp:Label ID="lblHeroName" runat="server" /></em></h1>
                    <p>This is your personal library. Pick a track, press play and keep the counter of reproductions growing.</p>

                    <div class="hero-stats">
                        <div class="stat"><b><asp:Label ID="lblSongCount" runat="server" /></b><span>Songs</span></div>
                        <div class="stat"><b><asp:Label ID="lblTotalPlays" runat="server" /></b><span>Plays</span></div>
                        <div class="stat"><b><asp:Label ID="lblPlaylistCount" runat="server" /></b><span>Playlists</span></div>
                    </div>
                </div>

                <div class="hero-actions">
                    <button type="button" class="btn-play-all" id="btnPlayAll">
                        <svg viewBox="0 0 24 24"><path d="M8 5v14l11-7z" /></svg>
                        Play all
                    </button>
                </div>
            </section>

            <section class="section" id="catalog">
                <div class="section-head">
                    <h2>Recently added</h2>
                    <span class="count"><asp:Label ID="lblCardsCount" runat="server" /> tracks</span>
                </div>

                <div class="cards">
                    <asp:Repeater ID="rptCards" runat="server">
                        <ItemTemplate>
                            <button type="button" class="card" data-track-id='<%# Eval("ID_SONG") %>'>
                                <span class="cover-lg <%# CoverClass(Container.ItemIndex) %>">
                                    <%# Initial(Eval("SONG_NAME")) %>
                                    <span class="card-play">
                                        <svg viewBox="0 0 24 24"><path d="M8 5v14l11-7z" /></svg>
                                    </span>
                                </span>
                                <span class="card-title"><%# Text(Eval("SONG_NAME")) %></span>
                                <span class="card-sub"><%# PlaysValue(Eval("PLAYS")) %> plays</span>
                            </button>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </section>

            <section class="section">
                <div class="section-head">
                    <h2>All songs</h2>
                    <span class="count">Table &middot; TBL_SONG</span>
                </div>

                <div class="table-wrap">
                    <table class="tracks">
                        <thead>
                            <tr>
                                <th class="col-idx">#</th>
                                <th>Title</th>
                                <th class="col-plays">Plays</th>
                                <th class="col-actions">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptSongs" runat="server">
                                <ItemTemplate>
                                    <tr class="track"
                                        data-id='<%# Eval("ID_SONG") %>'
                                        data-title="<%# Attr(Eval("SONG_NAME")) %>"
                                        data-src="<%# Attr(SongUrl(Eval("SONG_PATH"))) %>"
                                        data-cover="<%# CoverClass(Container.ItemIndex) %>"
                                        data-plays="<%# PlaysValue(Eval("PLAYS")) %>">
                                        <td class="col-idx">
                                            <span class="idx-num"><%# Container.ItemIndex + 1 %></span>
                                            <span class="eq-mini"><i></i><i></i><i></i></span>
                                        </td>
                                        <td>
                                            <div class="track-main">
                                                <span class="cover <%# CoverClass(Container.ItemIndex) %>"><%# Initial(Eval("SONG_NAME")) %></span>
                                                <span class="track-meta">
                                                    <span class="track-name"><%# Text(Eval("SONG_NAME")) %></span>
                                                    <span class="track-sub">PoliMusic Records</span>
                                                </span>
                                            </div>
                                        </td>
                                        <td class="col-plays">
                                            <span class="plays-count"><%# PlaysValue(Eval("PLAYS")) %></span>
                                            <span class="plays-label">plays</span>
                                        </td>
                                        <td class="col-actions">
                                            <button type="button" class="icon-btn play-btn" title="Play">
                                                <svg class="ic-play" viewBox="0 0 24 24"><path d="M8 5v14l11-7z" /></svg>
                                                <svg class="ic-pause" viewBox="0 0 24 24"><path d="M6 5h4v14H6zm8 0h4v14h-4z" /></svg>
                                            </button>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>

                    <asp:PlaceHolder ID="phEmpty" runat="server" Visible="false">
                        <div class="empty">
                            <h3>There are no songs yet</h3>
                            <p>Add records to TBL_SONG and they will appear right here.</p>
                        </div>
                    </asp:PlaceHolder>
                </div>

                <asp:Label ID="lblMessage" runat="server" CssClass="msg" />
            </section>
        </main>
    </div>

    <!-- ================= PLAYER ================= -->
    <div class="player">
        <div class="player-track">
            <span class="cover c1" id="playerCover"><span id="playerCoverLetter">&ndash;</span></span>
            <div class="player-meta">
                <div class="player-title" id="playerTitle">Nothing playing</div>
                <div class="player-sub" id="playerSub">Select a song to start</div>
            </div>
        </div>

        <div class="player-center">
            <div class="player-controls">
                <button type="button" class="icon-btn" id="btnPrev" title="Previous">
                    <svg viewBox="0 0 24 24"><path d="M7 6h2v12H7zm3 6 9 6V6z" /></svg>
                </button>
                <button type="button" class="play-toggle" id="btnPlay" title="Play">
                    <svg class="ic-play" viewBox="0 0 24 24"><path d="M8 5v14l11-7z" /></svg>
                    <svg class="ic-pause" viewBox="0 0 24 24"><path d="M6 5h4v14H6zm8 0h4v14h-4z" /></svg>
                </button>
                <button type="button" class="icon-btn" id="btnNext" title="Next">
                    <svg viewBox="0 0 24 24"><path d="M15 6h2v12h-2zM5 18l9-6-9-6z" /></svg>
                </button>
            </div>
            <div class="player-progress">
                <span id="timeCurrent">0:00</span>
                <input type="range" class="slider" id="seek" min="0" max="100" step="0.5" value="0" />
                <span id="timeTotal">0:00</span>
            </div>
        </div>

        <div class="player-right">
            <svg viewBox="0 0 24 24"><path d="M3 10v4h4l5 4V6L7 10zm13.5 2a4.5 4.5 0 0 0-2.5-4v8a4.5 4.5 0 0 0 2.5-4z" /></svg>
            <input type="range" class="slider" id="volume" min="0" max="1" step="0.01" value="0.8" />
        </div>
    </div>

    <div class="toast" id="toast"></div>

    <audio id="audioPlayer" preload="none"></audio>

    <script type="text/javascript">
        (function () {
            var audio = document.getElementById('audioPlayer');
            var rows = Array.prototype.slice.call(document.querySelectorAll('tr.track'));
            var tracks = rows.map(function (row) {
                return {
                    id: row.getAttribute('data-id'),
                    title: row.getAttribute('data-title'),
                    src: row.getAttribute('data-src'),
                    cover: row.getAttribute('data-cover'),
                    plays: parseInt(row.getAttribute('data-plays'), 10) || 0,
                    row: row
                };
            });

            var current = -1;
            var btnPlay = document.getElementById('btnPlay');
            var btnPrev = document.getElementById('btnPrev');
            var btnNext = document.getElementById('btnNext');
            var btnPlayAll = document.getElementById('btnPlayAll');
            var seek = document.getElementById('seek');
            var volume = document.getElementById('volume');
            var timeCurrent = document.getElementById('timeCurrent');
            var timeTotal = document.getElementById('timeTotal');
            var playerTitle = document.getElementById('playerTitle');
            var playerSub = document.getElementById('playerSub');
            var playerCover = document.getElementById('playerCover');
            var playerCoverLetter = document.getElementById('playerCoverLetter');
            var toast = document.getElementById('toast');
            var toastTimer = null;

            function showToast(text) {
                toast.textContent = text;
                toast.className = 'toast show';
                if (toastTimer) { clearTimeout(toastTimer); }
                toastTimer = setTimeout(function () { toast.className = 'toast'; }, 2600);
            }

            function formatTime(seconds) {
                if (!isFinite(seconds) || seconds < 0) { return '0:00'; }
                var m = Math.floor(seconds / 60);
                var s = Math.floor(seconds % 60);
                return m + ':' + (s < 10 ? '0' + s : s);
            }

            function markRow(index, playing) {
                tracks.forEach(function (t, i) {
                    t.row.className = (i === index && playing) ? 'track is-playing' : 'track';
                    var btn = t.row.querySelector('.play-btn');
                    if (btn) { btn.className = (i === index && playing) ? 'icon-btn play-btn is-pause' : 'icon-btn play-btn'; }
                });
            }

            function updatePlayerInfo(track) {
                playerTitle.textContent = track.title;
                playerSub.textContent = 'PoliMusic Records';
                playerCover.className = 'cover ' + track.cover;
                playerCoverLetter.textContent = track.title.charAt(0).toUpperCase();
            }

            function registerPlay(track) {
                var request = new XMLHttpRequest();
                request.open('GET', 'SongPlays.ashx?id=' + encodeURIComponent(track.id), true);
                request.onreadystatechange = function () {
                    if (request.readyState !== 4 || request.status !== 200) { return; }
                    var plays = parseInt(request.responseText, 10);
                    if (isNaN(plays)) { return; }
                    track.plays = plays;
                    track.row.setAttribute('data-plays', plays);
                    var counter = track.row.querySelector('.plays-count');
                    if (counter) { counter.textContent = plays; }
                    var card = document.querySelector('.card[data-track-id="' + track.id + '"] .card-sub');
                    if (card) { card.textContent = plays + ' plays'; }
                };
                request.send();
            }

            function play(index) {
                if (index < 0 || index >= tracks.length) { return; }
                var track = tracks[index];
                if (!track.src) {
                    showToast('This track does not have an audio file.');
                    return;
                }
                current = index;
                audio.src = track.src;
                updatePlayerInfo(track);
                markRow(index, true);

                var promise = audio.play();
                if (promise && typeof promise.catch === 'function') {
                    promise.catch(function () {
                        markRow(index, false);
                        showToast('The audio file of "' + track.title + '" is not available on the server.');
                    });
                }
                registerPlay(track);
            }

            function toggle() {
                if (current < 0) {
                    if (tracks.length > 0) { play(0); }
                    return;
                }
                if (audio.paused) {
                    audio.play();
                    markRow(current, true);
                } else {
                    audio.pause();
                    markRow(current, false);
                }
            }

            function next() {
                if (tracks.length === 0) { return; }
                play((current + 1) % tracks.length);
            }

            function previous() {
                if (tracks.length === 0) { return; }
                play((current - 1 + tracks.length) % tracks.length);
            }

            btnPlay.addEventListener('click', toggle);
            btnNext.addEventListener('click', next);
            btnPrev.addEventListener('click', previous);

            if (btnPlayAll) {
                btnPlayAll.addEventListener('click', function () {
                    if (tracks.length === 0) { showToast('There are no songs to play.'); return; }
                    play(0);
                });
            }

            rows.forEach(function (row, index) {
                row.addEventListener('dblclick', function () { play(index); });
                var btn = row.querySelector('.play-btn');
                if (btn) {
                    btn.addEventListener('click', function () {
                        if (current === index && !audio.paused) {
                            audio.pause();
                            markRow(index, false);
                        } else {
                            play(index);
                        }
                    });
                }
            });

            Array.prototype.slice.call(document.querySelectorAll('.card')).forEach(function (card) {
                card.addEventListener('click', function () {
                    var id = card.getAttribute('data-track-id');
                    for (var i = 0; i < tracks.length; i++) {
                        if (tracks[i].id === id) { play(i); return; }
                    }
                });
            });

            audio.addEventListener('timeupdate', function () {
                if (!audio.duration) { return; }
                seek.value = (audio.currentTime / audio.duration) * 100;
                timeCurrent.textContent = formatTime(audio.currentTime);
            });

            audio.addEventListener('loadedmetadata', function () {
                timeTotal.textContent = formatTime(audio.duration);
            });

            audio.addEventListener('ended', next);

            audio.addEventListener('play', function () {
                btnPlay.className = 'play-toggle is-pause';
                if (current >= 0) { markRow(current, true); }
            });

            audio.addEventListener('pause', function () {
                btnPlay.className = 'play-toggle';
                if (current >= 0) { markRow(current, false); }
            });

            seek.addEventListener('input', function () {
                if (!audio.duration) { return; }
                audio.currentTime = (seek.value / 100) * audio.duration;
            });

            volume.addEventListener('input', function () {
                audio.volume = parseFloat(volume.value);
            });

            audio.volume = parseFloat(volume.value);

            var search = document.getElementById('txtSearch');
            if (search) {
                search.addEventListener('input', function () {
                    var term = search.value.toLowerCase();
                    rows.forEach(function (row, index) {
                        var title = (row.getAttribute('data-title') || '').toLowerCase();
                        row.style.display = title.indexOf(term) === -1 ? 'none' : '';
                    });
                });
            }
        })();
    </script>

    </form>
</body>
</html>
