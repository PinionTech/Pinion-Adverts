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
	1.5.2 <-> 2012 - 7/14 gH0sTy
		Don't replace custom VGUI Menues
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
#pragma semicolon 1

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
#define PLUGIN_VERSION "1.5-P"
public Plugin:myinfo =
{
	name = "Pinion Adverts",
	author = "LumiStance",
	description = "Replaces MOTD with Pinion adverts",
	version = PLUGIN_VERSION,
	url = "http://srcds.lumistance.com/"
};

// MOTD specific
new UserMsg:vgui;
new bool:g_FreeNextVGUI;
new bool:g_bFirstMOTD[MAXPLAYERS+1] = false;
// Game detection
new bool:g_L4D = false;
new bool:g_L4D2 = false; //Detecting both separately
// Delay
new Handle:g_Timers[MAXPLAYERS+1];
// Console Variables
new Handle:g_ConVar_URL;
new Handle:g_ConVar_contentURL;
// Configuration
new String:g_BaseURL[PLATFORM_MAX_PATH];
new Handle:g_ConVar_motdfile;
new Handle:g_ConVar_Version;
// Configuration
new String:g_motdfile[PLATFORM_MAX_PATH];
new String:g_URL[PLATFORM_MAX_PATH];
new g_motdTimeStamp = -1;

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

	// Game Detection
	new String:gdir[16];
	GetGameFolderName(gdir, sizeof(gdir));
	
	g_L4D = StrEqual(gdir, "left4dead");
	g_L4D2 = StrEqual(gdir, "left4dead2");
	
	
	// Specify console variables used to configure plugin
	g_ConVar_motdfile = FindConVar("motdfile");
	g_ConVar_contentURL = CreateConVar("sm_motdredirect_url", "", "Target URL to write into motdfile", FCVAR_PLUGIN|FCVAR_SPONLY);
	AutoExecConfig(true, "pinion_adverts");

	// Version of plugin - Make visible to game-monitor.com - Dont store in configuration file
	g_ConVar_Version = CreateConVar("sm_motdredirect_version", PLUGIN_VERSION, "[SM] MOTD Redirect Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	// More event hooks for the config files
	HookConVarChange(g_ConVar_motdfile, Event_CvarChange);
	HookConVarChange(g_ConVar_contentURL, Event_CvarChange);
}

// Occurs after round_start
public OnConfigsExecuted()
{
	// Synchronize Cvar Cache after configuration loaded
	RefreshCvarCache();
	// Override config file and work around A2S_RULES bug in linux orange box
	SetConVarString(g_ConVar_Version, PLUGIN_VERSION);
}

public OnClientConnected(client)
{
	g_bFirstMOTD[client] = true;
}
public OnClientDisconnect(client)
{
	g_bFirstMOTD[client] = false;
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
/*
// Player Chose Team - Cause page hit
public Event_PlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetEventInt(event, "team") >= 1)
		CreateTimer(0.1, Event_DoPageHit, GetEventInt(event, "userid"));
}*/

public Action:Event_DoPageHit(Handle:timer, any:user_index)
{
	// This event implies client is in-game while GetClientOfUserId() checks IsClientConnected()
	new client_index = GetClientOfUserId(user_index);
	if (client_index && !IsFakeClient(client_index))
	{
		//PrintToServer("Page Hit for %d", client_index);
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

	decl String:buffer[64];
	decl String:buffer2[256];
	
	BfReadString(bf, buffer, sizeof(buffer));
	if (strcmp(buffer, "info") != 0)
		return Plugin_Continue;
	
	new count = BfReadByte(bf);
	//Psychonic's plugin was very helpful in learning how to block the right VGUI menu	
	//https://forums.alliedmods.net/showthread.php?t=147193	
	
	if (count == 0 || !g_bFirstMOTD[players[0]])
		return Plugin_Continue;
	
	new Handle:kv = CreateKeyValues("data");
	for (new i = 0; i < count; i++)
	{
		BfReadString(bf, buffer, sizeof(buffer));
		BfReadString(bf, buffer2, sizeof(buffer2));
		
		if (strcmp(buffer, "customsvr") == 0 || (strcmp(buffer, "msg") == 0 && strcmp(buffer2, "motd") != 0))
		{
			CloseHandle(kv);
			return Plugin_Continue;
		}
		
		KvSetString(kv, buffer, buffer2);
	}
	
	new Handle:pack;
	g_Timers[players[0]] = CreateDataTimer(0.1, LoadPage, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, GetClientUserId(players[0]));
	WritePackCell(pack, _:kv);
	
	//PrintToServer("Calling it for %d", players[0]);

	return Plugin_Handled;
}

public Action:PageClosed(client, const String:command[], argc)
{
	g_FreeNextVGUI = true;	

	//keeping this in userid form incase we still need to hook events in the future for some games
	new userid = GetClientUserId(client); 
	CreateTimer(0.1, Event_DoPageHit, userid);

}

public Action:LoadPage(Handle:hTimer, Handle:pack)
//public Action:LoadPage(client)
{
	ResetPack(pack);
	new client = GetClientOfUserId(ReadPackCell(pack));
	new Handle:kv = Handle:ReadPackCell(pack);
	
	g_bFirstMOTD[client] = false;
	g_Timers[client] = INVALID_HANDLE;

	decl String:URL[128];
	GetConVarString(g_ConVar_contentURL, URL, sizeof(URL));

	//new Handle:kv = CreateKeyValues("data");

	if ((g_L4D2) || (g_L4D))
	{
		KvSetString(kv, "cmd", "closed_htmlpage");
	}
	else
	KvSetNum(kv, "cmd", MOTDPANEL_CMD_CLOSED_HTMLPAGE);

	KvSetString(kv, "msg",	URL);
	KvSetNum(kv,    "type",    MOTDPANEL_TYPE_URL);

	g_FreeNextVGUI = true;

	if (client != 0)
		ShowVGUIPanel(client, "info", kv, true);

	CloseHandle(kv);

	return Plugin_Stop;
}