JukeboxBackground = class( Turbine.UI.Window );
import "Turbine";
import "Nathan.JukeBox.VindarPatch";
earoFormat=(tonumber("1,000")==1); 
inputID = 0;
clientID = -1;
timeCode = 0;
LookingFor = 0;
SaveDone = false;
LoadDone = false;
TimeToLoadSongs = false;


InputDB = {
    Id = clientID,
    Timecode = timeCode,
    IsActive = true,
    LookingFor = LookingFor,
    Commands = {
    }
};
SyncDB = {
    Commands = {
    }
};

function JukeboxBackground:Constructor()
	Turbine.UI.Lotro.Window.Constructor( self );
    previousGameTime = Turbine.Engine.GetGameTime();
    self.UnloadSet = false;
    self:SetWantsUpdates(true);
    Turbine.Shell.WriteLine("Hi Im background constructor");
end

function JukeboxBackground:UnloadMe()
    Turbine.Shell.WriteLine("Hi Im unload");
	InputDB.IsActive = false;
    RemoveCallback(Turbine.Chat, "Received", ChatListener);
    local a = Turbine.DataScope.Account;
    local b = "JukeBoxInput" .. inputID;
    local c = InputDB;
    local d = FinishedInputSave(result, message);
	PatchDataSave( a,b,c,d );
end

function JukeboxBackground:Update()
	if not self.UnloadSet then
		self.UnloadSet = true;
        Turbine.Shell.WriteLine("Hi Im init update");
        AddCallback(Turbine.Chat, "Received", ChatListener);
		Plugins["Jukebox"].Unload = function(self,sender,args)
            JukeboxBackground:UnloadMe();
        end
	end
	local currentGameTime = Turbine.Engine.GetGameTime();
	local delta = currentGameTime - previousGameTime;
	if( delta > 10 ) then
        Turbine.Shell.WriteLine("Hi Im calling communicate");
		JukeboxBackground:SetWantsUpdates(false);
		Communicate();
	end
end

ChatListener = function(sender, args)
	if (args.ChatType==Turbine.ChatType.Say) or (args.ChatType==Turbine.ChatType.Tell) or (args.ChatType==Turbine.ChatType.Fellowship) or (args.ChatType==Turbine.ChatType.Raid) then
		commandText = {};
		numCommands = 1;
        Turbine.Shell.WriteLine("chat was read");
		CBegin, CEnd = string.find(args.Message,"!JB(.-)");
		while(CBegin~=nill) do
			commandText[numCommands] = string.sub(args.Message, CBegin, CEnd);
			CBegin, Cend = string.find(args.Message,"!JB .+ JB!", CEnd);
			numCommands = numCommands + 1;
		end
        for i,v in ipairs(commandText) do
            Turbine.Shell.WriteLine(v);
        end
	end
end

function Communicate()
    Turbine.Shell.WriteLine("Hi Im Communicate");
	SaveDone = false;
	LoadDone = false;
	PatchDataLoad( Turbine.DataScope.Account, "JukeBoxSync" .. LookingFor, FinishedSyncLoad(result, message));
	PatchDataSave( Turbine.DataScope.Account, "JukeBoxInput" .. inputID, InputDB, FinishedInputSave(result, message));
	inputID = (inputID + 1) % 1000;
end

function FinishedSyncLoad(result, message)
    Turbine.Shell.WriteLine("Hi Im FinishedSyncLoad");
	if ( result ) then
        Turbine.Shell.WriteLine("Hi Im FinishedSyncLoad with true result");
		Turbine.Shell.WriteLine( "<rgb=#00FF00>" .. Strings["loaded "] .. message .. "</rgb>");
		if IsTidy(message) then
			ProcessSync(message);
			LookingFor = (LookingFor + 1) % 1000;
			InputDB.LookingFor = LookingFor;
			PatchDataLoad( Turbine.DataScope.Account, "JukeBoxSync" .. LookingFor, FinishedSyncLoad(result, message));
		else
			FinishedCommunicate(2);
        end
	else
		Turbine.Shell.WriteLine( "<rgb=#FF0000>" .. Strings["sync not found"] .. " " .. message .. "</rgb>" );
		FinishedCommunicate(2);
	end
end

function FinishedInputSave(result, message)
	if ( result ) then
		Turbine.Shell.WriteLine( "<rgb=#00FF00> input saved </rgb>");
	else
		Turbine.Shell.WriteLine( "<rgb=#FF0000> input not saved</rgb>" );
	end
	FinishedCommunicate(1);
end

function FinishedCommunicate(sender)
	if(sender == 1) then
		SaveDone = true;
	else
		LoadDone = true;
	end
	if(SaveDone and LoadDone) then
		previousGameTime = Turbine.Engine.GetGameTime();
		Self:SetWantsUpdates(true);
		if(TimeToLoadSongs) then
			LoadSongs();
		end
	end
end

function FinishedSongLoad(result, message)
    if(result) then
        SongDB = result;
    end
    if not SongDB.Songs then
        SongDB = {
            Directories = {
            },
            Songs = {	
            }
        };
    end	
    librarySize = SongDB.Songs;
    JukeboxWindow:SetDB(SongDB);
end

function ProcessSync(data)
	SyncDB = data;
	if(data.LoadSongs) then
		TimeToLoadSongs = true;
	end
	for i,v in ipairs(SyncDB.Commands) do 
        CommandSwitch(v); 
    end
end

function LoadSongs()
    PatchDataLoad( Turbine.DataScope.Account , "JukeBoxData", FinishedSongLoad);
    Turbine.Shell.WriteLine("LoadSongs");
end

function CommandSwitch(command)
	
end

function IsTidy(data)
	--TODO: check if file is complete
	return true;
end

function AddCallback(object, event, callback)
    if (object[event] == nil) then
        object[event] = callback;
    else
        if (type(object[event]) == "table") then
            table.insert(object[event], callback);
        else
            object[event] = {object[event], callback};
        end
    end
    return callback;
end

function RemoveCallback(object, event, callback)
    if (object[event] == callback) then
        object[event] = nil;
    else
        if (type(object[event]) == "table") then
            local size = table.getn(object[event]);
            for i = 1, size do
                if (object[event][i] == callback) then
                    table.remove(object[event], i);
                    break;
                end
            end
        end
    end
end

function NumCleaner(num)
    if euroFormat then
        function euroNormalize(value)
            return tonumber((string.gsub(value,"%.",",")));
        end
    else
        function euroNormalize(value)
            return tonumber((string.gsub(value,",",".")));
        end
    end
end