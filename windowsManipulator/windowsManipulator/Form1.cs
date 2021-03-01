using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using JukeBoxSyncer;

namespace WindowsManipulator
{
    public partial class Form1 : Form
    {
        public struct Client
        {
            public string label;
            public int id;
        }
        public winMan man;
        public List<Client> clients;
        public TextBox text;
        public List<Button> buttons = new List<Button>();
        private string report = "";
        private int width = 0;
        public bool pause = false;
        private Thread R, L;
        public Form1()
        {
            InitializeComponent();
            InitInterface();
            man = new winMan(this);
            StartThreads();
        }
        public void Resizer(object sender, System.EventArgs e)
        {
            text.Size = new Size(this.ClientSize.Width, this.ClientSize.Height - (this.ClientSize.Height / 3));
            int length = 0;
            for (int i = 0; i < buttons.Count; ++i)
            {
                buttons[i].Top = (5 * this.ClientSize.Height / 6) - (buttons[i].Height / 2);
                buttons[i].Left = (this.ClientSize.Width / 2) - (width / 2) + length;
                length += buttons[i].Width;
            }
        }
        public void InitInterface()
        {
            CreateMyTextBox();
            CreateButtons();
            Resize += Resizer;
            Width = width + 100;
            MinimumSize = new Size(width, (buttons[0].Height + 100));
        }
        public void CreateButtons()
        {

            for (int i = 0; i < Button1.Buttons.Length; ++i)
            {
                Button1 temp = new Button1(man);
                temp.Text = Button1.Buttons[i].label;
                temp.AutoSize = true;
                temp.DialogResult = DialogResult.OK;
                temp.Name = "Button" + Button1.Buttons[i].id;
                temp.id = Button1.Buttons[i].id;
                temp.Enabled = true;
                temp.Top = (5 * this.ClientSize.Height / 6) - (temp.Height / 2);
                if (i == 0) temp.Select();
                buttons.Add(temp);
                Controls.Add(temp);
                width += temp.Width;
            }
            int length = 0;
            for (int i = 0; i < buttons.Count; ++i)
            {
                buttons[i].Left = (this.ClientSize.Width / 2) - (width / 2) + length;
                length += buttons[i].Width;
            }
        }
        public void CreateMyTextBox()
        {
            // Create an instance of a Label.
            text = new TextBox();
            // Set the Multiline property to true.
            text.Multiline = true;
            // Add vertical scroll bars to the TextBox control.
            text.ScrollBars = ScrollBars.Vertical;

            // Set WordWrap to true to allow text to wrap to the next line.
            text.WordWrap = true;
            text.Enabled = true;
            text.ReadOnly = true;
            // Set the text of the control and specify a mnemonic character.
            text.Text = "Press a key on keyboard to target correct device\n";

            /* Set the size of the control based on the PreferredHeight and PreferredWidth values. */
            text.Size = new Size(this.ClientSize.Width, this.ClientSize.Height - (this.ClientSize.Height / 3));

            Controls.Add(text);
        }
        public void PopulateForm(List<lotroclient> newclients)
        {
            clients = new List<Client>();
            for (int i = 0; i < newclients.Count; ++i)
            {
                Client temp = new Client();
                temp.id = newclients[i].id;
                temp.label = "lotro client " + temp.id + " detected";
                clients.Add(temp);
            }
            Report("found " + clients.Count + " clients");
        }
        public void Report(string t)
        {
            report += t + "\r\n";
            if (text.InvokeRequired)
            {
                text.BeginInvoke((MethodInvoker)delegate {
                    UpdateText(report);
                });
            }
            else
            {
                UpdateText();
            }
        }
        public void UpdateText()
        {
            text.Text = "";
            foreach (Client item in clients)
            {
                text.Text += item.label + "\r\n";
            }
            text.Text += report;
        }
        public void UpdateText(string r)
        {
            text.Text = "";
            foreach (Client item in clients)
            {
                text.Text += item.label + "\r\n";
            }
            text.Text += r;
        }
        public void setText(int id, string text)
        {
            Client temp = clients.Find(f => f.id == id);
            temp.label = text;
            UpdateText();
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
                Report(e.Message);
            }
        }
        public bool abort = false;
        public void NetThread()
        {
            while (!abort)
            {
                if (!pause)
                {
                    //man.SyncR();
                    Report("net Thread Called");
                    Thread.Sleep(60000);
                }
            }
        }
        public void LocalThread()
        {
            while (!abort)
            {
                if (!pause)
                {
                    man.ManageLocal();
                    Report("local Thread Called");
                    Thread.Sleep(10000);
                }
            }
        }
    }
}
