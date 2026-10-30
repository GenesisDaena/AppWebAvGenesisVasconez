<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="WebAppPoliMusicV2.Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>PoliMusic &middot; Sign in</title>
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
    <form id="formLogin" runat="server" class="auth">

        <!-- ============ Panel de marca ============ -->
        <section class="auth-brand">
            <span class="blob blob-1"></span>
            <span class="blob blob-2"></span>
            <span class="blob blob-3"></span>

            <div class="auth-brand-inner">
                <div class="auth-logo">
                    <span class="mark">
                        <svg viewBox="0 0 24 24"><path d="M12 3v10.55A4 4 0 1 0 14 17V7h4V3h-6z" /></svg>
                    </span>
                    PoliMusic
                </div>

                <h1 class="auth-headline">Millions of songs.<br /><span>One orange library.</span></h1>
                <p class="auth-sub">
                    Sign in to keep your playlists, your plays and your favourite tracks in one single place.
                </p>

                <div class="equalizer">
                    <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
                </div>
            </div>

            <div class="auth-brand-foot">
                <span>Advanced Web Applications</span>
                <span>Escuela Polit&eacute;cnica Nacional</span>
            </div>
        </section>

        <!-- ============ Panel del formulario ============ -->
        <section class="auth-panel">
            <div class="auth-card">
                <div class="eyebrow">Welcome back</div>
                <h1>Sign in</h1>
                <p class="hint">Use your PoliMusic account to continue listening.</p>

                <div class="field">
                    <label for="<%= txtLogin.ClientID %>">Username</label>
                    <asp:TextBox ID="txtLogin" runat="server" CssClass="input" placeholder="your.username" autocomplete="username" />
                </div>

                <div class="field">
                    <label for="<%= txtPassword.ClientID %>">Password</label>
                    <asp:TextBox ID="txtPassword" runat="server" CssClass="input" TextMode="Password" placeholder="••••••••" autocomplete="current-password" />
                </div>

                <asp:Button ID="btnLogin" runat="server" Text="Sign in" OnClick="BtnLogin_Click" />

                <asp:Label ID="lblMessage" runat="server" CssClass="msg" />

                <p class="auth-alt">
                    New to PoliMusic?
                    <asp:LinkButton ID="LinkButtonNewUser" runat="server" OnClick="LinkButtonNewUser_Click">Create an account</asp:LinkButton>
                </p>
            </div>
        </section>

    </form>
</body>
</html>
