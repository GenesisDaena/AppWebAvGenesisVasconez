using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.PoliMusicV3
{
    /// <summary>
    /// Capa de logica de negocio de las canciones.
    /// Todos los metodos delegan en DAL.PoliMusicV3.Song.
    /// </summary>
    public class Song
    {
        private string strConnectionString;

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        public int Save(EntityLayer.PoliMusicV3.Song song)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).Save(song);
        }

        public DataTable Read()
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).Read();
        }

        public DataTable ReadTop(int top)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).ReadTop(top);
        }

        public EntityLayer.PoliMusicV3.Song ReadById(int idSong)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).ReadById(idSong);
        }

        public int Update(EntityLayer.PoliMusicV3.Song song)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).Update(song);
        }

        public int IncrementPlays(int idSong)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).IncrementPlays(idSong);
        }

        public int Delete(int idSong)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).Delete(idSong);
        }

        public int CheckExistSong(string songName)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).CheckExistSong(songName);
        }

        /// <summary>
        /// Valida los campos obligatorios antes de guardar.
        /// Devuelve cadena vacia cuando todo esta correcto.
        /// </summary>
        public string ValidationsRequired(EntityLayer.PoliMusicV3.Song song)
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
            if (song.Plays < 0)
            {
                return "Plays cannot be a negative number!";
            }
            return string.Empty;
        }

        /// <summary>
        /// Valida que el nombre de la cancion no este repetido.
        /// Devuelve cadena vacia cuando todo esta correcto.
        /// </summary>
        public string ValidationsDuplicated(EntityLayer.PoliMusicV3.Song song)
        {
            if (CheckExistSong(song.SongName) != 0)
            {
                return "Song already registered!";
            }
            return string.Empty;
        }
    }
}
