JukeboxWindow = class( Turbine.UI.Window );
selectedSong = ""; -- set the default slot
selectedSongIndex = 1;
selectedTrack = 1;
songIndexMod = 0; -- needed to find out the actual db index of selected song
selectedDir = "/"; -- set the default dir
dirPath = {}; -- table holding directory path
dirPath[1] = "/"; -- set first item as root dir
librarySize = 0;
searchMode = false;
-- fix to prevent Vindar patch from messing up anything since it's not needed
JukeboxLoad = Turbine.PluginData.Load;
JukeboxSave = Turbine.PluginData.Save;

Settings = { WindowPosition = { Left = "700", Top = "20", Width = "342", Height = "398" }, WindowVisible = "no", WindowOpacity="0.9", DirHeight = "100", TracksHeight = "50", TracksVisible = "no", ToggleVisible = "yes", ToggleLeft = "100", ToggleTop = "100", ToggleOpacity = "1", SearchVisible = "yes", DescriptionVisible = "no", DescriptionFirst = "no" }; -- default values
CharSettings = {
};

-- if (lang == "de" or lang == "fr") then	
	-- if (Turbine.Engine.GetLocale() == "de" or Turbine.Engine.GetLocale() == "fr") then
		-- Settings.WindowOpacity = "0,9";
	-- end
-- end
euroFormat=(tonumber("1,000")==1);
if euroFormat then
	Settings.WindowOpacity = "0,9";
	Settings.ToggleOpacity = "0,25";
end

SongDB = {
	Directories = {
	},
	Songs = {	
	}
};
SearchDB = {
};


function JukeboxWindow:Constructor()
	Turbine.UI.Lotro.Window.Constructor( self );
	
	Background = Nathan.Jukebox.JukeboxBackground();
	Background:SetVisible( false );

	SongDB = JukeboxLoad( Turbine.DataScope.Account , "JukeboxData") or SongDB;
	Settings = JukeboxLoad( Turbine.DataScope.Account , "JukeboxSettings") or Settings;
	CharSettings = JukeboxLoad( Turbine.DataScope.Character , "JukeboxSettings") or CharSettings;
	
	-- Legacy fixes
	if not Settings.DirHeight then
		Settings.DirHeight = "100";
	end
	if not Settings.TracksHeight then
		Settings.TracksHeight = "40";
	end
	if not Settings.TracksVisible then
		Settings.TracksVisible = "no";
	end
	if not WindowVisible then
		WindowVisible = "no";
	end	
	if not Settings.SearchVisible then
		Settings.SearchVisible = "yes";	
	end
	if not Settings.DescriptionVisible then
		Settings.DescriptionVisible = "no";	
	end
	if not Settings.DescriptionFirst then
		Settings.DescriptionFirst = "no";	
	end
	
	if not Settings.ToggleOpacity then
		Settings.ToggleOpacity = 1/4;
	end		
 	
	if not SongDB.Songs then
		SongDB = {
			Directories = {
			},
			Songs = {	
			}
		};
	end		
	
	if not Settings.Commands then
		Settings.Commands = {};		
		Settings.Commands["1"] = { Title = Strings["cmd_demo1_title"], Command = Strings["cmd_demo1_cmd"] };
		Settings.Commands["2"] = { Title = Strings["cmd_demo2_title"], Command = Strings["cmd_demo2_cmd"] };
		Settings.Commands["3"] = { Title = Strings["cmd_demo3_title"], Command = Strings["cmd_demo3_cmd"] };
		Settings.DefaultCommand = "1";
	end
	
	if not CharSettings.InstrSlots then
		CharSettings.InstrSlots = {};
		CharSettings.InstrSlots["visible"] = "yes";
		CharSettings.InstrSlots["number"] = 8;
		for i = 1, CharSettings.InstrSlots["number"] do
			CharSettings.InstrSlots[tostring(i)] = { qsType = "", qsData = "" };		
		end
	end
	if not CharSettings.InstrSlots["number"] then
		CharSettings.InstrSlots["number"] = 8;
	end
	for i = 1, CharSettings.InstrSlots["number"] do
		CharSettings.InstrSlots[tostring(i)].qsType = tonumber(CharSettings.InstrSlots[tostring(i)].qsType);
	end		
	
	-- unstringify settings
	Settings.WindowPosition.Left = tonumber(Settings.WindowPosition.Left);
	Settings.WindowPosition.Top = tonumber(Settings.WindowPosition.Top);
	Settings.WindowPosition.Width = tonumber(Settings.WindowPosition.Width);
	Settings.WindowPosition.Height = tonumber(Settings.WindowPosition.Height);
	Settings.ToggleTop = tonumber(Settings.ToggleTop);
	Settings.ToggleLeft = tonumber(Settings.ToggleLeft);
	Settings.DirHeight = tonumber(Settings.DirHeight);
	Settings.TracksHeight = tonumber(Settings.TracksHeight);
	Settings.WindowOpacity = tonumber(Settings.WindowOpacity);
	Settings.ToggleOpacity = tonumber(Settings.ToggleOpacity);
	CharSettings.InstrSlots["number"] = tonumber(CharSettings.InstrSlots["number"]);
	
	-- Fix to prevent window or toggle to travel outside of the screen
	local displayWidth, displayHeight = Turbine.UI.Display.GetSize();
	if Settings.WindowPosition.Left + Settings.WindowPosition.Width > displayWidth then
		Settings.WindowPosition.Left = displayWidth - Settings.WindowPosition.Width;
	end
	if Settings.WindowPosition.Top + Settings.WindowPosition.Height > displayHeight then
		Settings.WindowPosition.Top = displayHeight - Settings.WindowPosition.Height;
	end
	if Settings.WindowPosition.Left < 0 then
		Settings.WindowPosition.Left = 0;
	end
	if Settings.WindowPosition.Top < 0 then
		Settings.WindowPosition.Top = 0;
	end	
	if Settings.ToggleLeft + 35 > displayWidth then
		Settings.ToggleLeft = displayWidth - 35;
	end
	if Settings.ToggleTop + 35 > displayHeight then
		Settings.ToggleTop = displayHeight - 35;
	end
	if Settings.ToggleLeft < 0 then
		Settings.ToggleLeft = 0;
	end
	if Settings.ToggleTop < 0 then
		Settings.ToggleTop = 0;
	end
	
	
	-- Hide UI when F12 is pressed
	local hideUI = false;
	local wasVisible;
	self:SetWantsKeyEvents(true);
	self.KeyDown = function(sender, args)
		if (args.Action == 268435635) then
			if not hideUI then
				hideUI = true;
				if self:IsVisible() then
					wasVisible = true;
					self:SetVisible(false);					
				else
					wasVisible = false;
				end
				settingsWindow:SetVisible(false);
				toggleWindow:SetVisible(false);
			else
				hideUI = false;
				if wasVisible then
					self:SetVisible(true);
					settingsWindow:SetVisible(false);					
				end
				if (Settings.ToggleVisible == "yes") then
					toggleWindow:SetVisible(true);
				end
			end
		end
	end
	
	librarySize = #SongDB.Songs;
	
	self:SetPosition( Settings.WindowPosition.Left, Settings.WindowPosition.Top );
	self:SetSize( Settings.WindowPosition.Width, Settings.WindowPosition.Height );
	--self:SetZOrder(10);
	
	self:SetOpacity( Settings.WindowOpacity );
	self:SetText("Jukebox");
	
	self.minWidth = 342;
	self.minHeight = 308;
	self.lFXmod = 23; -- listFrame x coord modifier
	self.lCXmod = 42; -- listContainer x coord modifier

	if (CharSettings.InstrSlots["visible"] == "yes") then
		self.lFYmod = 214; -- listFrame y coord modifier = difference between bottom pixels and window bottom
		self.lCYmod = 233; -- listContainer y coord modifier = difference between bottom pixels and window bottom
	else
		self.lFYmod = 169; -- listFrame y coord modifier = difference between bottom pixels and window bottom
		self.lCYmod = 188; -- listContainer y coord modifier = difference between bottom pixels and window bottom
	end
	
	-- Frame for the song list
	self.listFrame = Turbine.UI.Control();
	self.listFrame:SetParent( self );
	self.listFrame:SetBackColor( Turbine.UI.Color(1, 0.15, 0.15, 0.15) );
	self.listFrame:SetPosition(12, 134);
	self.listFrame:SetSize(self:GetWidth() - self.lFXmod, self:GetHeight() - self.lFYmod);
	self.listContainer = Turbine.UI.Control();
	self.listContainer:SetParent( self );
	self.listContainer:SetBackColor( Turbine.UI.Color(1,0,0,0) );
	self.listContainer:SetPosition(18, 147);
	self.listContainer:SetSize(self:GetWidth() - self.lCXmod, self:GetHeight() - self.lCYmod);
	
	-- outer frame title
	self.listFrame.heading = Turbine.UI.Label();
	self.listFrame.heading:SetParent( self.listFrame );
	self.listFrame.heading:SetLeft(5);
	self.listFrame.heading:SetSize(self.listFrame:GetWidth(),13);
	self.listFrame.heading:SetFont( Turbine.UI.Lotro.Font.TrajanPro13 );
	self.listFrame.heading:SetText( Strings["ui_dirs"] );
	
	-- separator1 between dir list and song list
	self.separator1 = Turbine.UI.Control();
	self.separator1:SetParent( self.listContainer );
	self.separator1:SetZOrder(300);
	self.separator1:SetBackColor( Turbine.UI.Color(1, 0.15, 0.15, 0.15) );
	self.separator1:SetTop( Settings.DirHeight );
	self.separator1:SetSize(self.listContainer:GetWidth(), 13);

	-- separator1 title
	self.separator1.heading = Turbine.UI.Label();
	self.separator1.heading:SetParent( self.separator1 );
	self.separator1.heading:SetLeft(0);
	self.separator1.heading:SetSize(100,13);
	self.separator1.heading:SetFont( Turbine.UI.Lotro.Font.TrajanPro13 );
	self.separator1.heading:SetText( Strings["ui_songs"] );
	self.separator1.heading:SetMouseVisible( false );		
	
	-- separator1 hint arrows
	self.sArrows1 = Turbine.UI.Control();
	self.sArrows1:SetParent( self.separator1 );
	self.sArrows1:SetZOrder(310);
	self.sArrows1:SetBackground("Nathan/Jukebox/arrows.tga");
	self.sArrows1:SetSize(20,10);
	self.sArrows1:SetPosition(self.separator1:GetWidth() / 2 - 10, 1);
	self.sArrows1:SetMouseVisible( false );
	
	-- separator2 between song list and track list
	self.separator2 = Turbine.UI.Control();
	self.separator2:SetParent( self.listContainer );
	self.separator2:SetZOrder(300);
	self.separator2:SetBackColor( Turbine.UI.Color(1, 0.15, 0.15, 0.15) );
	self.separator2:SetTop( self.listContainer:GetHeight() - Settings.TracksHeight - 13);
	self.separator2:SetSize( self.listContainer:GetWidth(), 13);
	self.separator2:SetVisible( false );
	
	-- separator2 title
	self.separator2.heading = Turbine.UI.Label();
	self.separator2.heading:SetParent( self.separator2 );
	self.separator2.heading:SetLeft(0);
	self.separator2.heading:SetSize(100,13);	
	self.separator2.heading:SetFont( Turbine.UI.Lotro.Font.TrajanPro13 );
	self.separator2.heading:SetText( Strings["ui_parts"] );
	self.separator2.heading:SetMouseVisible( false );	

	-- separator2 hint arrows
	self.sArrows2 = Turbine.UI.Control();
	self.sArrows2:SetParent( self.separator2 );
	self.sArrows2:SetZOrder(310);
	self.sArrows2:SetBackground("Nathan/Jukebox/arrows.tga");
	self.sArrows2:SetSize(20,10);
	self.sArrows2:SetPosition(self.separator2:GetWidth() / 2 - 10, 1);
	self.sArrows2:SetMouseVisible( false );
	self.sArrows2:SetVisible( false );
	
	-- Tooltip
	self.tipLabel = Turbine.UI.Label();
	self.tipLabel:SetParent( self );
	self.tipLabel:SetPosition( self:GetWidth() - 270, 27 );
	self.tipLabel:SetSize(245, 30);
	self.tipLabel:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleRight );
	self.tipLabel:SetText("");
	
	-- Music mode button
	self.musicSlot = Turbine.UI.Lotro.Quickslot();
	self.musicSlot:SetParent( self );
	self.musicSlot:SetPosition(20, 50);
	self.musicSlot:SetSize(32, 30);
	self.musicSlot:SetZOrder(100);
	self.musicSlot:SetAllowDrop(false);
	self.musicSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_music"]));
	self.musicSlot:SetVisible( true );
	
	-- Play button
	self.playSlot = Turbine.UI.Lotro.Quickslot();
	self.playSlot:SetParent( self );
	self.playSlot:SetPosition(60, 50);
	self.playSlot:SetVisible( true );
	self.playSlot:SetSize(32, 30);
	self.playSlot:SetZOrder(100);
	self.playSlot:SetAllowDrop(false);
	
	-- Ready check button
	self.readySlot = Turbine.UI.Lotro.Quickslot();
	self.readySlot:SetParent( self );
	self.readySlot:SetPosition(120, 50);
	self.readySlot:SetSize(32, 30);
	self.readySlot:SetZOrder(100);
	self.readySlot:SetAllowDrop(false);
	self.readySlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_ready"]));
	self.readySlot:SetVisible( true );
	
	-- Sync play button
	self.syncSlot = Turbine.UI.Lotro.Quickslot();
	self.syncSlot:SetParent( self );
	self.syncSlot:SetPosition(161, 50);
	self.syncSlot:SetVisible( true );
	self.syncSlot:SetSize(32, 30);
	self.syncSlot:SetZOrder(100);
	self.syncSlot:SetAllowDrop(false);
	
	-- Start sync play button
	self.syncStartSlot = Turbine.UI.Lotro.Quickslot();
	self.syncStartSlot:SetParent( self );
	self.syncStartSlot:SetPosition(202, 50);
	self.syncStartSlot:SetSize(32, 30);
	self.syncStartSlot:SetZOrder(100);
	self.syncStartSlot:SetAllowDrop(false);
	self.syncStartSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_start"]));
	self.syncStartSlot:SetVisible( true );
	
	-- Share button
	self.shareSlot = Turbine.UI.Lotro.Quickslot();
	self.shareSlot:SetParent( self );
	self.shareSlot:SetPosition(287, 50);
	self.shareSlot:SetSize(32, 30);
	self.shareSlot:SetZOrder(100);
	self.shareSlot:SetAllowDrop(false);
	if (Settings.Commands[Settings.DefaultCommand]) then
		self.shareSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, self:ExpandCmd(Settings.DefaultCommand)));
	end
	self.shareSlot:SetVisible( true );	
	
	-- Track label
	self.trackLabel = Turbine.UI.Label();
	self.trackLabel:SetParent( self );
	self.trackLabel:SetPosition(247, 63);
	self.trackLabel:SetSize(30, 12);
	self.trackLabel:SetZOrder(200);
	self.trackLabel:SetText("X:");

	-- Track number
	self.trackNumber = Turbine.UI.Label();
	self.trackNumber:SetParent( self );
	self.trackNumber:SetPosition(262, 63);
	self.trackNumber:SetWidth(20);
	
	-- Track up arrow
	self.trackPrev = Turbine.UI.Control();
	self.trackPrev:SetParent( self );
	self.trackPrev:SetPosition(252, 51);
	self.trackPrev:SetSize(12, 8);
	self.trackPrev:SetBackground("Nathan/Jukebox/arrowup.tga");
	self.trackPrev:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
	self.trackPrev:SetVisible( false );
	
	-- Track down arrow
	self.trackNext = Turbine.UI.Control();
	self.trackNext:SetParent( self );
	self.trackNext:SetPosition(252, 78);
	self.trackNext:SetSize(12, 8);
	self.trackNext:SetBackground("Nathan/Jukebox/arrowdown.tga");
	self.trackNext:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
	self.trackNext:SetVisible( false );
	
	-- actions for track change
	self.trackPrev.MouseClick = function(sender, args)
		if(args.Button == Turbine.UI.MouseButton.Left) then
			self:ChangeTrack(selectedTrack - 1);
		end
	end
	self.trackNext.MouseClick = function(sender, args)
		if(args.Button == Turbine.UI.MouseButton.Left) then
			self:ChangeTrack(selectedTrack + 1);
		end
	end
		
	-- actions for button mouse hovers
	self.musicSlot.MouseEnter = function(sender,args)
		self.musicIcon:SetBackground("Nathan/Jukebox/icn_m_hover.tga");
		self.tipLabel:SetText(Strings["tt_music"]);
	end
	self.musicSlot.MouseLeave = function(sender,args)
		self.musicIcon:SetBackground("Nathan/Jukebox/icn_m.tga");
		self.tipLabel:SetText("");
	end
	self.playSlot.MouseEnter = function(sender,args)
		self.playIcon:SetBackground("Nathan/Jukebox/icn_p_hover.tga");
		self.tipLabel:SetText(Strings["tt_play"]);
	end
	self.playSlot.MouseLeave = function(sender,args)
		self.playIcon:SetBackground("Nathan/Jukebox/icn_p.tga");
		self.tipLabel:SetText("");
	end
	self.readySlot.MouseEnter = function(sender,args)
		self.readyIcon:SetBackground("Nathan/Jukebox/icn_r_hover.tga");
		self.tipLabel:SetText(Strings["tt_ready"]);
	end
	self.readySlot.MouseLeave = function(sender,args)
		self.readyIcon:SetBackground("Nathan/Jukebox/icn_r.tga");
		self.tipLabel:SetText("");
	end
	self.syncSlot.MouseEnter = function(sender,args)
		self.syncIcon:SetBackground("Nathan/Jukebox/icn_s_hover.tga");
		self.tipLabel:SetText(Strings["tt_sync"]);
	end
	self.syncSlot.MouseLeave = function(sender,args)
		self.syncIcon:SetBackground("Nathan/Jukebox/icn_s.tga");
		self.tipLabel:SetText("");
	end
	self.syncStartSlot.MouseEnter = function(sender,args)
		self.syncStartIcon:SetBackground("Nathan/Jukebox/icn_ss_hover.tga");
		self.tipLabel:SetText(Strings["tt_start"]);
	end
	self.syncStartSlot.MouseLeave = function(sender,args)
		self.syncStartIcon:SetBackground("Nathan/Jukebox/icn_ss.tga");
		self.tipLabel:SetText("");
	end
	self.shareSlot.MouseEnter = function(sender,args)
		self.shareIcon:SetBackground("Nathan/Jukebox/icn_sh_hover.tga");
		if (Settings.Commands[Settings.DefaultCommand].Title) then
			self.tipLabel:SetText(Settings.Commands[Settings.DefaultCommand].Title);
		end
	end
	self.shareSlot.MouseLeave = function(sender,args)
		self.shareIcon:SetBackground("Nathan/Jukebox/icn_sh.tga");
		self.tipLabel:SetText("");
	end
	self.shareSlot.MouseWheel = function(sender,args)
		local nextCmd = tonumber(Settings.DefaultCommand) - args.Direction;
		local size = SettingsWindow:CountCmds();
		
		if (nextCmd == 0) then
			Settings.DefaultCommand = tostring(size);		
		elseif (nextCmd > size) then
			Settings.DefaultCommand = "1";		
		else
			Settings.DefaultCommand = tostring(nextCmd);		
		end
		
		self.shareSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, self:ExpandCmd(Settings.DefaultCommand)));		
		self.shareSlot:SetVisible(true);
	end
	self.trackLabel.MouseClick = function(sender,args)
		if(args.Button == Turbine.UI.MouseButton.Left) then
			self:ToggleTracks();
		end
	end
	
	-- icons that hide default quick slots
	self.musicIcon = Turbine.UI.Control();
	self.musicIcon:SetParent( self );
	self.musicIcon:SetPosition(20, 50);
	self.musicIcon:SetSize(35, 35);
	self.musicIcon:SetZOrder(110);
	self.musicIcon:SetMouseVisible(false);
	self.musicIcon:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
	self.musicIcon:SetBackground("Nathan/Jukebox/icn_m.tga");
	
	self.playIcon = Turbine.UI.Control();
	self.playIcon:SetParent( self );
	self.playIcon:SetPosition(60, 50);
	self.playIcon:SetSize(35, 35);
	self.playIcon:SetZOrder(110);
	self.playIcon:SetMouseVisible(false);
	self.playIcon:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
	self.playIcon:SetBackground("Nathan/Jukebox/icn_p.tga");

	self.readyIcon = Turbine.UI.Control();
	self.readyIcon:SetParent( self );
	self.readyIcon:SetPosition(120, 50);
	self.readyIcon:SetSize(35, 35);
	self.readyIcon:SetZOrder(110);
	self.readyIcon:SetMouseVisible(false);
	self.readyIcon:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
	self.readyIcon:SetBackground("Nathan/Jukebox/icn_r.tga");
	
	self.syncIcon = Turbine.UI.Control();
	self.syncIcon:SetParent( self );
	self.syncIcon:SetPosition(161, 50);
	self.syncIcon:SetSize(35, 35);
	self.syncIcon:SetZOrder(110);
	self.syncIcon:SetMouseVisible(false);
	self.syncIcon:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
	self.syncIcon:SetBackground("Nathan/Jukebox/icn_s.tga");
	
	self.syncStartIcon = Turbine.UI.Control();
	self.syncStartIcon:SetParent( self );
	self.syncStartIcon:SetPosition(202, 50);
	self.syncStartIcon:SetSize(35, 35);
	self.syncStartIcon:SetZOrder(110);
	self.syncStartIcon:SetMouseVisible(false);
	self.syncStartIcon:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
	self.syncStartIcon:SetBackground("Nathan/Jukebox/icn_ss.tga");
	
	self.shareIcon = Turbine.UI.Control();
	self.shareIcon:SetParent( self );
	self.shareIcon:SetPosition(287, 50);
	self.shareIcon:SetSize(35, 35);
	self.shareIcon:SetZOrder(110);
	self.shareIcon:SetMouseVisible(false);
	self.shareIcon:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
	self.shareIcon:SetBackground("Nathan/Jukebox/icn_sh.tga");	
	
	-- selected song display
	self.songTitle = Turbine.UI.Label();
	self.songTitle:SetParent( self );
	self.songTitle:SetFont(Turbine.UI.Lotro.Font.Verdana16);
	self.songTitle:SetForeColor( Turbine.UI.Color(1, 0.15, 0.95, 0.15) );	
	self.songTitle:SetPosition( 23, 90 );
	self.songTitle:SetSize( self:GetWidth() - 52, 16);
	
	-- search field
	self.searchInput = Turbine.UI.Lotro.TextBox();
	self.searchInput:SetParent(self);
	self.searchInput:SetPosition(17, 110);
	self.searchInput:SetSize(150, 20);
	self.searchInput:SetFont(Turbine.UI.Lotro.Font.Verdana14);
	self.searchInput:SetMultiline(false);	
	self.searchInput:SetVisible( false );
	local searchFocus = false; 
	self.searchInput.KeyDown = function(sender, args)
		if (args.Action == 162) then
			if (searchFocus) then
				self:SearchSongs();
			end
		end
	end
	self.searchInput.FocusGained = function(sender, args)
		searchFocus = true;
	end
	self.searchInput.FocusLost = function(sender, args)
		searchFocus = false;
	end
	
	-- search button
	self.searchBtn = Turbine.UI.Lotro.Button();
	self.searchBtn:SetParent(self);
	self.searchBtn:SetPosition(172, 110);
	self.searchBtn:SetSize(80, 20);
	self.searchBtn:SetText(Strings["ui_search"]);
	self.searchBtn:SetVisible( false );

	self.searchBtn.MouseClick = function(sender, args)
		self:SearchSongs();
	end
	
	-- clear search button
	self.clearBtn = Turbine.UI.Lotro.Button();
	self.clearBtn:SetParent(self);
	self.clearBtn:SetPosition(255, 110);
	self.clearBtn:SetSize(70, 20);
	self.clearBtn:SetText(Strings["ui_clear"]);
	self.clearBtn:SetVisible( false );
	
	self.clearBtn.MouseClick = function(sender, args)
		searchMode = false;
		self.searchInput:SetText("");
		self.songlistBox:ClearItems();
		self:LoadSongs();
		self:SelectSong(1);
	end
	
	-- hide search components if not toggled
	if (Settings.SearchVisible == "yes") then
		self.searchInput:SetVisible( true );
		self.searchBtn:SetVisible( true );
		self.clearBtn:SetVisible( true );				
	end
	
	-- directory list box
	self.dirlistBox = Turbine.UI.ListBox();
	self.dirlistBox:SetParent( self.listContainer );
	self.dirlistBox:SetMouseVisible( true );
	self.dirlistBox:SetSize(self.listContainer:GetWidth(), Settings.DirHeight);
	self.dirlistBox:SetPosition(10 , 0);
	
	-- scrollbar for directory list box
	self.dirScroll = Turbine.UI.Lotro.ScrollBar();
	self.dirScroll:SetParent( self );
	self.dirScroll:SetOrientation( Turbine.UI.Orientation.Vertical );
	self.dirScroll:SetPosition( self:GetWidth() - self.lFXmod, 147 )
	self.dirScroll:SetHeight( self.dirlistBox:GetHeight() );
	self.dirScroll:SetZOrder(320);
	self.dirScroll:SetWidth( 10 );
	self.dirScroll:SetValue( 0 );
	self.dirlistBox:SetVerticalScrollBar( self.dirScroll );
	
	-- track list box
	self.tracklistBox = Turbine.UI.ListBox();
	self.tracklistBox:SetParent( self.listContainer );
	self.tracklistBox:SetSize( self.listContainer:GetWidth() - 10, Settings.TracksHeight);
	self.tracklistBox:SetPosition(10, self.listContainer:GetHeight() - Settings.TracksHeight);
	self.tracklistBox:SetVisible( false );
	
	-- scrollbar for track list box
	self.trackScroll = Turbine.UI.Lotro.ScrollBar();
	self.trackScroll:SetParent( self );
	self.trackScroll:SetOrientation( Turbine.UI.Orientation.Vertical );
	self.trackScroll:SetPosition( self:GetWidth() - self.lFXmod, self.listContainer:GetTop() + self.tracklistBox:GetTop() )
	self.trackScroll:SetHeight( self.tracklistBox:GetHeight() );
	self.trackScroll:SetZOrder(310);
	self.trackScroll:SetWidth( 10 );
	self.trackScroll:SetValue( 0 );
	self.tracklistBox:SetVerticalScrollBar( self.trackScroll );
	self.trackScroll:SetVisible( false );
		
	-- hide track components if not toggled
	if (Settings.TracksVisible == "yes") then
		self.tracklistBox:SetVisible( true );
		self.separator2:SetVisible( true );
		self.sArrows2:SetVisible( true );		
		self.trackScroll:SetVisible( true );
	end
	
	-- main song list box
	self.songlistBox = Turbine.UI.ListBox();
	self.songlistBox:SetParent( self.listContainer );
	self.songlistBox:SetMouseVisible( true );
	self.songlistBox:SetWidth(self.listContainer:GetWidth() - 10);
	if (Settings.TracksVisible == "yes") then
		self.songlistBox:SetHeight(self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - self.tracklistBox:GetHeight() - 26);
	else
		self.songlistBox:SetHeight(self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - 13);
	end
	self.songlistBox:SetPosition(10 , self.dirlistBox:GetHeight() + 13);
	
	-- scrollbar for song list box
	self.songScroll = Turbine.UI.Lotro.ScrollBar();
	self.songScroll:SetParent( self );
	self.songScroll:SetOrientation( Turbine.UI.Orientation.Vertical );
	self.songScroll:SetPosition( self:GetWidth() - self.lFXmod, self.listContainer:GetTop() + self.songlistBox:GetTop())
	self.songScroll:SetHeight( self.songlistBox:GetHeight() );
	self.songScroll:SetZOrder(310);
	self.songScroll:SetWidth( 10 );
	self.songScroll:SetValue( 0 );
	self.songlistBox:SetVerticalScrollBar( self.songScroll );
			
	-- instrument slot container
	self.instrContainer = Turbine.UI.Control();
	self.instrContainer:SetParent( self );
	self.instrContainer:SetPosition( 10, self:GetHeight() - 75 );
	if (CharSettings.InstrSlots["visible"] == "yes") then
		self.instrContainer:SetVisible( true );
	else
		self.instrContainer:SetVisible( false );
	end
	self.instrContainer:SetSize( 40*CharSettings.InstrSlots["number"], 38 );
	self.instrContainer:SetZOrder(90);

	-- instrument slots
	self.instrSlot = {};
	
	local instrdrag = false;
	for i=1,CharSettings.InstrSlots["number"] do
		self.instrSlot[i] = Turbine.UI.Lotro.Quickslot();
		self.instrSlot[i]:SetParent( self.instrContainer );
		self.instrSlot[i]:SetPosition(40*(i-1), 0);
		self.instrSlot[i]:SetSize(37, 37);
		self.instrSlot[i]:SetZOrder(100);
		self.instrSlot[i]:SetAllowDrop(true);
		
		if (CharSettings.InstrSlots[tostring(i)].data ~= "") then
			pcall(function() 
				local sc = Turbine.UI.Lotro.Shortcut( CharSettings.InstrSlots[tostring(i)].qsType, CharSettings.InstrSlots[tostring(i)].qsData);
				self.instrSlot[i]:SetShortcut(sc);
			end);
		end
		
		self.instrSlot[i].ShortcutChanged = function( sender, args )
			pcall(function() 
				local sc = sender:GetShortcut();
				CharSettings.InstrSlots[tostring(i)].qsType = tostring(sc:GetType());
				CharSettings.InstrSlots[tostring(i)].qsData = sc:GetData();
			end);
		end
		
		self.instrSlot[i].DragLeave = function( sender, args )
			if (instrdrag) then 
				CharSettings.InstrSlots[tostring(i)].qsType ="";
				CharSettings.InstrSlots[tostring(i)].qsData = "";
				local sc = Turbine.UI.Lotro.Shortcut( "", "");
				self.instrSlot[i]:SetShortcut(sc);
				instrdrag = false;
			end
		end
		
		self.instrSlot[i].MouseDown = function( sender, args )
			if(args.Button == Turbine.UI.MouseButton.Left) then	
				instrdrag = true;
			end
		end
	end
	
	-- adjust to search visibility
	
	if (Settings.SearchVisible == "no") then 
		self:ToggleSearch("off");
	end
	
	-- initialize list items from song database
	if (librarySize ~= 0 and not SongDB.Songs[1].Realnames) then
		
		for i = 1, #SongDB.Directories do
			local dirItem = Turbine.UI.Label();
			local _, dirLevel = string.gsub(SongDB.Directories[i], "/", "/");
			if (dirLevel == 2) then				
				dirItem:SetText(string.sub(SongDB.Directories[i],2));			
				dirItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
				dirItem:SetSize( 1000, 20 );				
				self.dirlistBox:AddItem( dirItem );
			end
		end
		
		self.listFrame.heading:SetText( Strings["ui_dirs"] .. " (" .. selectedDir .. ")" );
		
		if (self.dirlistBox:ContainsItem(1)) then
			local dirItem = self.dirlistBox:GetItem(1);
			dirItem:SetForeColor( Turbine.UI.Color(1, 0.15, 0.95, 0.15) );
		end
		
		-- load content to song list box
		self:LoadSongs();
		
		-- set first item as initial selection
		local found = self.songlistBox:GetItemCount();		
		if (found > 0) then
			self:SelectSong(1);
			self:RefreshTracks(selectedSongIndex);
			self:ChangeTrack(selectedTrack);
		end
		self.separator1.heading:SetText( Strings["ui_songs"] .. " (" .. found .. ")" );
		
		-- action for selecting a dir
		self.dirlistBox.SelectedIndexChanged = function( sender, args )
			self:SelectDir(sender:GetSelectedIndex());
		end
		-- action for selecting a song
		self.songlistBox.SelectedIndexChanged = function( sender, args )
			self:SelectSong(sender:GetSelectedIndex());
		end
		-- action for selecting a track
		self.tracklistBox.SelectedIndexChanged = function( sender, args )
			self:ChangeTrack(sender:GetSelectedIndex());
		end
	else
		-- show message when library is empty or database format has changed
		self.separator1:SetVisible( false );
		self.separator2:SetVisible( false );
		self.dirScroll:SetVisible( false );
		self.songScroll:SetVisible( false );
		self.trackScroll:SetVisible( false );
		self.listFrame.heading:SetText( "" );
		self.emptyLabel = Turbine.UI.Label();
		self.emptyLabel:SetParent( self );
		self.emptyLabel:SetPosition( 30, 155 );
		self.emptyLabel:SetSize(220, 240);
		self.emptyLabel:SetText(Strings["err_nosongs"]);
	end
	
	-- window resize control
	self.resizeCtrl = Turbine.UI.Control();
	self.resizeCtrl:SetParent(self);
	self.resizeCtrl:SetSize(20,20);		
	self.resizeCtrl:SetZOrder(200);
	self.resizeCtrl:SetPosition(self:GetWidth() - 20,self:GetHeight() - 20); 
                    
	self.resizeCtrl.MouseDown = function(sender,args)
	  sender.dragStartX = args.X;
	  sender.dragStartY = args.Y;
	  sender.dragging = true;
	end
		
	self.resizeCtrl.MouseUp = function(sender,args)
	  sender.dragging = false;
	  Settings.WindowPosition.Width = self:GetWidth();
	  Settings.WindowPosition.Height = self:GetHeight();
	end
					
	self.resizeCtrl.MouseMove = function(sender,args)
	  	local width, height = self:GetSize();
      
		if ( sender.dragging ) then
			if (self.songlistBox:GetHeight() < 45) and (args.Y - sender.dragStartY) < 0 then
				self.songlistBox:SetHeight(45);				
				self:SetWidth( width + ( args.X - sender.dragStartX ));
			else
				self:SetSize( width + ( args.X - sender.dragStartX ), 
					height + ( args.Y - sender.dragStartY ) );
			end			
			
			self.listFrame:SetSize(self:GetWidth() - self.lFXmod, self:GetHeight() - self.lFYmod);
			self.listContainer:SetSize(self:GetWidth() - self.lCXmod, self:GetHeight() - self.lCYmod);				
			self.dirlistBox:SetSize(self.listContainer:GetWidth() - 10, Settings.DirHeight);
			self.dirScroll:SetLeft(self:GetWidth() - self.lFXmod);
			self.songlistBox:SetWidth(self.listContainer:GetWidth() - 10);
			self.listFrame.heading:SetSize(self.listFrame:GetWidth(),13);
			self.instrContainer:SetTop( self:GetHeight() - 75 );			
			
			if (Settings.TracksVisible == "yes") then
				self.tracklistBox:SetHeight(Settings.TracksHeight);
				self.songlistBox:SetHeight(self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - self.tracklistBox:GetHeight() - 26);
				self.tracklistBox:SetWidth(self.listContainer:GetWidth() - 10);
				self.tracklistBox:SetTop(self.listContainer:GetHeight() - Settings.TracksHeight);
				self.trackScroll:SetPosition(self:GetWidth() - self.lFXmod, self.listContainer:GetTop() + self.tracklistBox:GetTop());
				self.separator2:SetTop( self.listContainer:GetHeight() - Settings.TracksHeight - 13);
				self.separator2:SetWidth(self.listContainer:GetWidth());
				self.sArrows2:SetLeft(self.separator2:GetWidth() / 2 - 10);				
			else
				self.trackScroll:SetVisible(false);
				self.songlistBox:SetHeight(self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - 13);
			end
			
			self.songScroll:SetHeight(self.songlistBox:GetHeight());
			self.songScroll:SetPosition(self:GetWidth() - self.lFXmod, self.listContainer:GetTop() + self.songlistBox:GetTop());
			self.separator1:SetWidth(self.listContainer:GetWidth());
			self.sArrows1:SetLeft(self.separator1:GetWidth() / 2 - 10);
			self.songTitle:SetWidth(self:GetWidth() - 52);
			self.settingsBtn:SetPosition(self:GetWidth()/2 - 50, self:GetHeight() - 30 );	
			self.tipLabel:SetLeft(self:GetWidth() - 270);			
		end
		
    	
		if (self:GetWidth() < self.minWidth) then
		    self:SetWidth(self.minWidth);
			self.listFrame:SetSize(self.minWidth - self.lFXmod, self:GetHeight() - self.lFYmod);
			self.listContainer:SetSize(self.minWidth - self.lCXmod, self:GetHeight() - self.lCYmod);
			self.dirlistBox:SetWidth(self.listContainer:GetWidth() - 10);
			self.songlistBox:SetWidth(self.listContainer:GetWidth() - 10);
			self.listFrame.heading:SetSize(self.listFrame:GetWidth(),13);
			
			if (Settings.TracksVisible == "yes") then
				self.tracklistBox:SetWidth(self.listContainer:GetWidth() - 10);
				self.trackScroll:SetLeft(self.minWidth - self.lFXmod, self.listContainer:GetTop() + self.tracklistBox:GetTop());
				self.separator2:SetWidth(self.listContainer:GetWidth());
				self.sArrows2:SetLeft(self.separator2:GetWidth() / 2 - 10);						
			else
				self.trackScroll:SetVisible(false);
			end
			
			self.songScroll:SetPosition(self.minWidth - self.lFXmod, self.listContainer:GetTop() + self.songlistBox:GetTop());
			self.dirScroll:SetPosition(self.minWidth - self.lFXmod, self.listContainer:GetTop());

			self.separator1:SetWidth(self.listContainer:GetWidth());
			self.sArrows1:SetLeft(self.separator1:GetWidth() / 2 - 10);
			self.songTitle:SetWidth(self.minWidth - 52);
			self.settingsBtn:SetPosition(self:GetWidth()/2 - 50, self:GetHeight() - 30 );	
			self.tipLabel:SetLeft( self.minWidth - 270);
		end
		
		if (self:GetHeight() < self.minHeight) then
		    self:SetHeight(self.minHeight);
			self.listFrame:SetSize(self:GetWidth() - self.lFXmod, self.minHeight - self.lFYmod);
			self.listContainer:SetSize(self:GetWidth() - self.lCXmod, self.minHeight - self.lCYmod);
			
			if (Settings.TracksVisible == "yes") then
				self.songlistBox:SetHeight(self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - self.tracklistBox:GetHeight() - 26);
				self.tracklistBox:SetTop(self.listContainer:GetHeight() - Settings.TracksHeight);
				self.separator2:SetTop(self.listContainer:GetHeight() - Settings.TracksHeight - 13);
				self.trackScroll:SetTop(self.listContainer:GetTop() + self.tracklistBox:GetTop());
			else
				self.songlistBox:SetHeight( self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - 13 );
				self.trackScroll:SetVisible(false);
			end
			
			self.songScroll:SetHeight(self.songlistBox:GetHeight());
			self.settingsBtn:SetPosition(self:GetWidth()/2 - 50, self:GetHeight() - 30 );	
		end
		
		sender:SetPosition( self:GetWidth() - sender:GetWidth(), self:GetHeight() - sender:GetHeight() );
	end 
	
	-- dir list, song list ratio adjust
	self.separator1.MouseDown = function(sender,args)
	  sender.dragStartX = args.X;
	  sender.dragStartY = args.Y;
	  sender.dragging = true;
	end
	
	self.separator1.MouseUp = function(sender,args)
	  sender.dragging = false;
	  Settings.DirHeight = self.dirlistBox:GetHeight(); 
	end
	
	self.separator1.MouseMove = function(sender,args)
		if ( sender.dragging ) then
			local y = self.separator1:GetTop();
			local h = self.dirlistBox:GetHeight();
			self.dirlistBox:SetHeight( h + args.Y - sender.dragStartY );
			if (Settings.TracksVisible == "yes") then
				self.songlistBox:SetHeight(self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - self.tracklistBox:GetHeight() - 26);
			else
				self.songlistBox:SetHeight( self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - 13);
			end
			self.separator1:SetTop(self.dirlistBox:GetHeight());
			self.dirScroll:SetHeight(self.dirlistBox:GetHeight());
			self.songlistBox:SetTop(self.dirlistBox:GetHeight() + 13);
			
			self.songScroll:SetTop( self.listContainer:GetTop() + self.songlistBox:GetTop());
			self.songScroll:SetHeight( self.songlistBox:GetHeight());
		end	
		
		if (self.dirlistBox:GetHeight() < 40) then
			self.dirlistBox:SetHeight(40);
			self.separator1:SetTop(self.dirlistBox:GetHeight());
			self.dirScroll:SetHeight(self.dirlistBox:GetHeight());
			self.songlistBox:SetTop(self.dirlistBox:GetHeight() + 13);
			if (Settings.TracksVisible == "yes") then
				self.songlistBox:SetHeight(self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - self.tracklistBox:GetHeight() - 26);
			else
				self.songlistBox:SetHeight( self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - 13);
			end			
			self.songScroll:SetTop( self.listContainer:GetTop() + self.songlistBox:GetTop());
			self.songScroll:SetHeight(self.songlistBox:GetHeight());
		end
		
		if (self.songlistBox:GetHeight() < 40) then
			self.songlistBox:SetHeight(40);
			if (Settings.TracksVisible == "yes") then
				self.dirlistBox:SetHeight(self.listContainer:GetHeight() - Settings.TracksHeight - self.songlistBox:GetHeight() - 26);
			else
				self.dirlistBox:SetHeight(self.listContainer:GetHeight() - self.songlistBox:GetHeight() - 13);
			end
			
			self.dirScroll:SetHeight(self.dirlistBox:GetHeight());
			self.separator1:SetTop(self.dirlistBox:GetHeight());
			self.songlistBox:SetTop(self.dirlistBox:GetHeight() + 13);
			self.songScroll:SetTop( self.listContainer:GetTop() + self.songlistBox:GetTop());
			self.songScroll:SetHeight( self.songlistBox:GetHeight());
		end		

	end
	
	-- song list, track list ratio adjust
	self.separator2.MouseDown = function(sender,args)
	  sender.dragStartX = args.X;
	  sender.dragStartY = args.Y;
	  sender.dragging = true;
	end
	
	self.separator2.MouseUp = function(sender,args)
	  sender.dragging = false;
	  Settings.TracksHeight = self.tracklistBox:GetHeight(); 
	end
	
	self.separator2.MouseMove = function(sender,args)
		if ( sender.dragging ) then
			local y = self.separator2:GetTop();
			local h = self.tracklistBox:GetHeight();
			self.tracklistBox:SetHeight( h - args.Y + sender.dragStartY );
			self.tracklistBox:SetTop(self.listContainer:GetHeight() - self.tracklistBox:GetHeight());
			self.songlistBox:SetHeight(self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - self.tracklistBox:GetHeight() - 26);
			self.songScroll:SetHeight( self.songlistBox:GetHeight());
			self.trackScroll:SetHeight( self.tracklistBox:GetHeight());
			self.trackScroll:SetTop( self.listContainer:GetTop() + self.tracklistBox:GetTop());
			self.separator2:SetTop(self.listContainer:GetHeight() - self.tracklistBox:GetHeight() - 13);
		end
		if (self.tracklistBox:GetHeight() < 40) then
			self.tracklistBox:SetHeight(40);
			self.tracklistBox:SetTop(self.listContainer:GetHeight() - self.tracklistBox:GetHeight());
			self.songlistBox:SetHeight(self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - self.tracklistBox:GetHeight() - 26);
			self.separator2:SetTop(self.listContainer:GetHeight() - self.tracklistBox:GetHeight() - 13);
			self.songScroll:SetHeight( self.songlistBox:GetHeight());
			self.trackScroll:SetTop( self.listContainer:GetTop() + self.tracklistBox:GetTop());		
			self.trackScroll:SetHeight( self.tracklistBox:GetHeight());
		end
		if (self.songlistBox:GetHeight() < 40) then
			self.songlistBox:SetHeight(40);
			self.tracklistBox:SetHeight(self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - self.songlistBox:GetHeight() - 26);
			self.tracklistBox:SetTop(self.listContainer:GetHeight() - self.tracklistBox:GetHeight());
			self.songScroll:SetHeight( self.songlistBox:GetHeight());
			self.trackScroll:SetTop( self.listContainer:GetTop() + self.tracklistBox:GetTop());
			self.trackScroll:SetHeight( self.tracklistBox:GetHeight());			
			self.separator2:SetTop(self.listContainer:GetHeight() - self.tracklistBox:GetHeight() - 13);
		end	
	end
	
	-- Settings button	
	self.settingsBtn = Turbine.UI.Lotro.Button();
	self.settingsBtn:SetParent( self );
	self.settingsBtn:SetPosition(self:GetWidth()/2 - 55, self:GetHeight() - 30 );	
	self.settingsBtn:SetSize(110,20);
	self.settingsBtn:SetText(Strings["ui_settings"]);
	
	-- actions for settings button
	self.settingsBtn.MouseClick = function(sender, args)
		if(args.Button == Turbine.UI.MouseButton.Left) then
			settingsWindow:SetVisible(true);
		end
	end	
	
	-- action for closing window and saving position
	self.Closed = function( sender, args )
		self:SaveSettings();
		self:SetVisible( false );
	end
	
	if (Plugins ["Jukebox"] ~= nil ) then
		Plugins["Jukebox"].Unload = function( sender, args )
				self:SaveSettings();
		end
	end
	
end

function JukeboxWindow:SetDB(data)
	SongDB = data;
	librarySize = #SongDB.Songs;
	JukeBoxWindow:InitDirList();
end

function JukeboxWindow:GetDB()
	return SongDB;
end

-- action for selecting a directory
function JukeboxWindow:SelectDir( args )
	searchMode = false;
	local selectedItem = self.dirlistBox:GetItem(args);
	
	for i = 1,self.dirlistBox:GetItemCount() do
		local item = self.dirlistBox:GetItem(i);	
		item:SetForeColor( Turbine.UI.Color(1, 1, 1, 1) );
	end			
	selectedItem:SetForeColor( Turbine.UI.Color(1, 0.15, 0.95, 0.15) );	
	if (selectedItem:GetText() == "..") then
		selectedDir = "";
		table.remove(dirPath,#dirPath);
		for i = 1,#dirPath do 
			selectedDir = selectedDir .. dirPath[i];
		end
	else		
		selectedDir = selectedDir .. selectedItem:GetText();
		dirPath[#dirPath+1] = selectedItem:GetText();	
	end
	
	if (string.len(selectedDir)<31) then 
		self.listFrame.heading:SetText( Strings["ui_dirs"] .. " (" .. selectedDir .. ")" );
	else 
		self.listFrame.heading:SetText( Strings["ui_dirs"] .. " (" .. string.sub(selectedDir,string.len(selectedDir)-30) .. ")" );
	end
	
	-- refresh dir list
	self.dirlistBox:ClearItems();
	local dirItem = Turbine.UI.Label();
	if (selectedDir ~= "/") then
		dirItem:SetText(".."); -- first item as link to previous directory
		dirItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
		dirItem:SetSize( 1000, 20 );				
		self.dirlistBox:AddItem( dirItem );
	end
	
	for i = 1, #SongDB.Directories do
		dirItem = Turbine.UI.Label();		
		local _, dirLevelIni = string.gsub(selectedDir, "/", "/");
		local _, dirLevel = string.gsub(SongDB.Directories[i], "/", "/");
		if (dirLevel == dirLevelIni + 1) then
			if (selectedDir ~= "/") then
				local matchPos,_ = string.find(SongDB.Directories[i], selectedDir, 0, true);
				if (matchPos == 1) then	
					local _,cutPoint = string.find(SongDB.Directories[i], dirPath[#dirPath], 0, true);
					dirItem:SetText(string.sub(SongDB.Directories[i],cutPoint+1));			
					dirItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
					dirItem:SetSize( 1000, 20 );				
					self.dirlistBox:AddItem( dirItem );
				end
			else 
				dirItem:SetText(string.sub(SongDB.Directories[i],2));			
				dirItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
				dirItem:SetSize( 1000, 20 );				
				self.dirlistBox:AddItem( dirItem );
			end
		end
	end
	
	self.songlistBox:ClearItems();
	self:LoadSongs();
	local found = self.songlistBox:GetItemCount();
	if (found > 0) then
		self:SelectSong(1);
	else
		self.tracklistBox:ClearItems();
		self.separator2.heading:SetText( Strings["ui_parts"] .. " (0)" );
	end
	self.separator1.heading:SetText( Strings["ui_songs"] .. " (" .. found .. ")" );
end

-- load content to song list box
function JukeboxWindow:LoadSongs()
	local gotMod = false; --got the songIndexMod
	for i = 1, librarySize do
		local songItem = Turbine.UI.Label();
		if (SongDB.Songs[i].Filepath == selectedDir) then
			if not gotMod then
				songIndexMod = i - 1;
				gotMod = true;
			end			
			if (Settings.DescriptionVisible == "yes") then
				if (Settings.DescriptionFirst == "yes") then
					songItem:SetText(SongDB.Songs[i].Tracks[1].Name .. " / " .. SongDB.Songs[i].Filename);					
				else
					songItem:SetText(SongDB.Songs[i].Filename .. " / " .. SongDB.Songs[i].Tracks[1].Name);
				end
			else
				songItem:SetText(SongDB.Songs[i].Filename);
			end
			songItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
			songItem:SetSize( 1000, 20 );				
			self.songlistBox:AddItem( songItem );			
		end
	end
end

-- action for selecting a song
function JukeboxWindow:SelectSong( args )
	selectedTrack = 1;
	local selectedItem = self.songlistBox:GetItem(args);

	-- clear focus
	for i = 1,self.songlistBox:GetItemCount() do
		local item = self.songlistBox:GetItem(i);	
		item:SetForeColor( Turbine.UI.Color(1, 1, 1, 1) );
	end				
	selectedItem:SetForeColor( Turbine.UI.Color(1, 0.15, 0.95, 0.15) );
	
	if not searchMode then
		selectedSongIndex = songIndexMod + args;
		selectedSong = SongDB.Songs[selectedSongIndex].Filename;
				
		if ( SongDB.Songs[selectedSongIndex].Tracks[1].Name ~= "") then
			self.songTitle:SetText( SongDB.Songs[selectedSongIndex].Tracks[1].Name );	
		else
			self.songTitle:SetText( SongDB.Songs[selectedSongIndex].Filename );	
		end
		self.trackNumber:SetText( SongDB.Songs[selectedSongIndex].Tracks[1].Id );
		self.trackPrev:SetVisible(false);
		
		if (#SongDB.Songs[selectedSongIndex].Tracks > 1) then
			self.trackNext:SetVisible(true);
		else
			self.trackNext:SetVisible(false);
		end
				
		self.playSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias,  Strings["cmd_play"] .. " \"" .. selectedDir .. selectedSong .. "\""));
		self.playSlot:SetVisible( true );
		self.syncSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_play"] .. " \"" .. selectedDir ..selectedSong .. "\" " .. Strings["cmd_sync"]));
		self.syncSlot:SetVisible( true );
		self.shareSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, self:ExpandCmd(Settings.DefaultCommand)));		
		self.shareSlot:SetVisible( true );
	else
	
		selectedSongIndex = args;
		
		selectedSong = SearchDB[selectedSongIndex].Filename;
	
		if ( SearchDB[selectedSongIndex].Tracks[1].Name ~= "") then
			self.songTitle:SetText( SearchDB[selectedSongIndex].Tracks[1].Name );	
		else
			self.songTitle:SetText( SearchDB[selectedSongIndex].Filename );	
		end
		self.trackNumber:SetText( SearchDB[selectedSongIndex].Tracks[1].Id );
		self.trackPrev:SetVisible(false);
		if (#SearchDB[selectedSongIndex].Tracks > 1) then
			self.trackNext:SetVisible(true);
		else
			self.trackNext:SetVisible(false);
		end
		
		self.playSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias,  Strings["cmd_play"] .. " \"" .. SearchDB[selectedSongIndex].Filepath .. selectedSong .. "\""));
		self.playSlot:SetVisible( true );
		self.syncSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_play"] .. " \"" .. SearchDB[selectedSongIndex].Filepath .. selectedSong .. "\" " .. Strings["cmd_sync"]));
		self.syncSlot:SetVisible( true );
		self.shareSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, self:ExpandCmd(Settings.DefaultCommand)));		
		self.shareSlot:SetVisible( true );
	end
	
	self:RefreshTracks(selectedSongIndex);	
	self:ChangeTrack(selectedTrack);
	local found = self.tracklistBox:GetItemCount();
	self.separator2.heading:SetText( Strings["ui_parts"] .. " (" .. found .. ")" );
end


-- action for repopulating the track list when song is changed
function JukeboxWindow:RefreshTracks( songid )			
	self.tracklistBox:ClearItems();
	if not searchMode then
		for i = 1, #SongDB.Songs[songid].Tracks do
			local trackItem = Turbine.UI.Label();
			trackItem:SetText("[" .. SongDB.Songs[songid].Tracks[i].Id .. "] " .. SongDB.Songs[songid].Tracks[i].Name);
			trackItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
			trackItem:SetSize( 1000, 20 );				
			self.tracklistBox:AddItem( trackItem );			
		end
	else
		for i = 1, #SearchDB[songid].Tracks do
			local trackItem = Turbine.UI.Label();
			trackItem:SetText("[" .. SearchDB[songid].Tracks[i].Id .. "] " .. SearchDB[songid].Tracks[i].Name);
			trackItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
			trackItem:SetSize( 1000, 20 );				
			self.tracklistBox:AddItem( trackItem );			
		end
	end
end

-- action for changing track selection
function JukeboxWindow:ChangeTrack(trackid)
	selectedTrack = trackid;
	local trackcount;
	if not searchMode then
		trackcount = #SongDB.Songs[selectedSongIndex].Tracks;
	else
		trackcount = #SearchDB[selectedSongIndex].Tracks;
	end

	if ( selectedTrack > 1) then
		if ( selectedTrack == trackcount ) then
			self.trackPrev:SetVisible( true );
			self.trackNext:SetVisible( false );
		else
			self.trackPrev:SetVisible( true );
			self.trackNext:SetVisible( true );
		end
	end
	if ( selectedTrack == 1) then
		self.trackPrev:SetVisible( false );
		if (trackcount == 1) then		
			self.trackNext:SetVisible( false );
		else
			self.trackNext:SetVisible( true );
		end
	end

	if not searchMode then
		self.trackNumber:SetText(SongDB.Songs[selectedSongIndex].Tracks[selectedTrack].Id);
		self.songTitle:SetText(SongDB.Songs[selectedSongIndex].Tracks[selectedTrack].Name);
	
		self.playSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_play"] .. " \"" .. selectedDir .. selectedSong .. "\" " .. SongDB.Songs[selectedSongIndex].Tracks[selectedTrack].Id));
		self.playSlot:SetVisible( true );
		self.syncSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_play"] .. " \"" .. selectedDir .. selectedSong .. "\" " .. SongDB.Songs[selectedSongIndex].Tracks[selectedTrack].Id .. " " .. Strings["cmd_sync"]));
		self.syncSlot:SetVisible( true );
		self.shareSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, self:ExpandCmd(Settings.DefaultCommand)));		
		self.shareSlot:SetVisible( true );		
	else
		self.trackNumber:SetText(SearchDB[selectedSongIndex].Tracks[selectedTrack].Id);
		self.songTitle:SetText(SearchDB[selectedSongIndex].Tracks[selectedTrack].Name);

		self.playSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_play"] .. " \"" .. SearchDB[selectedSongIndex].Filepath .. selectedSong .. "\" " .. SearchDB[selectedSongIndex].Tracks[selectedTrack].Id));
		self.playSlot:SetVisible( true );
		self.syncSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_play"] .. " \"" .. SearchDB[selectedSongIndex].Filepath .. selectedSong .. "\" " .. SearchDB[selectedSongIndex].Tracks[selectedTrack].Id .. " " .. Strings["cmd_sync"]));
		self.syncSlot:SetVisible( true );
		self.shareSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, self:ExpandCmd(Settings.DefaultCommand)));		
		self.shareSlot:SetVisible( true );		
	end
	self:SetTrackFocus(selectedTrack);
end

-- action for setting focus on the track list
function JukeboxWindow:SetTrackFocus(trackNumber)
	for i = 1,self.tracklistBox:GetItemCount() do
		local item = self.tracklistBox:GetItem(i);
		if (i == trackNumber) then
			item:SetForeColor( Turbine.UI.Color(1, 0.15, 0.95, 0.15) );
		else
			item:SetForeColor( Turbine.UI.Color(1, 1, 1, 1) );
		end
	end		
end

-- action to search songs
function JukeboxWindow:SearchSongs()
	searchMode = true;
	self.songlistBox:ClearItems();
	local ii = 1;
	local matchFound = false;
	
	for i = 1, librarySize do		
		matchFound = false;

		if (string.find(string.lower(SongDB.Songs[i].Filename), string.lower(self.searchInput:GetText())) ~= nil) then
			matchFound = true;
		else
			for j = 1, #SongDB.Songs[i].Tracks do
				if not matchFound then				
					if (string.find(string.lower(SongDB.Songs[i].Tracks[j].Name), string.lower(self.searchInput:GetText())) ~= nil) then
						matchFound = true;
					end
				end
			end
		end
		
		if (matchFound) then
			local songItem = Turbine.UI.Label();
			if (Settings.DescriptionVisible == "yes") then			
				songItem:SetText(SongDB.Songs[i].Filename .. " / " .. SongDB.Songs[i].Tracks[1].Name);
			else
				songItem:SetText(SongDB.Songs[i].Filename);
			end
			songItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
			songItem:SetSize( 1000, 20 );				
			self.songlistBox:AddItem( songItem );								
			SearchDB[ii] = {};
			SearchDB[ii].Filename = SongDB.Songs[i].Filename;
			SearchDB[ii].Filepath = SongDB.Songs[i].Filepath;
			SearchDB[ii].Tracks = {};
			for j = 1, #SongDB.Songs[i].Tracks do
				SearchDB[ii].Tracks[j] = {};
				SearchDB[ii].Tracks[j].Id = SongDB.Songs[i].Tracks[j].Id;
				SearchDB[ii].Tracks[j].Name = SongDB.Songs[i].Tracks[j].Name;
			end
			ii = ii + 1;
		end
	end
	
	local found = self.songlistBox:GetItemCount();
	if (found > 0) then
		self:SelectSong(1);
	end
	self.separator1.heading:SetText( Strings["ui_songs"] .. " (" .. found .. ")" );
end

-- action for toggling search function on and off
function JukeboxWindow:ToggleSearch(mode)
	if (Settings.SearchVisible == "yes" or mode == "off") then		
		Settings.SearchVisible = "no";
		self.searchInput:SetVisible(false);
		self.searchBtn:SetVisible(false);
		self.clearBtn:SetVisible(false);
		self.lFYmod = self.lFYmod - 20;		
		self.lCYmod = self.lCYmod - 20;		
		self.listFrame:SetTop(114);
		self.listContainer:SetTop(127);
		self.songlistBox:SetHeight(self.songlistBox:GetHeight() + 20);	
		self.songScroll:SetHeight(self.songlistBox:GetHeight());
		self.tracklistBox:SetTop(self.tracklistBox:GetTop() + 20);
		self.separator2:SetTop(self.listContainer:GetHeight() - self.tracklistBox:GetHeight() - 13 + 20);
	else
		Settings.SearchVisible = "yes";
		self.searchInput:SetVisible(true);
		self.searchBtn:SetVisible(true);
		self.clearBtn:SetVisible(true);		
		self.lFYmod = self.lFYmod + 20;		
		self.lCYmod = self.lCYmod + 20;
		self.listFrame:SetTop(134);
		self.listContainer:SetTop(147);
		self.songlistBox:SetHeight(self.songlistBox:GetHeight() -20);		
		self.songScroll:SetHeight(self.songlistBox:GetHeight());
		self.tracklistBox:SetTop(self.tracklistBox:GetTop() - 20);
		self.separator2:SetTop(self.listContainer:GetHeight() - self.tracklistBox:GetHeight() - 13 - 20);
	end

	self.listFrame:SetHeight(self:GetHeight() - self.lFYmod);	
	self.listContainer:SetHeight(self:GetHeight() - self.lCYmod);		
	self.dirScroll:SetTop(self.listContainer:GetTop());
	self.songScroll:SetTop(self.listContainer:GetTop() + self.songlistBox:GetTop());
	self.trackScroll:SetTop(self.listContainer:GetTop() + self.tracklistBox:GetTop());
	self.trackScroll:SetHeight(self.tracklistBox:GetHeight());
	if (Settings.TracksVisible == "no") then
		self.trackScroll:SetVisible(false);
	end
end

-- action for toggling description on and off
function JukeboxWindow:ToggleDescription()
	if (Settings.DescriptionVisible == "yes") then
		Settings.DescriptionVisible = "no";
		self.songlistBox:ClearItems();
		self:LoadSongs();
		local found = self.songlistBox:GetItemCount();		
		if (found > 0) then
			self:SelectSong(1);
			self:RefreshTracks(selectedSongIndex);
			self:ChangeTrack(selectedTrack);
		end
	else
		Settings.DescriptionVisible = "yes";
		self.songlistBox:ClearItems();
		self:LoadSongs();
		local found = self.songlistBox:GetItemCount();		
		if (found > 0) then
			self:SelectSong(1);
			self:RefreshTracks(selectedSongIndex);
			self:ChangeTrack(selectedTrack);
		end
	end
end

-- action for toggling description on and off
function JukeboxWindow:ToggleDescriptionFirst()
	if (Settings.DescriptionFirst == "yes") then
		Settings.DescriptionFirst = "no";		
		if (Settings.DescriptionVisible == "yes") then
			self.songlistBox:ClearItems();
			self:LoadSongs();
			local found = self.songlistBox:GetItemCount();		
			if (found > 0) then
				self:SelectSong(1);
				self:RefreshTracks(selectedSongIndex);
				self:ChangeTrack(selectedTrack);
			end
		end
	else
		Settings.DescriptionFirst = "yes";
		if (Settings.DescriptionVisible == "yes") then
			self.songlistBox:ClearItems();
			self:LoadSongs();
			local found = self.songlistBox:GetItemCount();		
			if (found > 0) then
				self:SelectSong(1);
				self:RefreshTracks(selectedSongIndex);
				self:ChangeTrack(selectedTrack);
			end
		end
	end
end

-- action for toggling tracks display on and off
function JukeboxWindow:ToggleTracks()
	if (Settings.TracksVisible == "yes") then
		Settings.TracksVisible = "no";
		self.songlistBox:SetHeight(self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - 13);
		self.songScroll:SetHeight(self.songlistBox:GetHeight());			
		self.tracklistBox:SetVisible(false);
		self.trackScroll:SetVisible(false);
		self.separator2:SetVisible(false);
	else
		Settings.TracksVisible = "yes";
		self.tracklistBox:SetVisible(true);
		self.trackScroll:SetVisible(true);
		self.separator2:SetVisible(true);
		self.sArrows2:SetVisible(true);
		
		-- check if there's room for the track list and adjust
		local h = self.dirlistBox:GetHeight() + Settings.TracksHeight + 26;
		if (self.listContainer:GetHeight() - h < 40) then
			self.listContainer:SetHeight(h + self.songlistBox:GetHeight())
			self:SetHeight(self.listContainer:GetHeight() + self.lCYmod);
			self.listFrame:SetHeight(self:GetHeight() - self.lFYmod);
			self.resizeCtrl:SetTop(self:GetHeight() - 20); 
		end
					
		self.tracklistBox:SetTop(self.listContainer:GetHeight() - Settings.TracksHeight);
		self.tracklistBox:SetSize(self.listContainer:GetWidth() - 10, Settings.TracksHeight);			
		self.trackScroll:SetPosition(self:GetWidth() - self.lFXmod, self.listContainer:GetTop() + self.tracklistBox:GetTop());
		self.trackScroll:SetHeight(self.tracklistBox:GetHeight());
		self.separator2:SetTop(self.tracklistBox:GetTop() - 13);
		self.separator2:SetWidth(self.listContainer:GetWidth());
		self.songlistBox:SetHeight(self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - self.tracklistBox:GetHeight() - 26);
		self.songScroll:SetHeight(self.songlistBox:GetHeight());
		self.settingsBtn:SetPosition(self:GetWidth()/2 - 50, self:GetHeight() - 30 );	
		self.sArrows2:SetLeft(self.separator2:GetWidth() / 2 - 10);			
	end
end

-- action for toggling instrument slots on and off
function JukeboxWindow:ToggleInstrSlots()
	local hMod = 45;
	if (CharSettings.InstrSlots["visible"] == "yes") then		
		CharSettings.InstrSlots["visible"] = "no";		
		self.instrContainer:SetVisible( false );	
		self.lFYmod = self.lFYmod - hMod;
		self.lCYmod = self.lCYmod - hMod;
		self.listFrame:SetHeight(self.listFrame:GetHeight() + hMod);
		self.listContainer:SetHeight(self.listContainer:GetHeight() + hMod);				
		self.songlistBox:SetHeight(self.songlistBox:GetHeight() + hMod);
		self.songScroll:SetHeight(self.songlistBox:GetHeight());
		if (Settings.TracksVisible == "yes") then		
			self.tracklistBox:SetTop(self.tracklistBox:GetTop() + hMod);
			self.separator2:SetTop(self.separator2:GetTop() + hMod);
		end
	else
		CharSettings.InstrSlots["visible"] = "yes";
		self.lFYmod = self.lFYmod + hMod;
		self.lCYmod = self.lCYmod + hMod;
		self.listFrame:SetHeight(self.listFrame:GetHeight() - hMod);
		self.listContainer:SetHeight(self.listContainer:GetHeight() - hMod);				
		self.songlistBox:SetHeight(self.songlistBox:GetHeight() -hMod);
		self.songScroll:SetHeight(self.songlistBox:GetHeight());
		if (Settings.TracksVisible == "yes") then
			self.tracklistBox:SetTop(self.tracklistBox:GetTop() - hMod);
			self.separator2:SetTop(self.separator2:GetTop() - hMod);		
		end
		self.instrContainer:SetVisible( true );
	end
end

function JukeboxWindow:ClearSlots()
	for i=1,CharSettings.InstrSlots["number"] do
		CharSettings.InstrSlots[tostring(i)].qsType ="";
		CharSettings.InstrSlots[tostring(i)].qsData = "";
		local sc = Turbine.UI.Lotro.Shortcut( "", "");
		self.instrSlot[i]:SetShortcut(sc);
	end
end

function JukeboxWindow:AddSlot()

	if self:GetWidth() > 10+(CharSettings.InstrSlots["number"]+1)*40 then
		local newslot = CharSettings.InstrSlots["number"]+1;
		CharSettings.InstrSlots["number"] = newslot;
		self.instrSlot[newslot] = Turbine.UI.Lotro.Quickslot();
		self.instrSlot[newslot]:SetParent( self.instrContainer );
		self.instrSlot[newslot]:SetPosition(40*(newslot-1), 0);
		self.instrSlot[newslot]:SetSize(37, 37);
		self.instrSlot[newslot]:SetZOrder(100);
		self.instrSlot[newslot]:SetAllowDrop(true);
		self.instrContainer:SetWidth(self.instrContainer:GetWidth()+40); 
		
		local sc = Turbine.UI.Lotro.Shortcut("","");
		self.instrSlot[newslot]:SetShortcut(sc);
		
		CharSettings.InstrSlots[tostring(newslot)] = { qsType = "", qsData = "" };		
		
		self.instrSlot[newslot].ShortcutChanged = function( sender, args )
			pcall(function() 
				local sc = sender:GetShortcut();
				CharSettings.InstrSlots[tostring(newslot)].qsType = tostring(sc:GetType());
				CharSettings.InstrSlots[tostring(newslot)].qsData = sc:GetData();
			end);
		end
		
		self.instrSlot[newslot].DragLeave = function( sender, args )
			if (instrdrag) then 
				CharSettings.InstrSlots[tostring(newslot)].qsType ="";
				CharSettings.InstrSlots[tostring(newslot)].qsData = "";
				local sc = Turbine.UI.Lotro.Shortcut( "", "");
				self.instrSlot[newslot]:SetShortcut(sc);
				instrdrag = false;
			end
		end
		
		self.instrSlot[newslot].MouseDown = function( sender, args )
			if(args.Button == Turbine.UI.MouseButton.Left) then	
				instrdrag = true;
			end
		end
	end
end

function JukeboxWindow:DelSlot()
	if CharSettings.InstrSlots["number"] > 1 then
		local delslot = CharSettings.InstrSlots["number"];
		CharSettings.InstrSlots["number"] = CharSettings.InstrSlots["number"]-1;
		self.instrContainer:SetWidth(self.instrContainer:GetWidth()-40); 
		self.instrSlot[delslot] = nil;
		CharSettings.InstrSlots[tostring(delslot)] = nil;
	end
end


function JukeboxWindow:ExpandCmd(cmdId)
	if librarySize ~= 0 then
		local cmd = Settings.Commands[cmdId].Command;
		if SongDB.Songs[selectedSongIndex].Tracks[selectedTrack] then
			cmd = string.gsub(cmd, "%%name", SongDB.Songs[selectedSongIndex].Tracks[selectedTrack].Name);				
			cmd = string.gsub(cmd, "%%file", SongDB.Songs[selectedSongIndex].Filename);
			if (selectedTrack ~= 1) then
				cmd = string.gsub(cmd, "%%part", selectedTrack);
			else
				cmd = string.gsub(cmd, "%%part", "");
			end
		elseif SongDB.Songs[selectedSongIndex].Filename then
			cmd = string.gsub(cmd, "%%name", SongDB.Songs[selectedSongIndex].Filename);
			cmd = string.gsub(cmd, "%%file", SongDB.Songs[selectedSongIndex].Filename);	
			if (selectedTrack ~= 1) then
				cmd = string.gsub(cmd, "%%part", selectedTrack);
			else
				cmd = string.gsub(cmd, "%%part", "");
			end
		else 
			cmd = "";
		end
		return cmd;
	end
end

function JukeboxWindow:SaveSettings()
	Settings.WindowPosition.Left = tostring(self:GetLeft());
	Settings.WindowPosition.Top = tostring(self:GetTop());
	Settings.WindowPosition.Width = tostring(self:GetWidth());
	Settings.WindowPosition.Height = tostring(self:GetHeight());
	Settings.ToggleTop = tostring(Settings.ToggleTop);
	Settings.ToggleLeft = tostring(Settings.ToggleLeft);
	Settings.DirHeight = tostring(Settings.DirHeight);
	Settings.TracksHeight = tostring(Settings.TracksHeight);
	Settings.WindowOpacity = tostring(Settings.WindowOpacity);
	Settings.ToggleOpacity = tostring(Settings.ToggleOpacity);
	
	for i = 1, CharSettings.InstrSlots["number"] do
		CharSettings.InstrSlots[tostring(i)].qsType = tostring(CharSettings.InstrSlots[tostring(i)].qsType);
	end
	CharSettings.InstrSlots["number"] = tostring(CharSettings.InstrSlots["number"]);
	
	JukeboxSave( Turbine.DataScope.Account, "JukeboxSettings", Settings,
		function( result, message )
			if ( result ) then
				Turbine.Shell.WriteLine( "<rgb=#00FF00>" .. Strings["sh_saved"] .. "</rgb>");
			else
				Turbine.Shell.WriteLine( "<rgb=#FF0000>" .. Strings["sh_notsaved"] .. " " .. message .. "</rgb>" );
			end
		end);
	JukeboxSave( Turbine.DataScope.Character, "JukeboxSettings", CharSettings,
		function( result, message )
			if ( result ) then
				--Turbine.Shell.WriteLine( "<rgb=#00FF00>" .. Strings["sh_saved"] .. "</rgb>");
			else
				Turbine.Shell.WriteLine( "<rgb=#FF0000>" .. Strings["sh_notsaved"] .. " " .. message .. "</rgb>" );
			end
		end);	
end