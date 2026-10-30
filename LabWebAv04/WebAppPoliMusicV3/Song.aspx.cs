using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV3
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
            }
        }

        /// <summary>
        /// Toma el usuario guardado en Session cuando el login fue correcto.
        /// </summary>
        private void LoadLoggedUser()
        {
            EntityLayer.PoliMusicV3.User user = Session[EntityLayer.PoliMusicV3.Util.Constants.USER] as EntityLayer.PoliMusicV3.User;
            if (user == null)
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            lblUserName.Text = Server.HtmlEncode(user.UserName);
            lblUserRole.Text = user.UserType == EntityLayer.PoliMusicV3.Util.Constants.ID_USER_ADMIN ? "Administrator" : "Listener";
            litAvatar.Text = BuildAvatar(user);
        }

        /// <summary>
        /// Carga las canciones por la capa de negocio (BLL -> DAL -> TBL_SONG).
        /// </summary>
        private void LoadSongs()
        {
            BLL.PoliMusicV3.Song bllSong = new BLL.PoliMusicV3.Song(strConnString);

            DataTable dtSong = bllSong.Read();
            rptSongs.DataSource = dtSong;
            rptSongs.DataBind();

            rptTop.DataSource = bllSong.ReadTop(3);
            rptTop.DataBind();

            lblSongCount.Text = dtSong.Rows.Count.ToString();
            lblTotalPlays.Text = GetTotalPlays(dtSong).ToString();
            phEmpty.Visible = dtSong.Rows.Count == 0;

            if (dtSong.Rows.Count == 0)
            {
                lblMessage.Text = "There are no songs registered in TBL_SONG yet.";
            }
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

        private string BuildAvatar(EntityLayer.PoliMusicV3.User user)
        {
            string photo = SafeImageUrl(user.Photo);
            if (photo != string.Empty)
            {
                return "<span class=\"pm-avatar\"><img src=\"" + photo + "\" alt=\"\" /></span>";
            }
            return "<span class=\"pm-avatar\">" + Initial(user.UserName) + "</span>";
        }

        // ---------------------------------------------------------------
        // Metodos usados desde las expresiones de enlace del .aspx
        // ---------------------------------------------------------------

        /// <summary>
        /// Convierte "~/songFiles/xxx.mp3" en una URL valida.
        /// Devuelve cadena vacia si el archivo no existe en el servidor.
        /// </summary>
        public string SongUrl(object path)
        {
            if (path == null || path == DBNull.Value || path.ToString().Trim() == string.Empty)
            {
                return string.Empty;
            }
            try
            {
                string relative = path.ToString().Trim();
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

        /// <summary>
        /// Devuelve la URL resuelta solo cuando la imagen existe en el servidor.
        /// </summary>
        public string SafeImageUrl(object path)
        {
            if (path == null || path == DBNull.Value || path.ToString().Trim() == string.Empty)
            {
                return string.Empty;
            }
            try
            {
                string relative = path.ToString().Trim();
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

        /// <summary>
        /// Elige uno de los cinco degradados de la paleta celeste.
        /// </summary>
        public string CoverClass(object index)
        {
            int value = 0;
            int.TryParse(Convert.ToString(index), out value);
            return "pm-c" + ((value % 5) + 1);
        }

        /// <summary>
        /// Primera letra del nombre, usada cuando no hay imagen de portada.
        /// </summary>
        public string Initial(object value)
        {
            string text = value == null || value == DBNull.Value ? string.Empty : value.ToString().Trim();
            if (text.Length == 0)
            {
                return "?";
            }
            return HttpUtility.HtmlEncode(text.Substring(0, 1).ToUpper());
        }

        /// <summary>
        /// Codifica un valor antes de escribirlo como texto.
        /// </summary>
        public string Text(object value)
        {
            if (value == null || value == DBNull.Value)
            {
                return string.Empty;
            }
            return HttpUtility.HtmlEncode(value.ToString());
        }

        /// <summary>
        /// Codifica un valor para usarlo dentro de un atributo HTML.
        /// </summary>
        public string Attr(object value)
        {
            if (value == null || value == DBNull.Value)
            {
                return string.Empty;
            }
            return HttpUtility.HtmlAttributeEncode(value.ToString());
        }

        /// <summary>
        /// Lee PLAYS como entero aunque la columna sea NULL.
        /// </summary>
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
    }
}
