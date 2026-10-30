<%@ Page Title="Songs" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV3.Song" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <style type="text/css">
        :root {
            --pm-deep: #0A5C74;
            --pm-mid: #2FA8C9;
            --pm-light: #E4F6FB;
            --pm-ink: #0B2733;
            --pm-muted: #5A7A88;
            --pm-line: #D3E9F1;
        }

        /* La pagina funciona como una app: se ocultan el separador y el pie del master */
        .body-content > hr,
        .body-content > footer {
            display: none;
        }

        .pm-wrap {
            padding-bottom: 96px;
        }

        /* ---------------- HERO ---------------- */
        .pm-hero {
            position: relative;
            overflow: hidden;
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            gap: 24px;
            padding: 28px 30px;
            border: 1px solid var(--pm-line);
            border-radius: 18px;
            background: linear-gradient(120deg, var(--pm-light) 0%, #ffffff 55%, #f2fbfe 100%);
        }

        .pm-hero:after {
            content: "";
            position: absolute;
            right: -90px;
            top: -90px;
            width: 280px;
            height: 280px;
            border-radius: 50%;
            background: radial-gradient(circle at 30% 30%, rgba(47,168,201,.38), rgba(10,92,116,0) 70%);
        }

        .pm-eyebrow {
            display: inline-block;
            margin-bottom: 10px;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: .18em;
            text-transform: uppercase;
            color: var(--pm-deep);
        }

        .pm-hero h1 {
            margin: 0 0 8px;
            font-size: 34px;
            font-weight: 800;
            letter-spacing: -.5px;
            color: var(--pm-ink);
        }

        .pm-hero p {
            margin: 0;
            max-width: 52ch;
            font-size: 14px;
            color: var(--pm-muted);
        }

        .pm-stats {
            display: flex;
            gap: 10px;
            margin-top: 18px;
        }

        .pm-stat {
            min-width: 92px;
            padding: 8px 14px;
            border: 1px solid var(--pm-line);
            border-radius: 12px;
            background: #fff;
        }

        .pm-stat b {
            display: block;
            font-size: 20px;
            color: var(--pm-deep);
        }

        .pm-stat span {
            font-size: 11px;
            letter-spacing: .1em;
            text-transform: uppercase;
            color: var(--pm-muted);
        }

        .pm-hero-side {
            position: relative;
            z-index: 1;
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            justify-content: space-between;
            gap: 14px;
        }

        .pm-user {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 6px 14px 6px 6px;
            border: 1px solid var(--pm-line);
            border-radius: 999px;
            background: #fff;
        }

        .pm-avatar {
            display: grid;
            place-items: center;
            width: 34px;
            height: 34px;
            overflow: hidden;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--pm-deep), var(--pm-mid));
            color: #fff;
            font-weight: 700;
        }

        .pm-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .pm-user strong {
            display: block;
            font-size: 13px;
            line-height: 1.2;
            color: var(--pm-ink);
        }

        .pm-role {
            display: block;
            font-size: 11px;
            color: var(--pm-muted);
        }

        .pm-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            border: 0;
            border-radius: 999px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
        }

        .pm-btn svg {
            width: 16px;
            height: 16px;
            fill: currentColor;
        }

        .pm-btn-solid {
            background: var(--pm-deep);
            color: #fff;
            box-shadow: 0 8px 18px rgba(10,92,116,.25);
        }

        .pm-btn-solid:hover {
            background: #084a5e;
        }

        /* ---------------- LAYOUT ---------------- */
        .pm-body {
            display: grid;
            grid-template-columns: 1.65fr 1fr;
            gap: 18px;
            margin-top: 18px;
        }

        @media (max-width: 900px) {
            .pm-body {
                grid-template-columns: 1fr;
            }
        }

        .pm-card {
            padding: 18px;
            border: 1px solid var(--pm-line);
            border-radius: 18px;
            background: #fff;
        }

        .pm-card h2 {
            margin: 0;
            font-size: 13px;
            font-weight: 800;
            letter-spacing: .12em;
            text-transform: uppercase;
            color: var(--pm-deep);
        }

        .pm-card-head {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 12px;
        }

        .pm-search input {
            width: 200px;
            padding: 8px 14px;
            border: 1px solid var(--pm-line);
            border-radius: 999px;
            background: #f7fdff;
            font-size: 13px;
            color: var(--pm-ink);
            outline: none;
        }

        .pm-search input:focus {
            border-color: var(--pm-mid);
            box-shadow: 0 0 0 3px rgba(47,168,201,.15);
        }

        /* ---------------- SONG ROWS ---------------- */
        .pm-rows {
            display: flex;
            flex-direction: column;
        }

        .pm-row {
            display: grid;
            grid-template-columns: 24px 36px 44px 1fr auto;
            align-items: center;
            gap: 12px;
            padding: 8px;
            border-radius: 12px;
        }

        .pm-row:hover {
            background: #f2fbfe;
        }

        .pm-index {
            font-size: 12px;
            text-align: center;
            color: var(--pm-muted);
        }

        .pm-play {
            display: grid;
            place-items: center;
            width: 36px;
            height: 36px;
            border: 1px solid var(--pm-line);
            border-radius: 50%;
            background: #fff;
            color: var(--pm-deep);
            cursor: pointer;
            transition: all .15s ease;
        }

        .pm-play svg {
            width: 14px;
            height: 14px;
            fill: currentColor;
        }

        .pm-play:hover {
            border-color: var(--pm-deep);
            background: var(--pm-deep);
            color: #fff;
        }

        .pm-cover {
            display: grid;
            place-items: center;
            width: 44px;
            height: 44px;
            border-radius: 10px;
            color: #fff;
            font-size: 16px;
            font-weight: 800;
        }

        .pm-c1 { background: linear-gradient(135deg, #0A5C74, #2FA8C9); }
        .pm-c2 { background: linear-gradient(135deg, #2FA8C9, #8FD8EA); }
        .pm-c3 { background: linear-gradient(135deg, #0A5C74, #8FD8EA); }
        .pm-c4 { background: linear-gradient(135deg, #126E8A, #4FC0DC); }
        .pm-c5 { background: linear-gradient(135deg, #0B4F63, #2FA8C9); }

        .pm-info {
            min-width: 0;
        }

        .pm-name {
            display: block;
            font-size: 14px;
            font-weight: 600;
            color: var(--pm-ink);
        }

        .pm-sub {
            display: block;
            overflow: hidden;
            max-width: 300px;
            font-size: 11px;
            color: var(--pm-muted);
            white-space: nowrap;
            text-overflow: ellipsis;
        }

        .pm-plays {
            padding: 4px 10px;
            border-radius: 999px;
            background: var(--pm-light);
            font-size: 11px;
            color: var(--pm-deep);
            white-space: nowrap;
        }

        /* ---------------- SIDE PANEL ---------------- */
        .pm-now {
            padding: 14px 0 4px;
            text-align: center;
        }

        .pm-now-cover {
            display: grid;
            place-items: center;
            width: 152px;
            height: 152px;
            margin: 0 auto 14px;
            border-radius: 16px;
            background: linear-gradient(135deg, #0A5C74, #2FA8C9);
            box-shadow: 0 14px 30px rgba(10,92,116,.25);
            color: #fff;
            font-size: 52px;
            font-weight: 800;
        }

        .pm-now-title {
            font-size: 17px;
            font-weight: 800;
            color: var(--pm-ink);
        }

        .pm-now-sub {
            margin-top: 4px;
            font-size: 12px;
            color: var(--pm-muted);
        }

        .pm-top {
            margin: 16px 0 0;
            padding: 14px 0 0;
            border-top: 1px dashed var(--pm-line);
            list-style: none;
        }

        .pm-top li {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 6px 0;
            font-size: 13px;
            color: var(--pm-ink);
        }

        .pm-top .pm-mini {
            display: grid;
            place-items: center;
            width: 28px;
            height: 28px;
            border-radius: 8px;
            background: var(--pm-light);
            color: var(--pm-deep);
            font-size: 11px;
            font-weight: 800;
        }

        .pm-top .pm-top-plays {
            margin-left: auto;
            font-size: 11px;
            color: var(--pm-muted);
        }

        .pm-empty {
            padding: 28px 12px;
            text-align: center;
            font-size: 13px;
            color: var(--pm-muted);
        }

        .pm-message {
            display: block;
            margin-top: 10px;
            font-size: 12px;
            color: #B04A4A;
        }

        /* ---------------- BOTTOM PLAYER ---------------- */
        .pm-bar {
            position: fixed;
            right: 0;
            bottom: 0;
            left: 0;
            z-index: 50;
            display: grid;
            grid-template-columns: 1fr 1.5fr 1fr;
            align-items: center;
            gap: 16px;
            padding: 10px 22px;
            border-top: 1px solid var(--pm-line);
            background: rgba(255,255,255,.96);
            box-shadow: 0 -6px 24px rgba(11,39,51,.07);
        }

        @media (max-width: 700px) {
            .pm-bar {
                grid-template-columns: 1fr auto;
            }

            .pm-bar-center {
                grid-column: 1 / -1;
                order: 3;
            }
        }

        .pm-bar-now {
            display: flex;
            align-items: center;
            gap: 12px;
            min-width: 0;
        }

        .pm-bar-cover {
            display: grid;
            flex: 0 0 auto;
            place-items: center;
            width: 46px;
            height: 46px;
            border-radius: 10px;
            background: linear-gradient(135deg, #0A5C74, #2FA8C9);
            color: #fff;
            font-weight: 800;
        }

        .pm-bar-meta {
            min-width: 0;
        }

        .pm-bar-meta b {
            display: block;
            overflow: hidden;
            font-size: 13px;
            color: var(--pm-ink);
            white-space: nowrap;
            text-overflow: ellipsis;
        }

        .pm-bar-meta span {
            font-size: 11px;
            color: var(--pm-muted);
        }

        .pm-bar-center {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 6px;
        }

        .pm-toggle {
            display: grid;
            place-items: center;
            width: 38px;
            height: 38px;
            border: 0;
            border-radius: 50%;
            background: var(--pm-deep);
            color: #fff;
            cursor: pointer;
        }

        .pm-toggle svg {
            width: 16px;
            height: 16px;
            fill: currentColor;
        }

        .pm-line {
            display: flex;
            align-items: center;
            gap: 10px;
            width: 100%;
        }

        .pm-line span {
            min-width: 34px;
            font-size: 11px;
            text-align: center;
            color: var(--pm-muted);
        }

        .pm-line input[type=range] {
            flex: 1;
            max-width: none;
            height: 4px;
            accent-color: #2FA8C9;
        }

        .pm-bar-right {
            display: flex;
            justify-content: flex-end;
        }

        .pm-pill {
            padding: 6px 12px;
            border-radius: 999px;
            background: var(--pm-light);
            font-size: 11px;
            font-weight: 700;
            color: var(--pm-deep);
        }
    </style>

    <div class="pm-wrap">

        <!-- ================= HERO ================= -->
        <header class="pm-hero">
            <div>
                <span class="pm-eyebrow">PoliMusic &middot; Song catalogue</span>
                <h1>Your celeste library</h1>
                <p>Every track stored in <strong>TBL_SONG</strong>, loaded through the business layer. Choose a song, press play and the player at the bottom will take over.</p>

                <div class="pm-stats">
                    <div class="pm-stat"><b><asp:Label ID="lblSongCount" runat="server" /></b><span>Songs</span></div>
                    <div class="pm-stat"><b><asp:Label ID="lblTotalPlays" runat="server" /></b><span>Plays</span></div>
                </div>
            </div>

            <div class="pm-hero-side">
                <div class="pm-user">
                    <asp:Literal ID="litAvatar" runat="server" />
                    <span class="pm-user-meta">
                        <strong><asp:Label ID="lblUserName" runat="server" /></strong>
                        <span class="pm-role"><asp:Label ID="lblUserRole" runat="server" /></span>
                    </span>
                </div>
                <button type="button" class="pm-btn pm-btn-solid" id="btnPlayAll">
                    <svg viewBox="0 0 24 24"><path d="M8 5v14l11-7z" /></svg>
                    Play all
                </button>
            </div>
        </header>

        <!-- ================= BODY ================= -->
        <div class="pm-body">

            <section class="pm-card">
                <div class="pm-card-head">
                    <h2>All songs</h2>
                    <div class="pm-search">
                        <input type="text" id="txtFilter" placeholder="Search a song..." autocomplete="off" />
                    </div>
                </div>

                <div class="pm-rows" id="pmRows">
                    <asp:Repeater ID="rptSongs" runat="server">
                        <ItemTemplate>
                            <div class="pm-row" data-name="<%# Attr(Eval("SONG_NAME")) %>">
                                <span class="pm-index"><%# Container.ItemIndex + 1 %></span>
                                <button type="button" class="pm-play"
                                        data-src="<%# SongUrl(Eval("SONG_PATH")) %>"
                                        data-title="<%# Attr(Eval("SONG_NAME")) %>"
                                        data-cover="<%# CoverClass(Container.ItemIndex) %>"
                                        data-plays="<%# PlaysValue(Eval("PLAYS")) %>"
                                        title="Play">
                                    <svg viewBox="0 0 24 24"><path d="M8 5v14l11-7z" /></svg>
                                </button>
                                <span class="pm-cover <%# CoverClass(Container.ItemIndex) %>"><%# Initial(Eval("SONG_NAME")) %></span>
                                <span class="pm-info">
                                    <span class="pm-name"><%# Text(Eval("SONG_NAME")) %></span>
                                    <span class="pm-sub"><%# Text(Eval("SONG_PATH")) %></span>
                                </span>
                                <span class="pm-plays"><%# PlaysValue(Eval("PLAYS")) %> plays</span>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <asp:PlaceHolder ID="phEmpty" runat="server" Visible="false">
                    <div class="pm-empty">There are no songs registered in TBL_SONG yet.</div>
                </asp:PlaceHolder>

                <asp:Label ID="lblMessage" runat="server" CssClass="pm-message" />
            </section>

            <aside class="pm-card">
                <h2>Now playing</h2>

                <div class="pm-now">
                    <div class="pm-now-cover" id="nowCover">&#9834;</div>
                    <div class="pm-now-title" id="nowTitle">Nothing playing</div>
                    <div class="pm-now-sub" id="nowSub">Pick a song from the list</div>
                </div>

                <ul class="pm-top">
                    <asp:Repeater ID="rptTop" runat="server">
                        <ItemTemplate>
                            <li>
                                <span class="pm-mini"><%# Initial(Eval("SONG_NAME")) %></span>
                                <span><%# Text(Eval("SONG_NAME")) %></span>
                                <span class="pm-top-plays"><%# PlaysValue(Eval("PLAYS")) %> plays</span>
                            </li>
                        </ItemTemplate>
                    </asp:Repeater>
                </ul>
            </aside>
        </div>
    </div>

    <!-- ================= BOTTOM PLAYER ================= -->
    <div class="pm-bar">
        <div class="pm-bar-now">
            <span class="pm-bar-cover" id="barCover">&#9834;</span>
            <span class="pm-bar-meta">
                <b id="barTitle">Nothing playing</b>
                <span id="barSub">Select a track</span>
            </span>
        </div>

        <div class="pm-bar-center">
            <button type="button" class="pm-toggle" id="barToggle" title="Play / Pause">
                <svg viewBox="0 0 24 24"><path d="M8 5v14l11-7z" /></svg>
            </button>
            <div class="pm-line">
                <span id="barCur">0:00</span>
                <input type="range" id="barSeek" min="0" max="100" value="0" step="1" />
                <span id="barDur">0:00</span>
            </div>
        </div>

        <div class="pm-bar-right">
            <span class="pm-pill" id="barPlays">0 plays</span>
        </div>
    </div>

    <audio id="pmAudio" preload="none"></audio>

    <script type="text/javascript">
        (function () {
            var audio = document.getElementById('pmAudio');
            var barCover = document.getElementById('barCover');
            var barTitle = document.getElementById('barTitle');
            var barSub = document.getElementById('barSub');
            var barPlays = document.getElementById('barPlays');
            var barToggle = document.getElementById('barToggle');
            var barSeek = document.getElementById('barSeek');
            var barCur = document.getElementById('barCur');
            var barDur = document.getElementById('barDur');
            var nowCover = document.getElementById('nowCover');
            var nowTitle = document.getElementById('nowTitle');
            var nowSub = document.getElementById('nowSub');

            var ICON_PLAY = '<svg viewBox="0 0 24 24"><path d="M8 5v14l11-7z" /></svg>';
            var ICON_PAUSE = '<svg viewBox="0 0 24 24"><path d="M6 5h4v14H6zm8 0h4v14h-4z" /></svg>';

            function formatTime(seconds) {
                if (!isFinite(seconds) || seconds < 0) { return '0:00'; }
                var m = Math.floor(seconds / 60);
                var s = Math.floor(seconds % 60);
                return m + ':' + (s < 10 ? '0' : '') + s;
            }

            function setToggleIcon(playing) {
                barToggle.innerHTML = playing ? ICON_PAUSE : ICON_PLAY;
            }

            function resetProgress() {
                barSeek.value = 0;
                barCur.textContent = '0:00';
                barDur.textContent = '0:00';
            }

            function selectTrack(button) {
                var src = button.getAttribute('data-src');
                var title = button.getAttribute('data-title');
                var cover = button.getAttribute('data-cover');
                var plays = button.getAttribute('data-plays');

                barTitle.textContent = title;
                nowTitle.textContent = title;
                barPlays.textContent = plays + ' plays';
                barCover.className = 'pm-bar-cover ' + cover;
                barCover.textContent = title.charAt(0).toUpperCase();
                nowCover.className = 'pm-now-cover ' + cover;
                nowCover.textContent = title.charAt(0).toUpperCase();
                resetProgress();
                setToggleIcon(false);

                if (!src) {
                    barSub.textContent = 'Audio file not found on the server';
                    nowSub.textContent = 'File missing in the song folder';
                    audio.removeAttribute('src');
                    audio.load();
                    return;
                }

                barSub.textContent = 'PoliMusic · celeste session';
                nowSub.textContent = 'Streaming from the song folder';
                audio.src = src;
                var promise = audio.play();
                if (promise && promise.catch) {
                    promise.catch(function () { setToggleIcon(false); });
                }
            }

            // Play buttons of every row
            var playButtons = document.querySelectorAll('.pm-play');
            for (var i = 0; i < playButtons.length; i++) {
                playButtons[i].addEventListener('click', function () {
                    selectTrack(this);
                });
            }

            // Play / pause
            barToggle.addEventListener('click', function () {
                if (!audio.getAttribute('src')) { return; }
                if (audio.paused) {
                    audio.play();
                } else {
                    audio.pause();
                }
            });

            audio.addEventListener('play', function () { setToggleIcon(true); });
            audio.addEventListener('pause', function () { setToggleIcon(false); });
            audio.addEventListener('ended', function () { setToggleIcon(false); });

            audio.addEventListener('loadedmetadata', function () {
                barDur.textContent = formatTime(audio.duration);
            });

            audio.addEventListener('timeupdate', function () {
                barCur.textContent = formatTime(audio.currentTime);
                if (isFinite(audio.duration) && audio.duration > 0) {
                    barSeek.value = Math.round((audio.currentTime / audio.duration) * 100);
                }
            });

            audio.addEventListener('error', function () {
                barSub.textContent = 'This audio file could not be loaded';
                setToggleIcon(false);
            });

            barSeek.addEventListener('input', function () {
                if (isFinite(audio.duration) && audio.duration > 0) {
                    audio.currentTime = (barSeek.value / 100) * audio.duration;
                }
            });

            // Play all: starts the first song that really has a file
            document.getElementById('btnPlayAll').addEventListener('click', function () {
                for (var i = 0; i < playButtons.length; i++) {
                    if (playButtons[i].getAttribute('data-src')) {
                        selectTrack(playButtons[i]);
                        return;
                    }
                }
                barSub.textContent = 'No audio file available on the server';
            });

            // Simple client side filter
            var filter = document.getElementById('txtFilter');
            var rows = document.querySelectorAll('.pm-row');
            filter.addEventListener('input', function () {
                var term = this.value.toLowerCase();
                for (var i = 0; i < rows.length; i++) {
                    var name = (rows[i].getAttribute('data-name') || '').toLowerCase();
                    rows[i].style.display = name.indexOf(term) === -1 ? 'none' : '';
                }
            });
        })();
    </script>

</asp:Content>
