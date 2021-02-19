using System;
using System.Drawing;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using System.Diagnostics;

namespace windowsManipulator
{
    public static class Program
    {

        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        public static Form1 form;
        public static winMan man;
        
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            form = new Form1();
            man = new winMan(form);
            Application.Run(form);
        }
    }
}
