import "Turbine.UI";
import "Turbine.UI.Lotro";
import "Nathan.Jukebox.Class"; -- Turbine library included so that there's no outside dependencies
import "Nathan.Jukebox.ToggleWindow";
import "Nathan.Jukebox.SettingsWindow";
import "Nathan.Jukebox.JukeboxBackground";
import "Nathan.Jukebox.JukeboxLang";
import "Nathan.Jukebox";

JukeboxWindow = Nathan.Jukebox.JukeboxWindow();
if (Settings.WindowVisible == "yes") then
	JukeboxWindow:SetVisible( true );
else
	JukeboxWindow:SetVisible( false );
end

settingsWindow = Nathan.Jukebox.SettingsWindow();
settingsWindow:SetVisible( false );

toggleWindow = Nathan.Jukebox.ToggleWindow();
if (Settings.ToggleVisible == "yes") then
	toggleWindow:SetVisible( true );
else 
	toggleWindow:SetVisible( false );
end

JukeboxCommand = Turbine.ShellCommand();

function JukeboxCommand:Execute(cmd, args)
	if ( args == Strings["sh_show"] ) then
		JukeboxWindow:SetVisible( true );
	elseif ( args == Strings["sh_hide"] ) then
		JukeboxWindow:SetVisible( false );
	elseif ( args == Strings["sh_toggle"] ) then
		JukeboxWindow:SetVisible( not JukeboxWindow:IsVisible() );
	elseif ( args ~= nil ) then
		JukeboxCommand:GetHelp();
	end
end

function JukeboxCommand:GetHelp()
	Turbine.Shell.WriteLine( Strings["sh_help1"] );
	Turbine.Shell.WriteLine( Strings["sh_help2"] );
	Turbine.Shell.WriteLine( Strings["sh_help3"] );
end

Turbine.Shell.AddCommand( "Jukebox", JukeboxCommand );
Turbine.Shell.WriteLine("Jukebox v"..Plugins["Jukebox"]:GetVersion().." by Nathan");
