SettingsWindow = class( Turbine.UI.Lotro.Window );

function SettingsWindow:Constructor()
	Turbine.UI.Lotro.Window.Constructor( self );
	
	local sCmd = 0;
	
	self:SetPosition( Settings.WindowPosition.Left - 300, Settings.WindowPosition.Top + 100 );
	self:SetSize(370,535);
	self:SetZOrder(20);
	self:SetText(Strings["ui_settings"]);

	-- general settings label
	self.genLabel = Turbine.UI.Label();
	self.genLabel:SetParent(self);
	self.genLabel:SetPosition(20,40);
	self.genLabel:SetWidth(300);
	self.genLabel:SetForeColor(Turbine.UI.Color(1,0.77,0.64,0.22));
	self.genLabel:SetFont( Turbine.UI.Lotro.Font.TrajanPro16 );
	self.genLabel:SetText(Strings["ui_general"]);
	
	--Track display checkbox
	self.trackCheck = Turbine.UI.Lotro.CheckBox();
	self.trackCheck:SetParent( self );
	self.trackCheck:SetPosition(20, 60);
	self.trackCheck:SetSize(300,20);
	self.trackCheck:SetText(" " .. Strings["cb_parts"]);
	
	if (Settings.TracksVisible == "yes") then
		self.trackCheck:SetChecked(true);
	else
		self.trackCheck:SetChecked(false);
	end	
	
	self.trackCheck.CheckedChanged = function(sender, args)
		JukeboxWindow:ToggleTracks();
	end
	
	--Search function enabled checkbox
	self.searchCheck = Turbine.UI.Lotro.CheckBox();
	self.searchCheck:SetParent( self );
	self.searchCheck:SetPosition(20, 85);
	self.searchCheck:SetSize(300,20);	
	self.searchCheck:SetText(" " .. Strings["cb_search"]);
	
	if (Settings.SearchVisible == "yes") then
		self.searchCheck:SetChecked(true);
	else
		self.searchCheck:SetChecked(false);
	end
	self.searchCheck.CheckedChanged = function(sender, args)
		JukeboxWindow:ToggleSearch();
	end
	
	--Show description in song list checkbox
	self.descCheck = Turbine.UI.Lotro.CheckBox();
	self.descCheck:SetParent( self );
	self.descCheck:SetPosition(20, 110);
	self.descCheck:SetSize(300,20);	
	self.descCheck:SetText(" " .. Strings["cb_desc"]);
	
	if (Settings.DescriptionVisible == "yes") then
		self.descCheck:SetChecked(true);
	else
		self.descCheck:SetChecked(false);
	end
	self.descCheck.CheckedChanged = function(sender, args)
		JukeboxWindow:ToggleDescription();
	end
	
	--Show description first in song list checkbox
	self.descFirstCheck = Turbine.UI.Lotro.CheckBox();
	self.descFirstCheck:SetParent( self );
	self.descFirstCheck:SetPosition(20, 135);
	self.descFirstCheck:SetSize(300,20);	
	self.descFirstCheck:SetText(" " .. Strings["cb_descfirst"]);
	
	if (Settings.DescriptionFirst == "yes") then
		self.descFirstCheck:SetChecked(true);
	else
		self.descFirstCheck:SetChecked(false);
	end
	self.descFirstCheck.CheckedChanged = function(sender, args)
		JukeboxWindow:ToggleDescriptionFirst();
	end	
	
	--Window visibility on load checkbox
	self.visibleCheck = Turbine.UI.Lotro.CheckBox();
	self.visibleCheck:SetParent( self );
	self.visibleCheck:SetPosition(20, 160);
	self.visibleCheck:SetSize(300,20);
	self.visibleCheck:SetText(" " .. Strings["cb_windowvis"]);
	
	if (Settings.WindowVisible == "yes") then
		self.visibleCheck:SetChecked(true);
	else
		self.visibleCheck:SetChecked(false);
	end
	self.visibleCheck.CheckedChanged = function(sender, args)
		self:ChangeVisibility();
	end
	
	self.sbbtnLabel = Turbine.UI.Label();
	self.sbbtnLabel:SetParent(self);
	self.sbbtnLabel:SetPosition(20,185);
	self.sbbtnLabel:SetWidth(300);
	self.sbbtnLabel:SetForeColor(Turbine.UI.Color(1,0.77,0.64,0.22));
	self.sbbtnLabel:SetFont( Turbine.UI.Lotro.Font.TrajanPro16 );
	self.sbbtnLabel:SetText(Strings["ui_icon"]);
	
	--Jukebox button visibility checkbox	
	self.toggleCheck = Turbine.UI.Lotro.CheckBox();
	self.toggleCheck:SetParent( self );
	self.toggleCheck:SetPosition(20, 205);
	self.toggleCheck:SetSize(300,20);
	self.toggleCheck:SetText(" " .. Strings["cb_iconvis"]);

	if (Settings.ToggleVisible == "yes") then
		self.toggleCheck:SetChecked(true);
	else
		self.toggleCheck:SetChecked(false);
	end
	self.toggleCheck.CheckedChanged = function(sender, args)
		self:ChangeToggleVisibility();
	end

	-- Toggle button opacity controls
	self.toggleOpacityLabel = Turbine.UI.Label();
	self.toggleOpacityLabel:SetParent(self);
	self.toggleOpacityLabel:SetPosition(45,235);
	self.toggleOpacityLabel:SetWidth(300);
	self.toggleOpacityLabel:SetText(Strings["ui_btn_opacity"]);
	
	self.toggleOpacityScroll = Turbine.UI.Lotro.ScrollBar();
	self.toggleOpacityScroll:SetParent(self);
	self.toggleOpacityScroll:SetOrientation( Turbine.UI.Orientation.Horizontal );
	self.toggleOpacityScroll:SetPosition(45,250);
	self.toggleOpacityScroll:SetSize(220,10);
	self.toggleOpacityScroll:SetValue( 100*Settings.ToggleOpacity );
	self.toggleOpacityScroll:SetMaximum( 100 );
	self.toggleOpacityScroll:SetMinimum( 0 );
	self.toggleOpacityScroll:SetSmallChange( 1 );
	self.toggleOpacityScroll:SetLargeChange( 5 );
	
	self.toggleOpacityScroll.ValueChanged = function(sender,args)
		newvalue = sender:GetValue()/100;
		Settings.ToggleOpacity = newvalue;
		self.toggleOpacityInd:SetText(newvalue);
		toggleWindow:SetOpacity(newvalue);
	end
	
	self.toggleOpacityInd = Turbine.UI.Label();
	self.toggleOpacityInd:SetParent(self);
	self.toggleOpacityInd:SetPosition(280,250);
	self.toggleOpacityInd:SetWidth(30);
	self.toggleOpacityInd:SetForeColor(Turbine.UI.Color(1,0.77,0.64,0.22));
	self.toggleOpacityInd:SetText(Settings.ToggleOpacity);

	self.instrLabel = Turbine.UI.Label();
	self.instrLabel:SetParent(self);
	self.instrLabel:SetPosition(20,270);
	self.instrLabel:SetWidth(300);
	self.instrLabel:SetForeColor(Turbine.UI.Color(1,0.77,0.64,0.22));
	self.instrLabel:SetFont( Turbine.UI.Lotro.Font.TrajanPro16 );
	self.instrLabel:SetText(Strings["ui_instr"]);
	
	--Instrument bar visibility checkbox
	self.instrCheck = Turbine.UI.Lotro.CheckBox();
	self.instrCheck:SetParent( self );
	self.instrCheck:SetPosition(20, 290);
	self.instrCheck:SetSize(300,20);
	self.instrCheck:SetText(" " .. Strings["cb_instrvis"]);
	
	if (CharSettings.InstrSlots["visible"] == "yes") then
		self.instrCheck:SetChecked(true);
	else
		self.instrCheck:SetChecked(false);
	end
	self.instrCheck.CheckedChanged = function(sender, args)
		JukeboxWindow:ToggleInstrSlots();
	end	

	
	-- clear slots button
	self.clrSlotsBtn = Turbine.UI.Lotro.Button();
	self.clrSlotsBtn:SetParent(self);
	self.clrSlotsBtn:SetPosition(20,315);
	self.clrSlotsBtn:SetSize(155,20);
	self.clrSlotsBtn:SetText(Strings["ui_clr_slots"]);
	
	self.clrSlotsBtn.MouseDown = function(sender,args)
		JukeboxWindow:ClearSlots();
	end
	
	-- add / remove slots
	self.addSlotBtn = Turbine.UI.Lotro.Button();
	self.addSlotBtn:SetParent(self);
	self.addSlotBtn:SetPosition(180,315);
	self.addSlotBtn:SetSize(85,20);
	self.addSlotBtn:SetText(Strings["ui_add_slot"]);
	
	self.addSlotBtn.MouseDown = function(sender,args)
		JukeboxWindow:AddSlot();
	end
	self.delSlotBtn = Turbine.UI.Lotro.Button();
	self.delSlotBtn:SetParent(self);
	self.delSlotBtn:SetPosition(270,315);
	self.delSlotBtn:SetSize(75,20);
	self.delSlotBtn:SetText(Strings["ui_del_slot"]);
	
	self.delSlotBtn.MouseDown = function(sender,args)
		JukeboxWindow:DelSlot();
	end	
	
	-- commands label
	self.cmdLabel = Turbine.UI.Label();
	self.cmdLabel:SetParent(self);
	self.cmdLabel:SetPosition(20,345);
	self.cmdLabel:SetWidth(300);
	self.cmdLabel:SetForeColor(Turbine.UI.Color(1,0.77,0.64,0.22));
	self.cmdLabel:SetFont( Turbine.UI.Lotro.Font.TrajanPro16 );
	self.cmdLabel:SetText(Strings["ui_custom"]);
	
	self.addBtn = Turbine.UI.Lotro.Button();
	self.addBtn:SetParent(self);
	self.addBtn:SetPosition(20,365);
	self.addBtn:SetSize(85,20);
	self.addBtn:SetText(Strings["ui_cus_add"]);
	
	self.addBtn.MouseDown = function(sender,args)
		if(args.Button == Turbine.UI.MouseButton.Left) then
			self:ShowAddWindow(0);
		end
	end
	
	self.editBtn = Turbine.UI.Lotro.Button();
	self.editBtn:SetParent(self);
	self.editBtn:SetPosition(115,365);
	self.editBtn:SetSize(70,20);
	self.editBtn:SetText(Strings["ui_cus_edit"]);
	self.editBtn:SetEnabled(false);
	
	self.editBtn.MouseDown = function(sender,args)
		if(args.Button == Turbine.UI.MouseButton.Left) then
			self:ShowAddWindow(sCmd);
		end	
	end
	
	self.delBtn = Turbine.UI.Lotro.Button();
	self.delBtn:SetParent(self);
	self.delBtn:SetPosition(195,365);
	self.delBtn:SetSize(75,20);
	self.delBtn:SetText(Strings["ui_cus_del"]);
	self.delBtn:SetEnabled(false);
	
	self.delBtn.MouseDown = function(sender,args)
		if(args.Button == Turbine.UI.MouseButton.Left) then
			self.cmdlistBox:RemoveItemAt(sCmd);
			local size = self:CountCmds();
			for i=sCmd,size do
				if (i == size) then
					Settings.Commands[tostring(i)] = nil;
				else					
					Settings.Commands[tostring(i)].Title = Settings.Commands[tostring(i+1)].Title;
					Settings.Commands[tostring(i)].Command = Settings.Commands[tostring(i+1)].Command;
				end
			end
			
			sCmd = 0;
	
			self.editBtn:SetEnabled(false);
			self.delBtn:SetEnabled(false);
		end	
	end
	
	self.listFrame = Turbine.UI.Control();
	self.listFrame:SetParent(self);
	self.listFrame:SetPosition(20, 395);
	self.listFrame:SetSize(self:GetWidth() - 40, 99);
	self.listFrame:SetBackColor(Turbine.UI.Color(1, 0.15, 0.15, 0.15));
	
	self.listFrame.heading = Turbine.UI.Label();
	self.listFrame.heading:SetParent( self.listFrame );
	self.listFrame.heading:SetLeft(0);
	self.listFrame.heading:SetSize(100,13);
	self.listFrame.heading:SetFont( Turbine.UI.Lotro.Font.TrajanPro13 );
	self.listFrame.heading:SetText( Strings["ui_cmds"] );
	
	self.listBg = Turbine.UI.Control();
	self.listBg:SetParent(self.listFrame);
	self.listBg:SetPosition(0,15);
	self.listBg:SetSize(self.listFrame:GetWidth() - 19, self.listFrame:GetHeight() - 19);
	self.listBg:SetBackColor(Turbine.UI.Color(1, 0, 0, 0));
	
	self.cmdlistBox = Turbine.UI.ListBox();
	self.cmdlistBox:SetParent(self.listFrame);
	self.cmdlistBox:SetPosition(5,15);
	self.cmdlistBox:SetSize(self.listFrame:GetWidth() - 23,self.listFrame:GetHeight() - 19);
	
	self:RefreshCmds();
	
	self.cmdScroll = Turbine.UI.Lotro.ScrollBar();
	self.cmdScroll:SetParent(self);
	self.cmdScroll:SetOrientation( Turbine.UI.Orientation.Vertical );	
	self.cmdScroll:SetPosition(self.listFrame:GetLeft() + self.listFrame:GetWidth() -12, self.listFrame:GetTop() + 13);
	self.cmdScroll:SetSize(10,self.cmdlistBox:GetHeight());
	self.cmdScroll:SetValue(0);
	self.cmdlistBox:SetVerticalScrollBar( self.cmdScroll );	
	self.cmdScroll:SetVisible( false );	
	
	self.cmdlistBox.SelectedIndexChanged = function(sender,args)
		self:ChangeCmd(sender:GetSelectedIndex());
	end
	
	
	function self:ChangeVisibility()
		if (Settings.WindowVisible == "yes") then
			Settings.WindowVisible = "no";			
		else
			Settings.WindowVisible = "yes";
		end
	end
	
	function self:ChangeToggleVisibility()
		if (Settings.ToggleVisible == "yes") then
			Settings.ToggleVisible = "no";
			toggleWindow:SetVisible(false);
		else
			Settings.ToggleVisible = "yes";
			toggleWindow:SetVisible(true);
		end
	end
	
	function self:ChangeCmd(cmdId)
		self.editBtn:SetEnabled(true);
		self.delBtn:SetEnabled(true);
		local selectedItem = self.cmdlistBox:GetItem(cmdId);
		sCmd = cmdId;
		self:SetCmdFocus(sCmd);
	end
	
	function self:SetCmdFocus(cmdId)
		for i = 1,self.cmdlistBox:GetItemCount() do
			local item = self.cmdlistBox:GetItem(i);
			if (i == cmdId) then
				item:SetForeColor( Turbine.UI.Color(1, 0.15, 0.95, 0.15) );
			else
				item:SetForeColor( Turbine.UI.Color(1, 1, 1, 1) );
			end
		end		
	end
	
	self.saveBtn = Turbine.UI.Lotro.Button();
	self.saveBtn:SetParent(self);
	self.saveBtn:SetPosition(self:GetWidth()/2-50,self:GetHeight()-35);
	self.saveBtn:SetSize(100,20);	
	self.saveBtn:SetText(Strings["ui_save"]);
	self.saveBtn.MouseDown = function(sender,args)
		if(args.Button == Turbine.UI.MouseButton.Left) then
			JukeboxWindow:SaveSettings();
			self:SetVisible(false);
		end
	end
	
	function self:ShowAddWindow(cmdId)		
		self.addWindow = Turbine.UI.Lotro.Window();
		self.addWindow:SetPosition( self:GetLeft() - 50, self:GetTop() + 50);
		self.addWindow:SetSize( 315, 300 );
		self.addWindow:SetZOrder(21);
		self.addWindow:SetVisible(true);
		
		if (cmdId == 0) then
			self.addWindow:SetText(Strings["ui_cus_winadd"]);
		else
			self.addWindow:SetText(Strings["ui_cus_winedit"]);
		end

		--title label
		self.addWindow.titleLabel = Turbine.UI.Label();
		self.addWindow.titleLabel:SetParent(self.addWindow);
		self.addWindow.titleLabel:SetPosition(20,45);
		self.addWindow.titleLabel:SetSize(100,20);
		self.addWindow.titleLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14);
		self.addWindow.titleLabel:SetText(Strings["ui_cus_title"]);
		
		--text input for command title
		self.addWindow.titleInput = Turbine.UI.Lotro.TextBox();
		self.addWindow.titleInput:SetParent(self.addWindow);
		self.addWindow.titleInput:SetPosition(20,60);
		self.addWindow.titleInput:SetSize(270,20);
		self.addWindow.titleInput:SetMultiline(false);
		self.addWindow.titleInput:SetFont(Turbine.UI.Lotro.Font.Verdana14);
		if (cmdId == 0) then
			self.addWindow.titleInput:SetText("");			
		else
			self.addWindow.titleInput:SetText(Settings.Commands[tostring(cmdId)].Title);
		end
		
		--title label
		self.addWindow.editLabel = Turbine.UI.Label();
		self.addWindow.editLabel:SetParent(self.addWindow);
		self.addWindow.editLabel:SetPosition(20,85);
		self.addWindow.editLabel:SetSize(100,20);
		self.addWindow.editLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14);
		self.addWindow.editLabel:SetText(Strings["ui_cus_command"]);
		
		--text input for command title
		self.addWindow.editInput = Turbine.UI.Lotro.TextBox();
		self.addWindow.editInput:SetParent(self.addWindow);
		self.addWindow.editInput:SetPosition(20,100);
		self.addWindow.editInput:SetSize(270,20);
		self.addWindow.editInput:SetMultiline(false);
		self.addWindow.editInput:SetFont(Turbine.UI.Lotro.Font.Verdana14);
		if (cmdId == 0) then
			self.addWindow.editInput:SetText("");			
		else
			self.addWindow.editInput:SetText(Settings.Commands[tostring(cmdId)].Command);
		end

		--ok button for saving
		self.addWindow.okBtn = Turbine.UI.Lotro.Button();
		self.addWindow.okBtn:SetParent(self.addWindow);
		self.addWindow.okBtn:SetPosition(20,130);
		self.addWindow.okBtn:SetSize(100,20);
		self.addWindow.okBtn:SetText(Strings["ui_ok"]);
		
		self.addWindow.error = Turbine.UI.Label();
		self.addWindow.error:SetParent(self.addWindow);
		self.addWindow.error:SetPosition(20,260);
		self.addWindow.error:SetSize(280,50);
		self.addWindow.error:SetForeColor(Turbine.UI.Color(1,1,0,0));
		self.addWindow.error:SetText("");
		
		
		self.addWindow.okBtn.MouseDown = function(sender,args)
			if(args.Button == Turbine.UI.MouseButton.Left) then
				if (self.addWindow.titleInput:GetText() ~= "" and self.addWindow.editInput:GetText() ~= "") then
					if (cmdId == 0) then
						newId = tostring(self:CountCmds()+1);
						Settings.Commands[newId] = {};
						Settings.Commands[newId].Title = self.addWindow.titleInput:GetText();	
						Settings.Commands[newId].Command = self.addWindow.editInput:GetText();					
					else
						cmdId = tostring(cmdId);
						Settings.Commands[tostring(cmdId)].Title = self.addWindow.titleInput:GetText();					
						Settings.Commands[tostring(cmdId)].Command = self.addWindow.editInput:GetText();					
					end
					
					self.addWindow.error:SetText("");
					self.addWindow:Close();		
					self:RefreshCmds();		
				else
					self.addWindow.error:SetText(Strings["ui_cus_err"]);
				end
			end
		end
		
		
		--cancel button		
		self.addWindow.cancelBtn = Turbine.UI.Lotro.Button();
		self.addWindow.cancelBtn:SetParent(self.addWindow);
		self.addWindow.cancelBtn:SetPosition(150,130);
		self.addWindow.cancelBtn:SetSize(100,20);
		self.addWindow.cancelBtn:SetText(Strings["ui_cancel"]);
		
		self.addWindow.cancelBtn.MouseDown = function(sender,args)
			if(args.Button == Turbine.UI.MouseButton.Left) then
				self.addWindow.error:SetText("");
				self.addWindow:Close();
			end
		end
		
		self.addWindow.help = Turbine.UI.Label();
		self.addWindow.help:SetParent(self.addWindow);
		self.addWindow.help:SetPosition(20,170);
		self.addWindow.help:SetSize(300, 200);
		self.addWindow.help:SetFont(Turbine.UI.Lotro.Font.Verdana14);
		self.addWindow.help:SetText(Strings["ui_cus_help"]);
		
	end
	
end

function SettingsWindow:RefreshCmds()
	local size = self.cmdlistBox:GetItemCount();	
	self.cmdlistBox:ClearItems();
	
	for i=1,self:CountCmds() do
		local cmdItem = Turbine.UI.Label();
		cmdItem:SetText(Settings.Commands[tostring(i)].Title);		
		cmdItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
		cmdItem:SetSize( 1000, 20 );				
		self.cmdlistBox:AddItem( cmdItem );	
	end
	sCmd = 0;
	
	self.editBtn:SetEnabled(false);
	self.delBtn:SetEnabled(false);
end

function SettingsWindow:CountCmds()
	local cSize = 0;
	for k, v in pairs(Settings.Commands) do 
		cSize = cSize + 1;
	end
	return cSize;
end

