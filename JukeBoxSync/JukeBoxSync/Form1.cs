using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Threading;
using JukeBoxSyncer;

namespace JukeBoxSync
{
    public partial class Form1 : Form
    {
        private System.Windows.Forms.ContextMenu contextMenu1;
        private System.Windows.Forms.MenuItem menuItem1;
        private System.Windows.Forms.MenuItem menuItem2;
        private System.Windows.Forms.MenuItem menuItem3;
        private System.Windows.Forms.MenuItem menuItem4;
        public JukeBoxBackend syncer = new JukeBoxBackend();
        private Thread R, L;
        public bool abort = false;
        public bool pause = false;
        public Form1()
        {
            InitializeComponent();
            contextMenu1 = new ContextMenu();
            menuItem1 = new MenuItem();
            menuItem2 = new MenuItem();
            menuItem3 = new MenuItem();
            menuItem4 = new MenuItem();
            contextMenu1.MenuItems.AddRange(new MenuItem[] { menuItem1, menuItem2, menuItem3, menuItem4,});
            menuItem1.Index = 0;
            menuItem1.Text = "Exit";
            menuItem1.Click += new EventHandler(menuItem1_Click);
            menuItem2.Index = 1;
            menuItem2.Text = "Pause";
            menuItem2.Click += new EventHandler(menuItem2_Click);
            menuItem3.Index = 2;
            menuItem3.Text = "Sync Local";
            menuItem3.Click += new EventHandler(menuItem3_Click);
            menuItem4.Index = 3;
            menuItem4.Text = "Sync Remote";
            menuItem4.Click += new EventHandler(menuItem4_Click);
            notifyIcon1.ContextMenu = contextMenu1;
            Load += resized;
            Resize += resized;
            WindowState = FormWindowState.Minimized;
            StartThreads();
        }
        public void resized(object sender, EventArgs e)
        {
            Hide();
        }
        private void menuItem1_Click(object Sender, EventArgs e)
        {
            // Close the form, which closes the application.
            Close();
        }
        private void menuItem2_Click(object Sender, EventArgs e)
        {
            Pause();
        }
        public void Pause()
        {
            pause = !pause;
            if ((R.ThreadState == ThreadState.Running || R.ThreadState == ThreadState.WaitSleepJoin) && (L.ThreadState == ThreadState.Running || L.ThreadState == ThreadState.WaitSleepJoin))
            {
                Closer(null, null);
            }
            else
            {
                StartThreads();
            }
        }
        private void menuItem3_Click(object Sender, EventArgs e)
        {
            SyncL();
        }
        private void menuItem4_Click(object Sender, EventArgs e)
        {
            SyncR();
        }
        public void Closer(object sender, CancelEventArgs e)
        {
            abort = true;
            L.Abort();
            R.Abort();
        }
        public void StartThreads()
        {
            try
            {
                abort = false;
                R = new Thread(NetThread);
                L = new Thread(LocalThread);
                R.Start();
                L.Start();
                Closing += Closer;
            }
            catch (Exception e)
            {
            }
        }
        public void NetThread()
        {
            //do stuff here to connect to server and sync music data then wait 1 min and do it again
            while (!abort)
            {
                if (!pause)
                {
                    SyncR();
                    Thread.Sleep(60000);
                }
            }
        }
        public void LocalThread()
        {
            //do stuff here to connect to server and sync music data then wait 10 seconds and do it again
            while (!abort)
            {
                if (!pause)
                {
                    SyncL();
                    Thread.Sleep(10000);
                }
            }
        }
        public void SyncL()
        {
            syncer.SyncLocal();
        }
        public void SyncR()
        {
            syncer.SyncRemote();
        }
    }
}
