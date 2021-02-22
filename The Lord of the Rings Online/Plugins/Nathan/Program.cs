using System;
using System.IO;
using System.Windows;
using System.Diagnostics;
using System.ComponentModel;
using System.Runtime.InteropServices;

namespace Nathan
{
    class Program
    {
        [DllImport ("User32.dll")]
        static extern int SetForegroundWindow(IntPtr point);
        public StreamWriter standardinput;
        
        
        static void Main(string[] args)
        {
            Process p = Process.GetProcessesByName("notepad")[0];
            if (p != null)
            {
                IntPtr h = p.MainWindowHandle;
                SetForegroundWindow(h);
            }
        }
    }
}