using System;
using System.Collections.Generic;
using System.Data;
using System.Web;

namespace WebAppPoliMusicV2.BLL
{
    /// <summary>
    /// Business Logic Layer for songs. Every method delegates to DAL.Song.
    /// </summary>
    public class Song
    {
        private string strConnectionString;

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        public int Save(Entities.Song song)
        {
            return new DAL.Song(strConnectionString).Save(song);
        }

        public DataTable Read()
        {
            return new DAL.Song(strConnectionString).Read();
        }

        public Entities.Song ReadById(int idSong)
        {
            return new DAL.Song(strConnectionString).ReadById(idSong);
        }

        public int Update(Entities.Song song)
        {
            return new DAL.Song(strConnectionString).Update(song);
        }

        public int IncrementPlays(int idSong)
        {
            return new DAL.Song(strConnectionString).IncrementPlays(idSong);
        }

        public int Delete(int idSong)
        {
            return new DAL.Song(strConnectionString).Delete(idSong);
        }

        public int CheckExistSong(string songName)
        {
            return new DAL.Song(strConnectionString).CheckExistSong(songName);
        }

        /// <summary>
        /// Required fields and duplicated name validations before saving a song.
        /// Returns an empty string when everything is valid.
        /// </summary>
        public string ValidationsRequired(Entities.Song song)
        {
            if (song == null)
            {
                return "The song information is required!";
            }
            if (string.IsNullOrEmpty(song.SongName))
            {
                return "Song name is required!";
            }
            if (string.IsNullOrEmpty(song.SongPath))
            {
                return "Song path is required!";
            }
            if (song.Plays.HasValue && song.Plays.Value < 0)
            {
                return "Plays cannot be a negative number!";
            }
            return string.Empty;
        }

        /// <summary>
        /// Validations that need to query the database (duplicated song name).
        /// Returns an empty string when everything is valid.
        /// </summary>
        public string ValidationsDuplicated(Entities.Song song)
        {
            if (CheckExistSong(song.SongName) != 0)
            {
                return "Song already registered!";
            }
            return string.Empty;
        }
    }
}
