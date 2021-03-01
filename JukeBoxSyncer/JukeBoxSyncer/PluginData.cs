using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Runtime;
using System.Linq;

namespace JukeBoxSyncer
{
    public class PluginData
    {
        public string[] Directories;
        public List<Song> Songs = new List<Song>();
        public PluginData(PluginData Copy)
        {
            Directories = new string[Copy.Directories.Length];
            for (int i = 0; i < Copy.Directories.Length; ++i)
            {
                Directories[i] = Copy.Directories[i];
            }
            for (int i = 0; i < Copy.Songs.Count; ++i)
            {
                Song newsong = new Song();

                newsong.Filename = Copy.Songs[i].Filename;
                newsong.Filepath = Copy.Songs[i].Filepath;
                newsong.seconds = Copy.Songs[i].seconds;
                newsong.Tracks = new Track[Copy.Songs[i].Tracks.Length];
                for (int e = 0; e < Copy.Songs[i].Tracks.Length; ++e)
                {
                    newsong.Tracks[e].Id = Copy.Songs[i].Tracks[e].Id;
                    newsong.Tracks[e].Name = Copy.Songs[i].Tracks[e].Name;
                }
                Songs.Add(newsong);
            }
        }
        public PluginData(string file)
        {
            int i = 0;
            while (i < file.Length)
            {
                if (file[i] == '{')//interesting callstack question
                {
                    ++i;
                    GetObject(file, ref i);
                }
                else
                {
                    ++i;
                }
            }
        }
        public void Write(string account)
        {
            string lotro = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments) + "/The Lord of the Rings Online";
            if (!Directory.Exists(lotro))
            {
                Directory.CreateDirectory(lotro);
            }
            string pluginData = lotro + "/PluginData";
            if (!Directory.Exists(pluginData))
            {
                Directory.CreateDirectory(pluginData);
            }
            string all = account + "/AllServers";
            if (!Directory.Exists(all))
            {
                Directory.CreateDirectory(all);
            }
            string JBData = all + "/JukeBoxData.plugindata";
            if (!File.Exists(JBData))
            {
                File.Create(JBData);
            }
            using (StreamWriter w = new StreamWriter(JBData))
            {
                w.Write("return\n" +
                        "{\n");
                WriteDirectories(w);
                WriteSongs(w);
                w.Write("}");
            }
        }
        private void WriteDirectories(StreamWriter w)
        {
            w.Write("\t[\"Directories\"] =\n" +
                    "\t{\n");
            for (int i = 0; i < Directories.Length; ++i)
            {
                w.Write("\t\t[" + (i + 1) + "] = \"" + Directories[i] + "\"");
                if (i + 1 < Directories.Length)
                {
                    w.Write(",");
                }
                w.Write("\n");
            }
            w.Write("\t},\n");
        }
        private void WriteSongs(StreamWriter w)
        {
            w.Write("\t[\"Songs\"] =\n" +
                    "\t{");
            for (int i = 0; i < Songs.Count; ++i)
            {
                w.Write("\t\t[" + (i + 1) + "] =\n" +
                        "\t\t{\n" +
                        "\t\t\t[\"Filepath\"] = \"" + Songs[i].Filepath + "\",\n" +
                        "\t\t\t[\"Filename\"] = \"" + Songs[i].Filename + "\",\n" +
                        "\t\t\t[\"Length\"] = \"" + Songs[i].seconds + "\",\n" +
                        "\t\t\t[\"Tracks\"] =\"\n" +
                        "\t\t\t{\n");
                for (int e = 0; i < Songs[i].Tracks.Length; ++e)
                {
                    w.Write("\t\t\t\t[" + (e + 1) + "] =\n" +
                        "\t\t\t\t\n" +
                        "\t\t\t\t\t[\"Id\"] =\"" + Songs[i].Tracks[e].Id + "\",\n" +
                        "\t\t\t\t\t[\"Name\"] =\"" + Songs[i].Tracks[e].Name + "\"\n" +
                        "\t\t\t\t}");
                    if (e + 1 < Songs[i].Tracks.Length) w.Write(",");
                    w.Write("\n");
                }
                w.Write("\t\t\t}");
                if (i + 1 < Songs.Count) w.Write(",");
                w.Write("\n");
            }
            w.Write("}\n");
        }
        private void GetObject(string file, ref int i)
        {
            string label = null;
            while (file[i] != '}')
            {
                if (file[i] == '[')
                {
                    ++i;
                    while (file[i++] != '\"') ;
                    label = GetWord(file, ref i);
                }
                else if (file[i] == '{')
                {
                    ++i;
                    if (label == "Directories")
                    {
                        GetDirectories(file, ref i);
                    }
                    else if (label == "Songs")
                    {
                        GetSongs(file, ref i);
                    }
                }
            }
            ++i;
        }
        private void GetSongs(string file, ref int i)
        {
            List<Song> vals = new List<Song>();
            while (file[i] != '}')
            {
                if (file[i++] == '{')
                {
                    vals.Add(GetSong(file, ref i));
                }
            }
            Songs = vals;
            ++i;
        }
        private Song GetSong(string file, ref int i)
        {
            Song val = new Song();
            List<Track> tracks = new List<Track>();
            string label = "";
            while (file[i] != '}')
            {
                if (file[i] == '\"')
                {
                    ++i;
                    label = GetWord(file, ref i);
                }
                else if (file[i] == '=')
                {
                    ++i;
                    if (label == "Tracks")
                    {
                        while (file[i++] != '{') ;
                        while (file[i] != '}')
                        {
                            tracks.Add(GetTrack(file, ref i));
                        }
                        ++i;
                    }
                    else
                    {
                        while (file[i++] != '\"') ;
                        if (label == "Filepath")
                        {
                            val.Filepath = GetWord(file, ref i);
                        }
                        else if (label == "Filename")
                        {
                            val.Filename = GetWord(file, ref i);
                        }
                        else if (label == "Length")
                        {
                            val.seconds = int.Parse(GetWord(file, ref i));
                        }
                    }
                }
            }
            ++i;
            val.Tracks = tracks.ToArray();
            return val;
        }
        private Track GetTrack(string file, ref int i)
        {
            Track val = new Track();
            string label = "";
            while (file[i] != '}')
            {
                if (file[i++] == '\"')
                {
                    label = GetWord(file, ref i);
                    while (file[i++] != '\"') ;
                    if (label == "Id")
                    {
                        val.Id = GetWord(file, ref i);
                    }
                    else if (label == "Name")
                    {
                        val.Name = GetWord(file, ref i);
                    }
                }
            }
            ++i;
            return val;
        }
        private void GetDirectories(string file, ref int i)
        {
            List<string> vals = new List<string>();
            while (file[i] != '}')
            {
                if (file[i++] == '\"')
                {
                    vals.Add(GetWord(file, ref i));
                }
            }
            ++i;
            Directories = vals.ToArray();
        }
        private string GetWord(string file, ref int i)
        {
            string val = "";
            while (file[i] != '\"')
            {
                val += file[i++];
            }
            ++i;
            return val;
        }
        public struct Song
        {
            public string Filepath;
            public string Filename;
            public int seconds;
            public Track[] Tracks;
        }
        public struct Track
        {
            public string Id;
            public string Name;
        }
    }
}
