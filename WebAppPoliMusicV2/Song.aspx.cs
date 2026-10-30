using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV2
{
    public partial class Song : System.Web.UI.Page
    {
        string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                LoadLoggedUser();
                LoadSongs();
                LoadPlaylists();
            }
        }

        /// <summary>
        /// Takes the user stored in Session when the login was successful.
        /// </summary>
        private void LoadLoggedUser()
        {
            Entities.User user = Session[Util.Constants.USER] as Entities.User;
            if (user == null)
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            lblUserName.Text = Server.HtmlEncode(user.UserName);
            lblHeroName.Text = Server.HtmlEncode(user.UserName);
            lblUserRole.Text = user.UserType == Util.Constants.ID_USER_ADMIN ? "Administrator" : "Listener";
            litAvatar.Text = BuildAvatar(user);
        }

        /// <summary>
        /// Loads the songs through the business layer (BLL -> DAL -> TBL_SONG).
        /// </summary>
        private void LoadSongs()
        {
            DataTable dtSong = new BLL.Song(strConnString).Read();

            rptSongs.DataSource = dtSong;
            rptSongs.DataBind();

            rptCards.DataSource = dtSong;
            rptCards.DataBind();

            lblSongCount.Text = dtSong.Rows.Count.ToString();
            lblCardsCount.Text = dtSong.Rows.Count.ToString();
            lblTotalPlays.Text = GetTotalPlays(dtSong).ToString();
            phEmpty.Visible = dtSong.Rows.Count == 0;

            if (dtSong.Rows.Count == 0)
            {
                lblMessage.Text = "There are no songs registered in TBL_SONG yet.";
            }
        }

        /// <summary>
        /// Loads the playlists of the logged user to fill the sidebar.
        /// </summary>
        private void LoadPlaylists()
        {
            Entities.User user = Session[Util.Constants.USER] as Entities.User;
            if (user == null)
            {
                return;
            }

            DataTable dtPlaylist = new BLL.Playlist(strConnString).ReadByUser(user.ID);
            rptPlaylists.DataSource = dtPlaylist;
            rptPlaylists.DataBind();
            lblPlaylistCount.Text = dtPlaylist.Rows.Count.ToString();
        }

        private int GetTotalPlays(DataTable dtSong)
        {
            int total = 0;
            foreach (DataRow row in dtSong.Rows)
            {
                total += PlaysValue(row["PLAYS"]);
            }
            return total;
        }

        private string BuildAvatar(Entities.User user)
        {
            string photo = SafeImageUrl(user.Photo);
            if (photo != string.Empty)
            {
                return "<span class=\"avatar\"><img src=\"" + photo + "\" alt=\"\" /></span>";
            }
            return "<span class=\"avatar\">" + Initial(user.UserName) + "</span>";
        }

        // ---------------------------------------------------------------
        // Helpers used from the data binding expressions of the .aspx
        // ---------------------------------------------------------------

        /// <summary>Resolves "~/songFiles/xxx.mp3" into a valid browser URL.</summary>
        public string SongUrl(object path)
        {
            if (path == null || path == DBNull.Value || path.ToString().Trim() == string.Empty)
            {
                return string.Empty;
            }
            return ResolveUrl(path.ToString());
        }

        /// <summary>Returns the resolved URL only when the file really exists on disk.</summary>
        public string SafeImageUrl(object path)
        {
            if (path == null || path == DBNull.Value || path.ToString().Trim() == string.Empty)
            {
                return string.Empty;
            }
            try
            {
                string relative = path.ToString();
                if (!File.Exists(Server.MapPath(relative)))
                {
                    return string.Empty;
                }
                return ResolveUrl(relative);
            }
            catch (Exception)
            {
                return string.Empty;
            }
        }

        /// <summary>Renders the playlist image or, when it is missing, its initial letter.</summary>
        public string CoverHtml(object photo, object title)
        {
            string url = SafeImageUrl(photo);
            if (url != string.Empty)
            {
                return "<img src=\"" + url + "\" alt=\"\" />";
            }
            return Initial(title);
        }

        /// <summary>Picks one of the five gradient covers of the palette.</summary>
        public string CoverClass(object index)
        {
            int value = 0;
            int.TryParse(Convert.ToString(index), out value);
            return "c" + ((value % 5) + 1);
        }

        /// <summary>First letter of a name, used when there is no image.</summary>
        public string Initial(object value)
        {
            string text = value == null || value == DBNull.Value ? string.Empty : value.ToString().Trim();
            if (text.Length == 0)
            {
                return "?";
            }
            return HttpUtility.HtmlEncode(text.Substring(0, 1).ToUpper());
        }

        /// <summary>HTML encodes a value before writing it as text.</summary>
        public string Text(object value)
        {
            if (value == null || value == DBNull.Value)
            {
                return string.Empty;
            }
            return HttpUtility.HtmlEncode(value.ToString());
        }

        /// <summary>HTML attribute encodes a value.</summary>
        public string Attr(object value)
        {
            if (value == null || value == DBNull.Value)
            {
                return string.Empty;
            }
            return HttpUtility.HtmlAttributeEncode(value.ToString());
        }

        /// <summary>Reads PLAYS as an integer, even when the column is NULL.</summary>
        public int PlaysValue(object value)
        {
            if (value == null || value == DBNull.Value)
            {
                return 0;
            }
            int plays;
            int.TryParse(value.ToString(), out plays);
            return plays;
        }

        /// <summary>0 = Public, 1 = Private (TBL_CATALOG / PLAYLIST TYPE).</summary>
        public string TypeName(object type)
        {
            return new BLL.Playlist(strConnString).GetTypeName(PlaysValue(type));
        }
    }
}
