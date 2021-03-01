using System;
using System.Runtime;
using System.Drawing;
using System.Threading;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Diagnostics;
using WindowsInput;
using JukeBoxSyncer;

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
        [DllImport("user32.dll")]
        static extern int SetWindowText(IntPtr hWnd, string text);

        [DllImport("user32.dll")]
        public static extern bool GetWindowRect(IntPtr hwnd, ref Rect rectangle);

        [DllImport("user32.dll")]
        public static extern IntPtr WindowFromPoint(Point lpPoint);

        public JukeBoxBackend syncer = new JukeBoxBackend();
        InputSimulator input = new InputSimulator();
        List<lotroclient> t = null;
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
                try
                {
                    form.Report("rect of " + temp.id + " " + temp.rect.Left);
                }
                catch (Exception e) { }
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
            int x = chosen.rect.Right - ((chosen.rect.Right - chosen.rect.Left) / 2), y = chosen.rect.Bottom - ((chosen.rect.Bottom - chosen.rect.Top) / 2);
            int count = 1;
            bool visible = true;
            while (WindowFromPoint(new Point(x, y)) != chosen.proc.MainWindowHandle)
            {
                input.Keyboard.KeyDown(WindowsInput.Native.VirtualKeyCode.MENU);
                for (int i = 0; i < count; ++i)
                {
                    input.Keyboard.KeyPress(WindowsInput.Native.VirtualKeyCode.TAB);
                }
                input.Keyboard.KeyUp(WindowsInput.Native.VirtualKeyCode.MENU);
                ++count;
                if (count > 15)
                {
                    visible = false;
                    break;
                }
                Thread.Sleep(200);
            }
            if (visible)
            {
                input.Mouse.MoveMouseTo(x, y);
                input.Mouse.LeftButtonClick();
                Thread.Sleep(100);
                input.Keyboard.KeyPress(WindowsInput.Native.VirtualKeyCode.VK_K);
            }
            else
            {
                form.setText(chosen.id, "cant see lotro client " + chosen.id);
            }
        }

    }
}
