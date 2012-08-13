/* pinion_adverts.sp
Name: Pinion Adverts
Author: LumiStance / Pinion
Contributors: Azelphur
Date: 2012 - 20/02

Description:
	Causes client to access a webpage when player has chosen a team.  Left 4 Dead will use
	player left start area / checkpoint.  The url will have have /host_ip/hostport/steamid
	added to it.  

Installation:
	Place compiled plugin (pinion_adverts.smx) into your plugins folder.
	The configuration file (pinion_adverts.cfg) is generated automatically.
	Changes to motdpagehit.cfg are read at map/plugin load time.
	Changes to cvars made in console take effect immediately.

Upgrade Notes:
	Renamed sm_motdpagehit_spawnurl to sm_motdpagehit_url as of v1.3; modify pinion_adverts.cfg appropriately.

Files:
	cstrike/addons/sourcemod/plugins/pinion_adverts.smx
	cstrike/cfg/sourcemod/pinion_adverts.cfg

Configuration Variables (Change in motdpagehit.cfg):
	sm_motdpagehit_url - The URL accessed on player event

Changelog
	1.8-pre <-> 2012 - Nicholas Hastings
		Updated game detection.
	1.7 <-> 2012 - 8/8 Mana (unreleased)
		Changed MOTD skip cvar to Enable/Disable option only
		Added a message notifying players when they can close the MOTD
		Integrated ForceHTML Plugin:
		http://forums.alliedmods.net/showthread.php?t=172864
	1.6 <-> 2012 - 8/1 Mana (unreleased)
		Added a cooldown option for skipping the MOTD.
		Defaults to 5 seconds of not being able to "close" the MOTD.
		Added a code option of only hooking the first MOTD, incase it conflicts with other plugins
	1.5.1 <-> 2012 - 5/24 Sam Gentle
		Made the MOTD hit use a javascript: url
	1.5 <-> 2012 - 5/24 Mana
		Removed event hooks, no longer neccesary
		Blocks current MOTD and replaces it a new
		Hooks MOTD closed button
		Plugin now works immediately after being loaded
		Left legacy code for writing MOTD to file (incase updates break sourcemod)
	1.4.2 <-> 2012 - 20/02 Azelphur
		Stop adverts when players join the spectator team
	1.4.1 <-> 2011 - 08/09 LumiStanc
		Add version CVA
	1.4 <-> 2011 - 08/05 David Banha
		Integrated code to update motd.txt config file
		Changed variable names as appropriat
		Changed config file name
	1.3 <-> 2011 - 07/24 LumiStance
		Add host ip and port to url, add auth_id
		Rename cvar to sm_motdpagehit_url
		Add L4D hook for player_left_checkpoint
		Change player_spawn to player_team for CSS and TF2
		Have separate hook callbacks for L4D and CSS/TF2
	1.2 <-> 2011 - 07/09 LumiStance
		Improve support for TF2 (v1.1 interferes with join sequence)
		Add Event_HandleSpawn delayed response
		Add checks for IsClientConnected(), GetClientTeam(), and IsFakeClient()
	1.1 <-> 2011 - 07/08 LumiStance
		Add code to hook player_left_start_area if it exists instead of player_spawn
	1.0 <-> 2011 - 07/08 LumiStance
		Initial Version
		Modify ShowHiddenMOTDPanel into more generic ShowMOTDPanelEx
		Add enum constants for ShowMOTDPanelEx command parameter
		Add code and url cvar for ShowMOTDPanelEx at player_spawn
*/

#include <sourcemod>
#include <sdktools>
#include <colors>

#pragma semicolon 1

#define TEAM_SPEC 1


new g_iTeam[MAXPLAYERS + 1];
new bool:g_bLoaded[MAXPLAYERS + 1];
new bool:g_bDisabled[MAXPLAYERS + 1];
new Handle:g_hTimer_Notify[MAXPLAYERS + 1];
new Handle:g_hTimer_Query[MAXPLAYERS + 1];

new Handle:g_hEnabled = INVALID_HANDLE;
new Handle:g_hRate = INVALID_HANDLE;
new Handle:g_hFlag = INVALID_HANDLE;

new g_iFlag;
new Float:g_fRate;
new bool:g_bLateLoad, bool:g_bEnabled;
new String:g_sPrefixChat[32], String:g_sPrefixCenter[32];

enum
{
	MOTDPANEL_CMD_NONE,
	MOTDPANEL_CMD_JOIN,
	MOTDPANEL_CMD_CHANGE_TEAM,
	MOTDPANEL_CMD_IMPULSE_101,
	MOTDPANEL_CMD_MAPINFO,
	MOTDPANEL_CMD_CLOSED_HTMLPAGE,
	MOTDPANEL_CMD_CHOOSE_TEAM,
};

// Plugin definitions
#define PLUGIN_VERSION "1.8-pre"
public Plugin:myinfo =
{
	name = "Pinion Adverts",
	author = "Multiple contributors",
	description = "Pinion in-game advertisements helper",
	version = PLUGIN_VERSION,
	url = "http://www.pinion.gg/"
};

// MOTD specific
new UserMsg:vgui;
new bool:g_FreeNextVGUI;
// Game detection
enum EGame
{
	kGameUnsupported = -1,
	kGameCSS,
	kGameHL2DM,
	kGameDODS,
	kGameTF2,
	kGameL4D,
	kGameL4D2,
	kGameND,
};
new const String:g_SupportedGames[EGame][] = {
	"cstrike",
	"hl2mp",
	"dod",
	"tf",
	"left4dead",
	"left4dead2",
	"nucleardawn"
};
new EGame:g_Game = kGameUnsupported;
// Delay
new Handle:g_Timers[MAXPLAYERS+1];
// Only hook the first MOTD
new bool:g_FirstMOTD[MAXPLAYERS+1];
// Console Variables
new Handle:g_ConVar_URL;
new Handle:g_ConVar_contentURL;
new Handle:g_ConVarCooldown;
// Configuration
new String:g_BaseURL[PLATFORM_MAX_PATH];
new Handle:g_ConVar_motdfile;
new Handle:g_ConVar_Version;
// Configuration
new String:g_motdfile[PLATFORM_MAX_PATH];
new String:g_URL[PLATFORM_MAX_PATH];
new g_motdTimeStamp = -1;
// Cooldown Timer
new Handle:CooldownTimer[MAXPLAYERS+1];
new bool:ContinueDisabled[MAXPLAYERS+1];

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	// Game Detection
	decl String:szGameDir[32];
	GetGameFolderName(szGameDir, sizeof(szGameDir));
	UTIL_StringToLower(szGameDir);
	
	for (new i = 0; i < sizeof(g_SupportedGames); ++i)
	{
		if (!strcmp(szGameDir, g_SupportedGames[i]))
		{
			g_Game = EGame:i;
			break;
		}
	}
	
	if (g_Game == kGameUnsupported)
	{
		strcopy(error, err_max, "This game is currently not supported. To request support, contact us at http://www.pinion.gg/contact.html");
		return APLRes_Failure;
	}
	
	g_bLateLoad = late;
	
	return APLRes_Success;
}

// Configure Environment
public OnPluginStart()
{
	// Catch the MOTD
	vgui = GetUserMessageId("VGUIMenu");
	HookUserMessage(vgui, OnMsgVGUIMenu, true);

	// Hook the MOTD OK button
	AddCommandListener(PageClosed, "closed_htmlpage");

	// Specify console variables used to configure plugin
	g_ConVar_URL = CreateConVar("sm_motdpagehit_url", "", "URL to access on player event", FCVAR_PLUGIN|FCVAR_SPONLY);
	AutoExecConfig(true, "pinion_adverts");

	// Event Hooks
	HookConVarChange(g_ConVar_URL, Event_CvarChange);	
	
	// Specify console variables used to configure plugin
	g_ConVar_motdfile = FindConVar("motdfile");
	g_ConVar_contentURL = CreateConVar("sm_motdredirect_url", "", "Target URL to write into motdfile", FCVAR_PLUGIN|FCVAR_SPONLY);
	g_ConVarCooldown = CreateConVar("sm_motdredirect_force_min_duration", "1", "Prevent the MOTD from being closed for 5 seconds.");
	AutoExecConfig(true, "pinion_adverts");

	// Version of plugin - Make visible to game-monitor.com - Dont store in configuration file
	g_ConVar_Version = CreateConVar("sm_motdredirect_version", PLUGIN_VERSION, "[SM] MOTD Redirect Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	// More event hooks for the config files
	HookConVarChange(g_ConVar_motdfile, Event_CvarChange);
	HookConVarChange(g_ConVar_contentURL, Event_CvarChange);

	//Force HTML plugin
	LoadTranslations("common.phrases");
	LoadTranslations("sm_force_html_motd.phrases");

	CreateConVar("sm_force_html_motd_version", PLUGIN_VERSION, "Force HTML MOTDs: Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_hEnabled = CreateConVar("sm_force_html_motd_enable", "1", "Enables/disables all features of the plugin.", FCVAR_NONE, true, 0.0, true, 1.0);
	HookConVarChange(g_hEnabled, OnSettingsChange);
	g_hRate = CreateConVar("sm_force_html_motd_rate", "1.0", "How often the query runs to check client cvar values.", FCVAR_NONE, true, 1.0);
	HookConVarChange(g_hRate, OnSettingsChange);
	g_hFlag = CreateConVar("sm_force_html_motd_flag", "z", "Individuals that possess this flag, or the \"Allow_Html_Motd\" override, will not be checked by this plugin. (\"\" = Disabled)", FCVAR_NONE);
	HookConVarChange(g_hFlag, OnSettingsChange);
	AutoExecConfig(true, "sm_force_html_motd");

	RegConsoleCmd("sm_motdhelp", Command_Help);
	HookEvent("player_team", Event_OnPlayerTeam, EventHookMode_Pre);

	if (g_Game == kGameCSS)
	{
		AddCommandListener(Command_Join, "jointeam");
		AddCommandListener(Command_Join, "joinclass");
	}
	
	g_bEnabled = GetConVarBool(g_hEnabled);
	g_fRate = GetConVarFloat(g_hRate);
	
	decl String:szBuffer[32];
	GetConVarString(g_hFlag, szBuffer, sizeof(szBuffer));
	g_iFlag = szBuffer[0] ? ReadFlagString(szBuffer) : 0;
}

// Occurs after round_start
public OnConfigsExecuted()
{
	// Synchronize Cvar Cache after configuration loaded
	RefreshCvarCache();
	// Override config file and work around A2S_RULES bug in linux orange box
	SetConVarString(g_ConVar_Version, PLUGIN_VERSION);

	if(g_bEnabled)
	{
		Format(g_sPrefixChat, sizeof(g_sPrefixChat), "%T", "Prefix_Chat", LANG_SERVER);
		Format(g_sPrefixCenter, sizeof(g_sPrefixCenter), "%T", "Prefix_Center", LANG_SERVER);

		if(g_bLateLoad)
		{
			for(new i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && !IsFakeClient(i))
				{
					g_iTeam[i] = GetClientTeam(i);
					if(!g_iFlag || !CheckCommandAccess(i, "Allow_Html_Motds", g_iFlag))
						g_hTimer_Query[i] = CreateTimer(g_fRate, Timer_QueryClient, i);
				}	
			}
			
			g_bLateLoad = false;
		}
	}
}

// Synchronize Cvar Cache when change made
public Event_CvarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	RefreshCvarCache();
	// Contents of motd file now invalid
	g_motdTimeStamp = -1;
}

stock RefreshCvarCache()
{
	// Build and cache url/ip/port string
	GetConVarString(g_ConVar_URL, g_BaseURL, sizeof(g_BaseURL));
	new hostip = GetConVarInt(FindConVar("hostip"));
	new hostport = GetConVarInt(FindConVar("hostport"));
	Format(g_BaseURL, sizeof(g_BaseURL), "%s/%i.%i.%i.%i/%i/", g_BaseURL,
		hostip >>> 24 & 255, hostip >>> 16 & 255, hostip >>> 8 & 255, hostip & 255, hostport);

	GetConVarString(g_ConVar_motdfile, g_motdfile, sizeof(g_motdfile));
	GetConVarString(g_ConVar_contentURL, g_URL, sizeof(g_URL));

	new timestamp = GetFileTime(g_motdfile, FileTime_LastChange);
	if (g_URL[0] && (g_motdTimeStamp == -1 || g_motdTimeStamp != timestamp))
	{
		new Handle:fileh = OpenFile(g_motdfile, "w");
		if (fileh == INVALID_HANDLE)
			SetFailState("[lm]Could not open \"%s\"", g_motdfile);
		else
		{
			WriteFileLine(fileh, g_URL);
			CloseHandle(fileh);

			g_motdTimeStamp = GetFileTime(g_motdfile, FileTime_LastChange);
		}
	}
}

public OnClientPostAdminCheck(client)
{
	g_FirstMOTD[client] = false;

	if(g_bEnabled)
	{
		if(IsClientInGame(client) && !IsFakeClient(client))
			if(!g_iFlag || !CheckCommandAccess(client, "Allow_Html_Motds", g_iFlag))
				g_hTimer_Query[client] = CreateTimer(g_fRate, Timer_QueryClient, client);
	}
}

public Action:Event_DoPageHit(Handle:timer, any:user_index)
{
	// This event implies client is in-game while GetClientOfUserId() checks IsClientConnected()
	new client_index = GetClientOfUserId(user_index);
	if (client_index && !IsFakeClient(client_index))
	{
		decl String:auth[PLATFORM_MAX_PATH];
		decl String:url[PLATFORM_MAX_PATH];
		
		GetClientAuthString(client_index, auth, sizeof(auth));
		
		Format(url, sizeof(url), "javascript:pingTracker('%s%s')", g_BaseURL, auth);

		ShowMOTDPanelEx(client_index, "", url, MOTDPANEL_TYPE_URL, MOTDPANEL_CMD_NONE, false);
	}
}

// Extended ShowMOTDPanel with options for Command and Show
stock ShowMOTDPanelEx(client, const String:title[], const String:msg[], type=MOTDPANEL_TYPE_INDEX, cmd=MOTDPANEL_CMD_NONE, bool:show=true)
{
	decl String:szType[3];
	new Handle:Kv = CreateKeyValues("data");
	IntToString(type, szType, sizeof(szType));

	KvSetString(Kv, "title", title);
	KvSetString(Kv, "type", szType);
	KvSetString(Kv, "msg", msg);
	KvSetNum(Kv, "cmd", cmd);	//http://forums.alliedmods.net/showthread.php?p=1220212
	ShowVGUIPanel(client, "info", Kv, show);
	CloseHandle(Kv);
}


public Action:OnMsgVGUIMenu(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init)
{
	if (g_FreeNextVGUI)
	{
		g_FreeNextVGUI = false;
		return Plugin_Continue;
	}

	if(!g_FirstMOTD[players[0]])
	{
		return Plugin_Continue;
	}

	decl String:buffer[64];
	BfReadString(bf, buffer, sizeof(buffer));
	if (strcmp(buffer, "info") != 0)
		return Plugin_Continue;
	
	PrintToServer("Calling it for %d", players[0]);
	g_Timers[players[0]] = CreateTimer(0.1, LoadPage, players[0]);

	return Plugin_Handled;
}

public Action:PageClosed(client, const String:command[], argc)
{
	g_FreeNextVGUI = true;
	
	g_FirstMOTD[client] = true;
	
	if(ContinueDisabled[client])
	{
		LoadPage(INVALID_HANDLE, client);
	}
	else
	{
		//keeping this in userid form incase we still need to hook events in the future for some games
		new userid = GetClientUserId(client); 
		CreateTimer(0.1, Event_DoPageHit, userid);
	}

}

public Action:LoadPage(Handle:timer, any:client)
{
	g_Timers[client] = INVALID_HANDLE;

	decl String:URL[128];
	GetConVarString(g_ConVar_contentURL, URL, sizeof(URL));

	new Handle:kv = CreateKeyValues("data");

	if (g_Game == kGameL4D || g_Game == kGameL4D2)
	{
		KvSetString(kv, "cmd", "closed_htmlpage");
	}
	else
	{
		KvSetNum(kv, "cmd", MOTDPANEL_CMD_CLOSED_HTMLPAGE);
	}

	if(!ContinueDisabled[client])
		KvSetString(kv, "msg",	URL);

	KvSetNum(kv,    "type",    MOTDPANEL_TYPE_URL);

	g_FreeNextVGUI = true;

	ShowVGUIPanel(client, "info", kv, true);
	CloseHandle(kv);

	ContinueDisabled[client] = true;
	
	if(GetConVarFloat(g_ConVarCooldown))
	{
		CooldownTimer[client] = CreateTimer(5.0, Timer_Restrict, client, TIMER_FLAG_NO_MAPCHANGE);
		PrintCenterText(client, "You can close the MOTD in 5 seconds.");
	}
	
	return Plugin_Stop;
}

public Action:Timer_Restrict(Handle:timer, any:client)
{
	ContinueDisabled[client] = false;
	CooldownTimer[client] = INVALID_HANDLE;
}

public OnClientDisconnect(client)
{
	if(g_bEnabled)
	{
		g_iTeam[client] = 0;
		g_bLoaded[client] = false;
		g_bDisabled[client] = false;
		
		if(g_hTimer_Notify[client] != INVALID_HANDLE && CloseHandle(g_hTimer_Notify[client]))
			g_hTimer_Notify[client] = INVALID_HANDLE;
		if(g_hTimer_Query[client] != INVALID_HANDLE && CloseHandle(g_hTimer_Query[client]))
			g_hTimer_Query[client] = INVALID_HANDLE;
	}
}

public Action:Command_Join(client, const String:command[], argc)
{
	if(client > 0 && IsClientInGame(client))
		if(g_bDisabled[client])
			return Plugin_Stop;

	return Plugin_Continue;
}

public Action:Timer_QueryClient(Handle:timer, any:client)
{
	g_hTimer_Query[client] = INVALID_HANDLE;
	if(IsClientInGame(client))
		QueryClientConVar(client, "cl_disablehtmlmotd", ConVar_QueryClient);

	return Plugin_Continue;
}

public ConVar_QueryClient(QueryCookie:cookie, client, ConVarQueryResult:result, const String:cvarName[], const String:cvarValue[])
{
	if(g_bEnabled && IsClientInGame(client))
	{
		if(result == ConVarQuery_Okay)
		{
			new bool:_bCurrent = StringToInt(cvarValue) ? true : false;
			if(_bCurrent != g_bDisabled[client])
			{
				g_bDisabled[client] = _bCurrent;
				if(!_bCurrent)
				{
					decl String:_sBuffer[192];
					Format(_sBuffer, sizeof(_sBuffer), "%T", "Motd_Panel_Title", client);
					ShowMOTDPanel(client, _sBuffer, "motd", MOTDPANEL_TYPE_INDEX);

					PrintCenterText(client, "%s%t", g_sPrefixCenter, "Phrase_Join_Permission");
				}
				else
				{
					ShowMenu(client);
					NotifyRestricted(client);
					g_hTimer_Notify[client] = CreateTimer(1.0, Timer_NotifyClient, client, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

					if(g_iTeam[client] > TEAM_SPEC)
						ChangeClientTeam(client, TEAM_SPEC);
				}
			}
			else if(g_bDisabled[client] && g_iTeam[client] > TEAM_SPEC)
			{
				ChangeClientTeam(client, TEAM_SPEC);
			}
		}

		g_hTimer_Query[client] = CreateTimer(g_fRate, Timer_QueryClient, client);
	}
}

public Action:Timer_NotifyClient(Handle:timer, any:client)
{
	if(IsClientInGame(client) && g_bDisabled[client])
	{
		NotifyRestricted(client);
		return Plugin_Continue;
	}

	g_hTimer_Notify[client] = INVALID_HANDLE;
	return Plugin_Stop;
}

NotifyRestricted(client)
{
	PrintCenterText(client, "%s%t", g_sPrefixCenter, "Phrase_Join_Restricted");
}

public Action:Event_OnPlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(g_bEnabled)
	{
		new userid = GetEventInt(event, "userid");
		new client = GetClientOfUserId(userid);
		if(client <= 0 || !IsClientInGame(client))
			return Plugin_Continue;

		g_iTeam[client] = GetEventInt(event, "team");
		if(g_bDisabled[client])
		{
			if(g_iTeam[client] > TEAM_SPEC)
			{
				ChangeClientTeam(client, TEAM_SPEC);
				CreateTimer(0.1, Timer_ConfirmSpectate, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			}

			dontBroadcast = true;
			SetEventBroadcast(event, true);
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

public Action:Timer_ConfirmSpectate(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if(client > 0 && IsClientInGame(client))
		if(g_iTeam[client] > TEAM_SPEC)
			ChangeClientTeam(client, TEAM_SPEC);
	
	return Plugin_Continue;
}

public Action:Command_Help(client, args)
{	
	if(client > 0 && IsClientInGame(client) && g_bDisabled[client])
		ShowMenu(client);
	
	return Plugin_Continue;
}

ShowMenu(client)
{
	decl String:_sBuffer[128], String:_sPhase[24];

	new Handle:_hMenu = CreateMenu(MenuHandler_Main);
	Format(_sBuffer, sizeof(_sBuffer), "%T", "Menu_Title", client);
	SetMenuTitle(_hMenu, _sBuffer);
	SetMenuPagination(_hMenu, MENU_NO_PAGINATION);
	SetMenuExitBackButton(_hMenu, false);
	SetMenuExitButton(_hMenu, false);
	
	for(new i = 0; i <= 8; i++)
	{
		Format(_sPhase, sizeof(_sPhase), "Menu_Phrase_%d", i);
		Format(_sBuffer, sizeof(_sBuffer), "%T", _sPhase, client);	
		if(strlen(_sBuffer))
			AddMenuItem(_hMenu, "", _sBuffer, ITEMDRAW_DISABLED);
	}
	Format(_sBuffer, sizeof(_sBuffer), "%T", "Menu_Phrase_Exit", client);	
	AddMenuItem(_hMenu, "0", _sBuffer);

	DisplayMenu(_hMenu, client, MENU_TIME_FOREVER);
}

public MenuHandler_Main(Handle:menu, MenuAction:action, param1, param2)
{
	switch(action)
	{
		case MenuAction_End:
			CloseHandle(menu);
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_Interrupted || param2 == MenuCancel_Exit)
				if(g_bDisabled[param1])
					ShowMenu(param1);
		}
		case MenuAction_Select:
		{
			decl String:_sBuffer[4];
			GetMenuItem(menu, param2, _sBuffer, sizeof(_sBuffer));
			
			if(g_bDisabled[param1])
				ShowMenu(param1);
		}
	}
}

public OnSettingsChange(Handle:cvar, const String:oldvalue[], const String:newvalue[])
{
	if(cvar == g_hEnabled)
	{
		g_bEnabled = StringToInt(newvalue) ? true : false;
	}
	else if(cvar == g_hRate)
	{
		g_fRate = StringToFloat(newvalue);
	}
	else if(cvar == g_hFlag)
	{
		decl String:_sBuffer[32];
		strcopy(_sBuffer, sizeof(_sBuffer), newvalue);
		g_iFlag = ReadFlagString(_sBuffer);
	}
}

stock UTIL_StringToLower(String:szInput[])
{
	new i = 0, c;
	while ((c = szInput[i]) != 0)
	{
		szInput[i++] = CharToLower(c);
	}
}
