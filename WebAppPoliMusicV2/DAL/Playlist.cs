using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web;

namespace WebAppPoliMusicV2.DAL
{
    /// <summary>
    /// Data Access Layer for TBL_PLAYLIST.
    /// Table: ID_PLAYLIST (identity), ID_USER, TITLE, CREATION_DATE, TYPE, PHOTO
    /// </summary>
    public class Playlist
    {
        private string strConnectionString;

        public Playlist(string strConnString)
        {
            strConnectionString = strConnString;
        }

        /// <summary>
        /// Returns the playlists of one user plus the number of songs of each one.
        /// </summary>
        public DataTable ReadByUser(int idUser)
        {
            DataTable dtPlaylist = new DataTable();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT p.[ID_PLAYLIST], p.[ID_USER], p.[TITLE], p.[CREATION_DATE], p.[TYPE], p.[PHOTO], " +
                    "(SELECT COUNT(*) FROM [TBL_PLAYLIST_SONG] ps WHERE ps.[ID_PLAYLIST] = p.[ID_PLAYLIST]) AS [SONG_COUNT] " +
                    "FROM [TBL_PLAYLIST] p " +
                    "WHERE p.[ID_USER] = @ID_USER " +
                    "ORDER BY p.[CREATION_DATE] DESC", con))
                {
                    cmd.Parameters.AddWithValue("@ID_USER", idUser);
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtPlaylist);
                        return dtPlaylist;
                    }
                }
            }
        }
    }
}
