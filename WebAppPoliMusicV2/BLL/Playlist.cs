using System;
using System.Collections.Generic;
using System.Data;
using System.Web;

namespace WebAppPoliMusicV2.BLL
{
    /// <summary>
    /// Business Logic Layer for playlists. Every method delegates to DAL.Playlist.
    /// </summary>
    public class Playlist
    {
        private string strConnectionString;

        public Playlist(string strConnString)
        {
            strConnectionString = strConnString;
        }

        public DataTable ReadByUser(int idUser)
        {
            return new DAL.Playlist(strConnectionString).ReadByUser(idUser);
        }

        /// <summary>
        /// Catalog value of the playlist type: 0 = Public, 1 = Private.
        /// </summary>
        public string GetTypeName(int type)
        {
            return type == 1 ? "Private" : "Public";
        }
    }
}
