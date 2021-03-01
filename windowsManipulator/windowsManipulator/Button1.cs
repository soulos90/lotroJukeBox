using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace WindowsManipulator
{
    class Button1 : Button
    {
        public struct button
        {
            public int id;
            public string label;
            public button(int i, string l) { id = i; label = l; }
        }
        public static button[] Buttons = { new button(0, "Pause"), new button(1, "Rescan clients"), new button(2, "Sync local data"), new button(3, "Sync remote data") };
        public winMan man;
        public int id;
        public Button1(winMan win)
        {
            man = win;
            Click += clicked;
        }
        public void clicked(object sender, EventArgs e)
        {
            try
            {
                man.ButtonClicked(id);
            }
            catch (Exception ex)
            {
                man.form.Report(ex.Message);
                man.form.Report("error caught in button.clicked");
            }
        }
    }
}
