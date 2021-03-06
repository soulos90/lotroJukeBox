﻿using System;
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
        private static Semaphore OneAtATime;
        DateTime madeAt;
        private bool newSongs = false;
        public JukeBoxBackend()
        {
            madeAt = DateTime.Now;
            OneAtATime = new Semaphore(0, 1);
            OneAtATime.Release(1);
        }
        public botInstructions SyncLocal(int[] ids)
        {
            OneAtATime.WaitOne();
            botInstructions vals = new botInstructions();
            vals.clients = new client[ids.Length];
            ClientPluginData[] clients = new ClientPluginData[ids.Length];
            for (int i = 0; i < ids.Length; ++i)
            {
                vals.clients[i].id = ids[i];
                if (i == 0)
                {
                    readFromPlugin(ref clients[i].data, ref clients[i].settings, ids[i]);
                }
                else
                {
                    readFromPlugin(ref clients[i].data, ref clients[i].settings, ids[i], clients[0].data.PData);
                }
            }
            processData(ref vals, clients);
            //pull input from jukebox plugindata and send decisions to jukebox plugindata
            OneAtATime.Release();
            return vals;//vals is data that winmanip will use to perform actions on lotro clients
        }
        private void readFromPlugin(ref Data d, ref Settings s, int id)
        {
            d = new Data(id, madeAt);
            s = new Settings(id, d.account);
            newSongs = d.newSongs;
        }
        private void readFromPlugin(ref Data d, ref Settings s, int id, PluginData copy)
        {
            d = new Data(id, madeAt, copy);
            s = new Settings(id, d.account);
            newSongs = d.newSongs;
        }
        private void processData(ref botInstructions BI, ClientPluginData[] data)
        {
            //make choices here
            writeToPlugin(data);//change data with instructions for plugin
        }
        private void writeToPlugin(ClientPluginData[] data)
        {
            if (data[0].data.newSongs)
            {
                data[0].data.WriteData();
            }
            //write to files here
            for (int i = 0; i < data.Length; ++i)
            {
                data[i].data.Write();
            }
        }
        public void SyncRemote()
        {
            OneAtATime.WaitOne();
            //connect to raymionds server to make sure networked song data is syncced
            OneAtATime.Release();
        }
    }
}
