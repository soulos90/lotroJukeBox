# lotroJukeBox
JukeBox plugin for lotro and windows apps to support it. either JukeBoxSync for minimal use, or windowsManipulator for automated use.
3 different C# solutions and 1 lua plugin. 

JBSync and WinManip are two optional UI's that rely on JBSyncer.

JBSync just manages background threads that send timed calls to JBSyncer.

WinManip manages similar background threads and also takes data from JBSyncer and uses it to make actions on the lotro client windows.

JBSyncer checks to make sure remote database and local database are synced up. It also processes PluginData to get in game user inputs and makes decisions about what song to queue up next. It also sends PluginData into game to inform the Plugin what song to queue up and what songs are available for selection.

JukeBox plugin collects in game user inputs through chat messages, and writes inputs into PluginData. it also Reads inputs from PluginData and changes in game UI to streamline User interactions. It is based heavily on the SongBook plugin, and as such has much of the same functionality as SongBook.
