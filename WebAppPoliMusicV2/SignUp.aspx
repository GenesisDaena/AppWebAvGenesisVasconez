<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SignUp.aspx.cs" Inherits="WebAppPoliMusicV2.SignUp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>PoliMusic &middot; Create account</title>
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

                <h1 class="auth-headline">Create your account.<br /><span>Start your library.</span></h1>
                <p class="auth-sub">
                    Save your playlists, follow your reproduction counter and take your music wherever you go.
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
                <div class="eyebrow">New listener</div>
                <h1>Sign up</h1>
                <p class="hint">Fields marked with <span class="req">*</span> are required.</p>

                <div class="grid-2">
                    <div class="field">
                        <label for="<%= txtUserName.ClientID %>">Username <span class="req">*</span></label>
                        <asp:TextBox ID="txtUserName" runat="server" CssClass="input" placeholder="your.username" autocomplete="username" />
                    </div>
                    <div class="field">
                        <label for="<%= txtEmail.ClientID %>">Email <span class="req">*</span></label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="input" placeholder="you@epn.edu.ec" autocomplete="email" />
                    </div>
                </div>

                <div class="grid-2">
                    <div class="field">
                        <label for="<%= txtPassword.ClientID %>">Password <span class="req">*</span></label>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="input" TextMode="Password" placeholder="••••••••" autocomplete="new-password" />
                    </div>
                    <div class="field">
                        <label for="<%= txtConfirmPassword.ClientID %>">Confirm password <span class="req">*</span></label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="input" TextMode="Password" placeholder="••••••••" autocomplete="new-password" />
                    </div>
                </div>

                <div class="grid-2">
                    <div class="field">
                        <label for="<%= txtBirthDate.ClientID %>">Birth date (dd/MM/yyyy)</label>
                        <asp:TextBox ID="txtBirthDate" runat="server" CssClass="input" placeholder="15/12/2000" />
                    </div>
                    <div class="field">
                        <label for="<%= fupPhoto.ClientID %>">Profile photo</label>
                        <asp:FileUpload ID="fupPhoto" runat="server" CssClass="input" />
                    </div>
                </div>

                <asp:Button ID="btnSumbit" runat="server" Text="Create account" OnClick="btnSumbit_Click" />

                <asp:Panel ID="frmConfirmation" runat="server" Visible="true">
                    <asp:Label ID="lblMessage" runat="server" CssClass="msg" />
                </asp:Panel>

                <p class="auth-alt">
                    Already have an account?
                    <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl="~/Login.aspx">Sign in</asp:HyperLink>
                </p>
            </div>
        </section>

    </form>
</body>
</html>
