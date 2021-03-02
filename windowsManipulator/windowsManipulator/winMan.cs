using System;
using System.Drawing;
using System.Threading;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Diagnostics;
using JukeBoxSyncer;
using WindowsInput;

namespace WindowsManipulator
{
    public struct Rect
    {
        public int Left { get; set; }
        public int Top { get; set; }
        public int Right { get; set; }
        public int Bottom { get; set; }
    }
    public struct lotroclient
    {
        public Process proc;

        public Rect rect;
        public int id;
    }
    
    public class winMan
    {
        private enum ShowWindowEnum
        {
            Hide = 0,
            ShowNormal = 1, ShowMinimized = 2, ShowMaximized = 3,
            Maximize = 3, ShowNormalNoActivate = 4, Show = 5,
            Minimize = 6, ShowMinNoActivate = 7, ShowNoActivate = 8,
            Restore = 9, ShowDefault = 10, ForceMinimized = 11
        };
        [DllImport("user32.dll")]
        static extern int SetWindowText(IntPtr hWnd, string text);
        [DllImport("user32.dll")]
        static extern bool GetWindowRect(IntPtr hwnd, ref Rect rectangle);
        [DllImport("user32.dll")]
        static extern IntPtr WindowFromPoint(Point lpPoint);
        [DllImport("user32")]
        static extern int SetCursorPos(int x, int y);
        [DllImport("user32.dll")]
        static extern int SetForegroundWindow(IntPtr hwnd);
        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool ShowWindow(IntPtr hWnd, ShowWindowEnum flags);

        private InputSimulator input = new InputSimulator();
        public JukeBoxBackend syncer = new JukeBoxBackend();
        public List<lotroclient> t = null;
        public Form1 form;
        public winMan(Form1 f)
        {
            form = f;
            ScanC();
        }
        public void ButtonClicked(int id)
        {
            switch (id)
            {
                case 0:
                    form.Pause();
                    form.Report("called pause");
                    break;
                case 1:
                    ScanC();
                    form.Report("called ScanC");
                    break;
                case 2:
                    ManageLocal();
                    form.Report("called SyncL");
                    break;
                case 3:
                    SyncR();
                    form.Report("called SyncR");
                    break;
            }
        }
        public void ScanC()
        {
            int numClients = 0;
            Process[] tl = Process.GetProcessesByName("lotroclient64");
            t = new List<lotroclient>();
            foreach (Process item in tl)
            {
                lotroclient temp = new lotroclient();
                temp.proc = item;
                temp.id = numClients++;
                Rect tempRect = new Rect();
                GetWindowRect(item.MainWindowHandle, ref tempRect);
                temp.rect = tempRect;
                SetWindowText(item.MainWindowHandle, "lotro " + temp.id);
                form.Report("rect of " + temp.id + " " + temp.rect.Left);
                
                t.Add(temp);
            }
            form.PopulateForm(t);
        }
        public void ManageLocal()
        {
            botInstructions active = SyncL();
            
            //execute actions on lotro clients to automatically run plugin
        }
        public botInstructions SyncL()
        {
            int[] clients = new int[t.Count];
            for (int i = 0; i < t.Count; ++i)
            {
                clients[i] = t[i].id;
            }
            if(clients.Length > 0)
            {
                return syncer.SyncLocal(clients);
            }
            else
            {
                return new botInstructions();
            }
        }
        public void SyncR()
        {
            syncer.SyncRemote();
        }
        public void SetFocus(lotroclient chosen)
        {
            if(chosen.proc != null)
            {
                if(chosen.proc.MainWindowHandle == IntPtr.Zero)
                {
                    ShowWindow(chosen.proc.Handle, ShowWindowEnum.Restore);
                }
                SetForegroundWindow(chosen.proc.MainWindowHandle);
            }
            
            int x = chosen.rect.Right - ((chosen.rect.Right - chosen.rect.Left) / 2), y = chosen.rect.Bottom - ((chosen.rect.Bottom - chosen.rect.Top) / 2);
            int count = 1;
            bool visible = true;
            while (WindowFromPoint(new Point(x, y)) != chosen.proc.MainWindowHandle)
            {
                input.Keyboard.KeyDown(WindowsInput.Native.VirtualKeyCode.MENU);
                Thread.Sleep(1);
                for (int i = 0; i < count; ++i)
                {
                    input.Keyboard.KeyPress(WindowsInput.Native.VirtualKeyCode.TAB);
                    Thread.Sleep(1);
                }
                input.Keyboard.KeyUp(WindowsInput.Native.VirtualKeyCode.MENU);
                Thread.Sleep(1);
                ++count;
                if (count > 15)
                {
                    visible = false;
                    break;
                }
                Thread.Sleep(1000);
            }
            if (visible)
            {
                SetCursorPos(x, y);
                //input.Mouse.LeftButtonClick();
                Thread.Sleep(100);
                //input.Keyboard.KeyPress(WindowsInput.Native.VirtualKeyCode.VK_K);
            }
            else
            {
                form.setText(chosen.id, "cant see lotro client " + chosen.id);
            }
        }

    }
}
