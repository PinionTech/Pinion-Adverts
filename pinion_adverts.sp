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
		Added support for CS:GO.
		Added support for "Updater" (https://forums.alliedmods.net/showthread.php?t=169095).
		Temporarily reverted ForceHTML plugin integration.
		Fixed team join issues in CS:S and DOD:S.
		Fixed player hits conflicting with some other MotD plugins.
		Specified motdfile (motd.txt) no longer gets clobbered. (!motd will show your specified MotD).
		Various other cleanup, error fixing, and error checks.
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

#undef REQUIRE_PLUGIN
#tryinclude <updater>

#pragma semicolon 1

#define TEAM_SPEC 1
#define MAX_AUTH_LENGTH 64

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
#define PLUGIN_VERSION "1.8"
public Plugin:myinfo =
{
	name = "Pinion Adverts",
	author = "Multiple contributors",
	description = "Pinion in-game advertisements helper",
	version = PLUGIN_VERSION,
	url = "http://www.pinion.gg/"
};

// Approximately 5 seconds from MotD display.
// Time starts from player_activate, a few seconds after Motd is sent, but a few seconds before it actually loads
#define WAIT_TIME 7

// Some games require a title to explicitly be set (while others don't even show the set title)
#define MOTD_TITLE "Sponsor Message"

#define UPDATE_URL "http://bin.pinion.gg/bin/pinion_adverts/updatefile.txt"

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
	kGameCSGO,
};
new const String:g_SupportedGames[EGame][] = {
	"cstrike",
	"hl2mp",
	"dod",
	"tf",
	"left4dead",
	"left4dead2",
	"nucleardawn",
	"csgo"
};
new EGame:g_Game = kGameUnsupported;
// Console Variables
new Handle:g_ConVar_URL;
new Handle:g_ConVarCooldown;
// Configuration
new String:g_BaseURL[PLATFORM_MAX_PATH];

enum EPlayerState
{
	kAwaitingAd,  // have not seen ad yet for this map
	kViewingAd,   // ad has been deplayed
	kAdClosing,   // ad is allowed to close
	kAdDone,      // done with ad for this map
}
new EPlayerState:g_PlayerState[MAXPLAYERS+1] = {kAwaitingAd, ...};
new bool:g_bPlayerActivated[MAXPLAYERS+1] = {false, ...};

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
	
	return APLRes_Success;
}

// Configure Environment
public OnPluginStart()
{
	// Catch the MOTD
	new UserMsg:VGUIMenu = GetUserMessageId("VGUIMenu");
	if (VGUIMenu == INVALID_MESSAGE_ID)
		SetFailState("Failed to find VGUIMenu usermessage");
	
	HookUserMessage(VGUIMenu, OnMsgVGUIMenu, true);

	// Hook the MOTD OK button
	AddCommandListener(PageClosed, "closed_htmlpage");
	
	// Specify console variables used to configure plugin
	g_ConVar_URL = CreateConVar("sm_motdredirect_url", "", "Target URL to replace MOTD");
	g_ConVarCooldown = CreateConVar("sm_motdredirect_force_min_duration", "1", "Prevent the MOTD from being closed for 5 seconds.");
	AutoExecConfig(true, "pinion_adverts");

	// Version of plugin - Make visible to game-monitor.com - Dont store in configuration file
	CreateConVar("sm_motdredirect_version", PLUGIN_VERSION, "[SM] MOTD Redirect Version", FCVAR_NOTIFY|FCVAR_DONTRECORD);

	// More event hooks for the config files
	RefreshCvarCache();
	HookConVarChange(g_ConVar_URL, Event_CvarChange);
	
	HookEvent("player_activate", Event_PlayerActivate);
	
	for (new i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i))
			ChangeState(i, kAdDone);
	}
	
#if defined _updater_included
    if (LibraryExists("updater"))
    {
		Updater_AddPlugin(UPDATE_URL);
	}
#endif
}

#if defined _updater_included
public OnLibraryAdded(const String:name[])
{
    if (StrEqual(name, "updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
}
#endif

// Occurs after round_start
public OnConfigsExecuted()
{
	// Synchronize Cvar Cache after configuration loaded
	RefreshCvarCache();
}

// Synchronize Cvar Cache when change made
public Event_CvarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	RefreshCvarCache();
}

RefreshCvarCache()
{
	// Build and cache url/ip/port string
	decl String:szInitialBaseURL[128];
	GetConVarString(g_ConVar_URL, szInitialBaseURL, sizeof(szInitialBaseURL));
	
	new hostip = GetConVarInt(FindConVar("hostip"));
	new hostport = GetConVarInt(FindConVar("hostport"));
	
	Format(g_BaseURL, sizeof(g_BaseURL), "%s?ip=%d.%d.%d.%d&port=%d", 
		szInitialBaseURL,
		hostip >>> 24 & 255, hostip >>> 16 & 255, hostip >>> 8 & 255, hostip & 255,
		hostport);
}

public OnClientConnected(client)
{
	ChangeState(client,  kAwaitingAd);
	g_bPlayerActivated[client] = false;
}

public Action:Event_DoPageHit(Handle:timer, any:userid)
{
	// This event implies client is in-game while GetClientOfUserId() checks IsClientConnected()
	new client = GetClientOfUserId(userid);
	if (client && !IsFakeClient(client))
	{
		if (g_Game == kGameCSGO)
		{
			ShowMOTDPanelEx(client, MOTD_TITLE, "javascript:windowClosed()", MOTDPANEL_TYPE_URL, MOTDPANEL_CMD_NONE, true);
			FakeClientCommand(client, "joingame");
		}
		else
		{
			ShowMOTDPanelEx(client, "", "javascript:windowClosed()", MOTDPANEL_TYPE_URL, MOTDPANEL_CMD_NONE, false);
		}
	}
}

// Extended ShowMOTDPanel with options for Command and Show
stock ShowMOTDPanelEx(client, const String:title[], const String:msg[], type=MOTDPANEL_TYPE_INDEX, cmd=MOTDPANEL_CMD_NONE, bool:show=true)
{
	new Handle:Kv = CreateKeyValues("data");

	KvSetString(Kv, "title", title);
	KvSetNum(Kv, "type", type);
	KvSetString(Kv, "msg", msg);
	KvSetNum(Kv, "cmd", cmd);	//http://forums.alliedmods.net/showthread.php?p=1220212
	ShowVGUIPanel(client, "info", Kv, show);
	CloseHandle(Kv);
}

public Event_PlayerActivate(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	g_bPlayerActivated[client] = true;
}


public Action:OnMsgVGUIMenu(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init)
{
	new client = players[0];
	if (playersNum > 1 || !IsClientInGame(client) || IsFakeClient(client)
		|| (GetState(client) != kAwaitingAd && GetState(client) != kViewingAd))
	{
		return Plugin_Continue;
	}

	decl String:buffer[64];
	BfReadString(bf, buffer, sizeof(buffer));
	if (strcmp(buffer, "info") != 0)
	{
		return Plugin_Continue;
	}
	
	CreateTimer(0.1, LoadPage, players[0]);

	return Plugin_Handled;
}

public Action:PageClosed(client, const String:command[], argc)
{
	switch (GetState(client))
	{
		case kAdDone:
		{
			return Plugin_Handled;
		}
		case kViewingAd:
		{
			LoadPage(INVALID_HANDLE, client);
		}
		case kAdClosing:
		{
			//keeping this in userid form incase we still need to hook events in the future for some games
			ChangeState(client, kAdDone);
			new userid = GetClientUserId(client); 
			CreateTimer(0.1, Event_DoPageHit, userid);
			
			// Do the actual intended motd 'cmd' now that we're done capturing close.
			switch (g_Game)
			{
				case kGameCSS:
					FakeClientCommand(client, "joingame");
				case kGameDODS:
					ClientCommand(client, "changeteam");
			}
		}
	}
	
	return Plugin_Handled;
}

public Action:LoadPage(Handle:timer, any:client)
{
	if (g_Game == kGameCSGO && GetState(client) == kViewingAd)
		return Plugin_Handled;
	
	new Handle:kv = CreateKeyValues("data");

	if (BGameUsesVGUIEnum())
	{
		KvSetNum(kv, "cmd", MOTDPANEL_CMD_CLOSED_HTMLPAGE);
	}
	else
	{
		KvSetString(kv, "cmd", "closed_htmlpage");
	}

	if (GetState(client) != kViewingAd)
	{
		decl String:szAuth[MAX_AUTH_LENGTH];
		GetClientAuthString(client, szAuth, sizeof(szAuth));
		
		decl String:szURL[128];
		Format(szURL, sizeof(szURL), "%s&steamid=%s", g_BaseURL, szAuth);
		
		KvSetString(kv, "msg",	szURL);
	}
	
	if (g_Game == kGameCSGO)
	{
		KvSetString(kv, "title", MOTD_TITLE);
	}
	
	KvSetNum(kv, "type", MOTDPANEL_TYPE_URL);
	
	ShowVGUIPanelEx(client, "info", kv, true, USERMSG_BLOCKHOOKS|USERMSG_RELIABLE);
	CloseHandle(kv);
	
	if (g_Game != kGameCSGO && GetState(client) != kViewingAd && GetConVarFloat(g_ConVarCooldown))
	{
		new Handle:data;
		CreateDataTimer(0.25, Timer_Restrict, data, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(data, GetClientSerial(client));
		WritePackFloat(data, GetGameTime());
	}
	
	if (g_Game == kGameCSGO)
		ChangeState(client, kAdClosing);
	else
		ChangeState(client, kViewingAd);
	
	
	return Plugin_Stop;
}

ShowVGUIPanelEx(client, const String:name[], Handle:kv=INVALID_HANDLE, bool:show=true, usermessageFlags=0)
{
	new Handle:bf = StartMessageOne("VGUIMenu", client, usermessageFlags);
	BfWriteString(bf, name);
	BfWriteByte(bf, show);
	
	if (kv == INVALID_HANDLE)
	{
		BfWriteByte(bf, 0);
	}
	else
	{	
		if (!KvGotoFirstSubKey(kv, false))
		{
			BfWriteByte(bf, 0);
		}
		else
		{
			new keyCount = 0;
			do
			{
				++keyCount;
			} while (KvGotoNextKey(kv, false));
			
			BfWriteByte(bf, keyCount);
			
			if (keyCount > 0)
			{
				KvGoBack(kv);
				KvGotoFirstSubKey(kv, false);
				do
				{
					decl String:key[128], String:value[128];
					KvGetSectionName(kv, key, sizeof(key));
					KvGetString(kv, NULL_STRING, value, sizeof(value), "");
					
					BfWriteString(bf, key);
					BfWriteString(bf, value);
				} while (KvGotoNextKey(kv, false));
			}
		}
	}
	
	EndMessage();
}

public Action:Timer_Restrict(Handle:timer, Handle:data)
{
	ResetPack(data);
	
	new client = GetClientFromSerial(ReadPackCell(data));
	if (client == 0)
		return Plugin_Stop;
	
	if (!g_bPlayerActivated[client])
		return Plugin_Continue;
	
	new Float:flStartTime = ReadPackFloat(data);
	new timeleft = WAIT_TIME - RoundToFloor(GetGameTime() - flStartTime);
	if (timeleft > 0)
	{
		PrintCenterText(client, "You may close the MOTD in %d seconds.", timeleft);
		return Plugin_Continue;
	}
	
	PrintCenterText(client, "");
	
	ChangeState(client, kAdClosing);
	
	return Plugin_Stop;
}

EPlayerState:GetState(client)
{
	return g_PlayerState[client];
}

ChangeState(client, EPlayerState:newState)
{
	g_PlayerState[client] = newState;
}

stock UTIL_StringToLower(String:szInput[])
{
	new i = 0, c;
	while ((c = szInput[i]) != 0)
	{
		szInput[i++] = CharToLower(c);
	}
}

// Right now, more supported games use this than not,
//   however, it's still used in less total games.
stock bool:BGameUsesVGUIEnum()
{
	return g_Game == kGameCSS
		|| g_Game == kGameTF2
		|| g_Game == kGameDODS
		|| g_Game == kGameHL2DM
		|| g_Game == kGameND
		|| g_Game == kGameCSGO
		;
}
