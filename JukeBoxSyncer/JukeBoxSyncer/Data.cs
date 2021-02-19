using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Runtime;

namespace JukeBoxSyncer
{
    
    public class Data
    {
        public int id;
        public bool found = false;
        public string account;
        public DateTime SyncTime;
        public Data(int i, DateTime at)
        {
            String lotro = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments) + "/The Lord of the Rings Online";
            id = i;
            SyncTime = at;
            if(!Directory.Exists(lotro))
            {
                Directory.CreateDirectory(lotro);
            }
        }
    }
}
