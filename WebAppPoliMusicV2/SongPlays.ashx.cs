using System;
using System.Configuration;
using System.Web;

namespace WebAppPoliMusicV2
{
    /// <summary>
    /// Adds one play to TBL_SONG without reloading the page.
    /// Called from Song.aspx with an XMLHttpRequest: SongPlays.ashx?id=3
    /// </summary>
    public class SongPlays : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

            int idSong;
            if (!int.TryParse(context.Request.QueryString["id"], out idSong) || idSong <= 0)
            {
                context.Response.StatusCode = 400;
                context.Response.Write("0");
                return;
            }

            try
            {
                string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;
                int plays = new BLL.Song(strConnString).IncrementPlays(idSong);
                context.Response.Write(plays.ToString());
            }
            catch (Exception)
            {
                context.Response.StatusCode = 500;
                context.Response.Write("0");
            }
        }

        public bool IsReusable
        {
            get { return false; }
        }
    }
}
