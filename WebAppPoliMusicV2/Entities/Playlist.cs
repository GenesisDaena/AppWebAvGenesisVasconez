using System;
using System.Collections.Generic;
using System.Web;

namespace WebAppPoliMusicV2.Entities
{
    public class Playlist
    {
        public Playlist()
        {
        }

        public Playlist(int id, int idUser, string title, string creationDate, int type, string photo, int songCount)
        {
            ID = id;
            IDUser = idUser;
            Title = title;
            CreationDate = creationDate;
            Type = type;
            Photo = photo;
            SongCount = songCount;
        }

        public int ID { get; set; }
        public int IDUser { get; set; }
        public string Title { get; set; }
        public string CreationDate { get; set; }
        /// <summary>0 = Public, 1 = Private (TBL_CATALOG / PLAYLIST TYPE)</summary>
        public int Type { get; set; }
        public string Photo { get; set; }
        public int SongCount { get; set; }
    }
}
