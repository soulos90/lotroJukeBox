using System;
using System.Threading;

namespace JukeBoxSyncer
{
    public struct ClientPluginData
    {
        public Data data;
        public Settings settings;
    }
    public struct botInstructions
    {
        public client[] clients;
    }
    public struct client
    {
        public int id;
        public string character;

    }
    public class JukeBoxBackend
    {
        private static Semaphore LocalSem;
        private static Semaphore RemoteSem;
        DateTime madeAt;
        public JukeBoxBackend()
        {
            madeAt = DateTime.Now;
            LocalSem = new Semaphore(0, 1);
            LocalSem.Release(1);
            RemoteSem = new Semaphore(0, 1);
            RemoteSem.Release(1);
        }
        public botInstructions SyncLocal(int[] ids)
        {
            LocalSem.WaitOne();
            botInstructions vals = new botInstructions();
            vals.clients = new client[ids.Length];
            ClientPluginData[] clients = new ClientPluginData[ids.Length];
            for (int i = 0; i < ids.Length; ++i)
            {
                vals.clients[i].id = ids[i];
                readFromPlugin(ref clients[i].data, ref clients[i].settings, ids[i]);
            }
            processData(ref vals, clients);
            //pull input from jukebox plugindata and send decisions to jukebox plugindata
            LocalSem.Release();
            return vals;//vals is data that winmanip will use to perform actions on lotro clients
        }
        private void readFromPlugin(ref Data d, ref Settings s, int id)
        {
            d = new Data(id, madeAt);
            s = new Settings(id, d.account);
        }
        private void processData(ref botInstructions BI, ClientPluginData[] data)
        {
            //make choices here
            writeToPlugin(data);//change data with instructions for plugin
        }
        private void writeToPlugin(ClientPluginData[] data)
        {
            //write to files here
            for(int i = 0; i < data.Length; ++i)
            {
                data[i].data.Write();
            }
        }
        public void SyncRemote()
        {
            RemoteSem.WaitOne();
            //connect to raymionds server to make sure networked song data is syncced
            RemoteSem.Release();
        }
    }
}
