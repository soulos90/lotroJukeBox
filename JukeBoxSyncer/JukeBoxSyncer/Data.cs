using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Runtime;
using System.Linq;

namespace JukeBoxSyncer
{

    public class Data
    {
        public int id;
        public bool found = false;
        public PluginData PData;
        public List<PluginInputs> PInputs = new List<PluginInputs>();
        public string account;
        public DateTime SyncTime;
        public int inpCount = 0;
        public bool newSongs = false;
        private bool IWroteData = false;
        public Data(int i, DateTime at)
        {
            id = i;
            SyncTime = at;
            CheckFiles();
        }
        public Data(int i, DateTime at, PluginData copy)
        {
            id = i;
            SyncTime = at;
            CheckFiles(copy);
        }
        public void CheckFiles(PluginData copy = null)
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
            string[] accountnames = Directory.GetDirectories(pluginData);
            for (int i = 0; i < accountnames.Length; ++i)
            {
                string all = accountnames[i] + "/AllServers";
                if (!Directory.Exists(all))
                {
                    Directory.CreateDirectory(all);
                }
                string[] JBInputs = Directory.GetFiles(all, "JukeBoxInputs*.plugindata");
                bool found = false;
                foreach (string item in JBInputs)
                {
                    PluginInputs temp;
                    using (StreamReader r = new StreamReader(item))
                    {
                        string file = r.ReadToEnd();
                        temp = new PluginInputs(file);
                    }
                    if (temp.Inputs.IsActive && temp.Inputs.Timecode != SyncTime.ToBinary())
                    {
                        PInputs.Add(temp);
                        found = true;
                    }
                }
                if (found && !IWroteData)
                {
                    IWroteData = true;
                    string JBData = all + "/JukeBoxData.plugindata";
                    account = accountnames[i];
                    if (!File.Exists(JBData))
                    {
                        File.Create(JBData);
                    }
                    PData = ReadData(JBData, copy);
                    break;
                }
            }
        }
        private PluginData ReadData(string path, PluginData copy)
        {
            PluginData vals;
            if (copy == null)
            {
                using (StreamReader r = new StreamReader(path))
                {
                    string file = r.ReadToEnd();
                    vals = new PluginData(file);
                }
                CompDataToFiles(ref vals);
            }
            else
            {
                vals = new PluginData(copy);
            }
            return vals;
        }
        private void CompDataToFiles(ref PluginData v)
        {
            if (CheckSongsD())
            {
                string music = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments) + "/The Lord of the Rings Online/Music";
                List<string> dRects = new List<string>();
                GetDirectories(music, music, ref dRects);
                PData.Directories = new string[dRects.Count];
                for (int i = 0; i < dRects.Count; ++i)
                {
                    PData.Directories[i] = dRects[i];
                }
                int songnum = 0;
                for (int i = 0; i < PData.Directories.Length; ++i)
                {
                    CheckSongsInDirectory(music + PData.Directories[i], ref songnum);
                }
            }
            else
            {
                PData.Directories = null;
                PData.Songs = null;
            }
        }
        private void CheckSongsInDirectory(string path, ref int SI)
        {
            string[] Songs = Directory.GetFiles(path, "*.abc");
            bool cont = true;
            int i = 0;
            while (cont)
            {
                if (Songs.Length > i && PData.Songs.Count > SI)//look at files in directories in order, while looking at files in list in order
                {
                    string songname = Songs[i].Replace(path, "");
                    if (songname == PData.Songs[SI].Filename)//if still synced continue
                    {
                        ++i;
                        ++SI;
                    }
                    else if (PData.Songs.Count > SI + 1 && songname == PData.Songs[SI + 1].Filename)//if files matches next in list then current in list was removed
                    {
                        PData.Songs.RemoveAt(SI);
                        ++i;
                        newSongs = true;
                    }
                    else if (Songs.Length > i + 1 && Songs[i + 1].Replace(path, "") == PData.Songs[SI].Filename)//if if next file matches current file in list then current file is new
                    {
                        PData.Songs.Insert(SI, ReadSongF(path, songname));
                        ++i;
                        ++SI;
                        newSongs = true;
                    }
                    else//multiple consecutive differences, need to iterate through arrays further to detect desync
                    {
                        bool fileE = false, listE = false;
                        for (int e = i + 1, j = SI + 1; (e < Songs.Length && !fileE) || (j < PData.Songs.Count && !listE); ++e, ++j)
                        {
                            if (!fileE && e < Songs.Length)
                            {
                                string tempname = Songs[e].Replace(path, "");
                                if (tempname == PData.Songs[SI].Filename)
                                {
                                    fileE = true;
                                    newSongs = true;
                                }
                            }
                            if (!listE && j < PData.Songs.Count)
                            {
                                if (PData.Songs[j].Filename == songname)
                                {
                                    listE = true;
                                    newSongs = true;
                                }
                            }
                        }
                        if (listE && fileE)//uh oh... this algorithm doesn't work
                        {

                        }
                        else if (listE)//file exists eventually in list meaning lots of songs in list removed from files
                        {
                            while (SI < PData.Songs.Count)
                            {
                                if (PData.Songs[SI].Filename != songname)
                                {
                                    PData.Songs.RemoveAt(SI);
                                }
                                else
                                {
                                    break;
                                }
                            }
                        }
                        else if (fileE)//current song in list exists eventually in files meaning lots of songs were added
                        {
                            while (i < Songs.Length)
                            {
                                string tempname = Songs[i].Replace(path, "");
                                if (tempname != PData.Songs[SI].Filename)
                                {
                                    PData.Songs.Insert((SI++) - 1, ReadSongF(path, tempname));
                                }
                                else
                                {
                                    break;
                                }
                            }
                        }
                    }
                }
                else if (Songs.Length > i)//reached end of list rest of song files need to be added
                {
                    string tempname = Songs[i++].Replace(path, "");
                    PData.Songs.Add(ReadSongF(path, tempname));
                }
                else if (PData.Songs.Count > SI)//reached end of files rest of songs in list need to be removed
                {
                    PData.Songs.RemoveAt(SI);
                }
                else//done with loop
                {
                    cont = false;
                }
            }
        }
        private PluginData.Song ReadSongF(string path, string name)
        {
            PluginData.Song val = new PluginData.Song();
            val.Filename = name;
            val.Filepath = path;
            val.seconds = 0;
            List<PluginData.Track> tempTrack = new List<PluginData.Track>();
            using (StreamReader r = new StreamReader(path + name))
            {
                bool header = true;
                float L = 1;
                float Q = 0;
                PluginData.Track currentTrack;
                while (!r.EndOfStream)
                {
                    string line = r.ReadLine();
                    if (header)
                    {
                        if (line[0] == 'L')
                        {
                            int i = 1;
                            while (!(line[i] >= '0') && !(line[i] <= '9')) ++i;
                            string val1 = "", val2 = "";
                            while (line[i] >= '0' && line[i] <= '9')
                            {
                                val1 += line[i];
                                ++i;
                            }
                            if (line[i] == '/')
                            {
                                ++i;
                            }
                            while (line[i] >= '0' && line[i] <= '9')
                            {
                                val2 += line[i];
                                ++i;
                            }
                            L = int.Parse(val1) / int.Parse(val2);
                        }
                        else if (line[0] == 'Q')
                        {
                            List<int> vals = new List<int>();
                            for (int i = 1; i < line.Length; ++i)
                            {
                                string temp = "";
                                while (!(line[i] >= '0') && !(line[i] <= '9')) ++i;

                                while (line[i] >= '0' && line[i] <= '9')
                                {
                                    temp += line[i];
                                }
                                vals.Add(int.Parse(temp));
                            }
                            float modi = 0;
                            float bpm = 0;
                            for (int i = 0; i < vals.Count; ++i)
                            {
                                if (i + 1 == vals.Count)
                                {
                                    bpm = vals[i];
                                }
                                if (i % 2 == 0)
                                {
                                    modi += vals[i] / vals[i + 1];
                                    ++i;
                                }
                            }
                            if (modi != 0)
                            {
                                Q = bpm * modi;
                            }
                            else
                            {
                                Q = bpm;
                            }
                        }
                        else if (line[0] == 'K')
                        {
                            header = false;
                        }
                        else if (line[0] == 'T')
                        {
                            currentTrack.Name = line.Substring(2);
                        }
                        else if (line[0] == 'X')
                        {
                            currentTrack = new PluginData.Track();
                            currentTrack.Id = line.Substring(2);
                            currentTrack.Name = "";
                            tempTrack.Add(currentTrack);
                        }
                    }
                    else
                    {
                        if (line[0] == 'X')
                        {
                            header = true;
                            currentTrack = new PluginData.Track();
                            currentTrack.Id = line.Substring(2);
                            currentTrack.Name = "";
                            tempTrack.Add(currentTrack);
                        }
                        else
                        {
                            string val1 = "", val2 = "";
                            string[] vals = line.Split(' ');
                            for (int i = 0; i < vals.Length; ++i)
                            {
                                int e = 0;
                                bool chord = false;
                                if (vals[i][e] == '[')
                                {
                                    chord = true;
                                }
                                while (!(vals[i][e] >= '0') && !(vals[i][e] <= '9')) ++e;
                                if (vals[i][e - 1] == '/')
                                {
                                    val1 = "1";
                                }
                                else
                                {
                                    while (vals[i][e] >= '0' && vals[i][e] <= '9')
                                    {
                                        val1 += vals[i][e];
                                        ++e;
                                    }
                                }
                                while (!(vals[i][e] >= '0') && !(vals[i][e] <= '9')) ++e;
                                while (vals[i][e] >= '0' && vals[i][e] <= '9')
                                {
                                    val2 += vals[i][e];
                                    ++e;
                                }
                                val.seconds += (int)Math.Ceiling((int.Parse(val1) / int.Parse(val2)) * Q * L);
                                while (chord)
                                {
                                    if (vals[i][vals[i].Length - 1] == ']')
                                    {
                                        chord = false;
                                    }
                                    ++i;
                                }
                            }
                        }
                    }
                }
            }
            return val;
        }
        private void GetDirectories(string path, string root, ref List<string> outs)
        {
            outs.Add(path.Replace(root, "/"));
            string[] subs = Directory.GetDirectories(path);
            for (int i = 0; i < subs.Length; ++i)
            {
                GetDirectories(subs[i], root, ref outs);
            }
        }
        private bool CheckSongsD()
        {
            bool exist = true;
            string lotro = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments) + "/The Lord of the Rings Online";
            if (!Directory.Exists(lotro))
            {
                exist = false;
            }
            string music = lotro + "/Music";
            if (exist && !Directory.Exists(music))
            {
                exist = false;
            }
            return exist;
        }
        public void Write()
        {
            for (int i = 0; i < PInputs.Count; ++i)
            {
                PInputs[i].Write();
            }
        }
        public void WriteData()
        {
            PData.Write(account);
        }
        public class PluginInputs
        {
            public Input Inputs;
            public PluginInputs(string file)
            {
                int i = 0;
                while (i < file.Length)
                {
                    if (file[i] == '{')
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
            public void Write()
            {

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
                        if (label == "Inputs")
                        {
                            GetInputs(file, ref i);
                        }
                    }
                }
                ++i;
            }
            private void GetInputs(string file, ref int i)
            {
                Inputs = new Input();
                string label = "";
                List<Command> commands = new List<Command>();
                while (file[i] != '}')
                {
                    if (file[i++] == '\"')
                    {
                        label = GetWord(file, ref i);
                        if (label == "Commands")
                        {
                            while (file[i++] != '{') ;
                            while (file[i] != '}')
                            {
                                commands.Add(GetCommand(file, ref i));
                            }
                            ++i;
                        }
                        else
                        {
                            while (file[i++] != '\"') ;
                            if (label == "Id")
                            {
                                Inputs.Id = ushort.Parse(GetWord(file, ref i));
                            }
                            else if (label == "Timecode")
                            {
                                Inputs.Timecode = long.Parse(GetWord(file, ref i));
                            }
                            else if (label == "IsActive")
                            {
                                Inputs.IsActive = short.Parse(GetWord(file, ref i)) == 1;
                            }
                        }
                    }
                }
            }
            private Command GetCommand(string file, ref int i)
            {
                Command val = new Command();
                string label = "";
                while (file[i] != '}')
                {
                    if (file[i++] == '\"')
                    {
                        label = GetWord(file, ref i);
                        while (file[i++] != '\"') ;
                        if (label == "SentBy")
                        {
                            val.SentBy = GetWord(file, ref i);
                        }
                        else if (label == "CommandType")
                        {
                            val.CommandType = GetWord(file, ref i);
                        }
                        else if (label == "Details")
                        {
                            val.Details = GetWord(file, ref i);
                        }
                    }
                }
                return val;
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
            public struct Input
            {
                public ushort Id;
                public long Timecode;
                public bool IsActive;
                public Command[] Commands;
            }
            public struct Command
            {
                public string SentBy;
                public string CommandType;
                public string Details;
            }
        }
    }
}
