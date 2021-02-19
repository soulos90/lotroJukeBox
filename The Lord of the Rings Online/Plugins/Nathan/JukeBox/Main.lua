import "Turbine";
import "Turbine.Gameplay";
import "Turbine.UI";
import "Turbine.UI.Lotro";
import "Nathan.JukeBox.Class"; -- Turbine library included so that there's no outside dependencies
import "Nathan.JukeBox.ToggleWindow";
import "Nathan.JukeBox.SettingsWindow";
import "Nathan.JukeBox.JukeBoxLang";
import "Nathan.JukeBox";

JukeBoxWindow = Nathan.JukeBox.JukeBoxWindow();
if (Settings.WindowVisible == "yes") then
	JukeBoxWindow:SetVisible( true );
else
	JukeBoxWindow:SetVisible( false );
end
settingsWindow = Nathan.JukeBox.SettingsWindow();
settingsWindow:SetVisible( false );

toggleWindow = Nathan.JukeBox.ToggleWindow();
if (Settings.ToggleVisible == "yes") then
	toggleWindow:SetVisible( true );
else 
	toggleWindow:SetVisible( false );
end

JukeBoxCommand = Turbine.ShellCommand();

function JukeBoxCommand:Execute(cmd, args)
	if ( args == Strings["sh_show"] ) then
		JukeBoxWindow:SetVisible( true );
	elseif ( args == Strings["sh_hide"] ) then
		JukeBoxWindow:SetVisible( false );
	elseif ( args == Strings["sh_toggle"] ) then
		JukeBoxWindow:SetVisible( not JukeBoxWindow:IsVisible() );
	elseif ( args ~= nil ) then
		JukeBoxCommand:GetHelp();
	end
end

function JukeBoxCommand:GetHelp()
	Turbine.Shell.WriteLine( Strings["sh_help1"] );
	Turbine.Shell.WriteLine( Strings["sh_help2"] );
	Turbine.Shell.WriteLine( Strings["sh_help3"] );
end

Turbine.Shell.AddCommand( "JukeBox", JukeBoxCommand );
Turbine.Shell.WriteLine("JukeBox v"..Plugins["JukeBox"]:GetVersion().." by Nathan");
