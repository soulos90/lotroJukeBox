using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Runtime;

namespace JukeBoxSyncer
{
    public class Settings
    {
        public int id;
        public string account;
        public Settings(int i, string a)
        {
            id = i;
            account = a;
        }
    }
}
