/* pinion_adverts.sp
Name: Pinion Adverts
See changelog for complete list of authors and contributors

Description:
	Causes client to access a webpage when player has chosen a team.  Left 4 Dead will use
	player left start area / checkpoint.  The url will have have /host_ip/hostport/steamid
	added to it.  

Installation:
	Place compiled plugin (pinion_adverts.smx) into your plugins folder.
	The configuration file (pinion_adverts.cfg) is generated automatically.
	Changes to cvars made in console take effect immediately.

Files:
	cstrike/addons/sourcemod/plugins/pinion_adverts.smx
	cstrike/cfg/sourcemod/pinion_adverts.cfg

Configuration Variables: See pinion_adverts.cfg.

------------------------------------------------------------------------------------------------------------------------------------

Changelog
	1.12.15 <-> 2013 2/6 - Caelan Borowiec
		Added dynamic minimum durations
		Added countermeasure to deal with players bypassing the motd window
	1.12.14 <-> 2013 1/24 - Caelan Borowiec
		Updated code to use CS:GO's new protobuff methods (Fixes the plugin not functioning in CS:GO).
	1.12.13 <-> 2013 1/20 - Caelan Borowiec
		Patched a possible memory leak
		Improved player immunity handling
		Added immunity for inital connection advert's delay timer
	1.12.12 <-> 2012 12/12 - Caelan Borowiec
		Version bump
	1.8.2-pre-12 <-> 2012 12/7 - Caelan Borowiec
		Fixed a bug that would prevent a player from seeing the jointeam menu if they idled too long after joining the server (For real this time).
		Fixed a resulting bug that would open a blank page two minutes after joining the server.
	1.8.2-pre-11 <-> 2012 12/5 - Caelan Borowiec
		Changed the force_min_duration cvar handling so that the delay length will now match the cvar value.
		Fixed a bug that would prevent a player from seeing the jointeam menu if they idled too long after joining the server.
		Fixed the round-end option for re-view ads not working on Arena maps.
	1.8.2-pre-10 <-> 2012 11/28 - Caelan Borowiec
		Converted LoadPage() to use DataTimers
		Added code to pass data indicating what triggered an ad view to the backend
		Fixed issue with admin immunity functionality
	1.8.2-pre-9 <-> 2012 11/20 - Caelan Borowiec
		Lowered the default value of sm_motdredirect_review_time from 40 to 30
	1.8.2-pre-8 <-> 2012 11/20 - Caelan Borowiec
		Added sm_motdredirect_tf2_review_event cvar to configure if 'review' ads are shown at round end or round start in TF2
		Added a check to prevent errors in ClosePage()
		Added checks to prevent errors when calling GetClientAuthString
	1.8.2-pre-7 <-> 2012 11/16 - Caelan Borowiec
		Changed event used for TF2 round-start adverts so that ads are displayed eariler.
		Renamed ConVar sm_advertisement_immunity_enable to sm_motdredirect_immunity_enable to be consistent with other cvar names.
		Made advertisement time restrictions apply to ads shown after L4D1/L4D2 map stage transitions.
		Updated sm_motdredirect_url checking code to prevent false-positives from being logged.
		Updated motd.txt replacement code to prevent overwriting the backup file.
		MOTD window will now auto-close after two minutes.
	1.8.2-pre-6 <-> 2012 11/13 - Caelan Borowiec
		Fixed adverts not working for Left 4 Dead 1 map stage transitions
		Revised plugin versioning scheme
	1.8.2-pre-5 <-> 2012 11/13 - Caelan Borowiec
		Disabled minimun display time feature in L4D and L4D2
	1.8.2-pre-4 <-> 2012 11/13 - Caelan Borowiec
		Moved round-end advertisements to now show during setup time at the start of the round.
	1.8.2-pre-3 <-> 2012 11/11 - Caelan Borowiec
		Corrected version numbering in the #define
		Added plugin version number to the query string
		Changed TF2 end-round advertisement handling:  Now all players will see an ad during the same round-end period after a global timer elapses.
	1.8.2-pre-2 <-> 2012 11/10 - Caelan Borowiec
		Fixed incompatible plugin message displaying with url-encoded text
		Added support for displaying advertisements after Left 4 Dead 1/Left 4 Dead 2 map stage transitions
		Added advertisement immunity and related configuration settings
	1.8.2-pre-1 <-> 2012 10/31 - Caelan Borowiec
		Added an error message to alert users if sm_motdredirect_url has not been assigned a value.
		Added functionality to check for incompatible plugins and display a notice via the MOTD
		Updated plugin comments.
	1.8.2 <-> 2012 - Nicholas Hastings
		Fixed harmless invalid client error that would occasionally be logged.
		Updated wait-to-close mention to mention Pinion Pot of Gold.
		Fixed regression in 1.8.0 causing ND to not open team menu after MOTD close.
	1.8.1 <-> 2012 - Nicholas Hastings
		Fixed MOTD panel being unclosable on most games if sm_motdredirect_force_min_duration set to 0.
	1.8 <-> 2012 - Nicholas Hastings
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
#include <socket>

#undef REQUIRE_PLUGIN
#tryinclude <updater>

#pragma semicolon 1

#define TEAM_SPEC 1
#define MAX_AUTH_LENGTH 64

//#define SHOW_CONSOLE_MESSAGES

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

enum loadTigger
{
	AD_TRIGGER_UNDEFINED = 0,
	AD_TRIGGER_CONNECT,
	AD_TRIGGER_PLAYER_TRANSITION,
	AD_TRIGGER_GLOBAL_TIMER,
	AD_TRIGGER_GLOBAL_TIMER_ROUNDEND,
};

// Plugin definitions
#define PLUGIN_VERSION "1.12.15"
public Plugin:myinfo =
{
	name = "Pinion Adverts",
	author = "Multiple contributors",
	description = "Pinion in-game advertisements helper",
	version = PLUGIN_VERSION,
	url = "http://www.pinion.gg/"
};

// The number of times to attempt to query adback.pinion.gg
#define MAX_QUERY_ATTEMPTS 10
//The number of seconds to delay between failed query attempts
#define QUERY_DELAY 3.0

// Some games require a title to explicitly be set (while others don't even show the set title)
#define MOTD_TITLE "Sponsor Message"

#define UPDATE_URL "http://bin.pinion.gg/bin/pinion_adverts/updatefile.txt"

#define IsReViewEnabled() GetConVarBool(g_ConVarReView)

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
new Handle:g_ConVarReView;
new Handle:g_ConVarReViewTime;
new Handle:g_ConVarImmunityEnabled;
new Handle:g_ConVarTF2EventOption;

// Globals required/used by dynamic delay code
new g_iCurrentIteration[MAXPLAYERS +1];
new g_iNumQueryAttempts[MAXPLAYERS +1] = 1;
new g_iDynamicDisplayTime[MAXPLAYERS +1] = 0;


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
new Handle:g_hPlayerLastViewedAd = INVALID_HANDLE;
new g_iLastAdWave = -1; // TODO: Reset this value to -1 when the last player leaves the server.

#define SECONDS_IN_MINUTE 60
#define GetReViewTime() (GetConVarInt(g_ConVarReViewTime) * SECONDS_IN_MINUTE)

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	// Backwards compatibility pre csgo/sm1.5
	MarkNativeAsOptional("GetUserMessageType");
	
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
	g_ConVarCooldown = CreateConVar("sm_motdredirect_force_min_duration", "25", "Prevent the MOTD from being closed for this many seconds (min: 15 sec, 0 = disabled).", 0, true, 0.0, true, 30.0);
	g_ConVarReView = CreateConVar("sm_motdredirect_review", "0", "Set clients to re-view ad next round if they have not seen it recently");
	g_ConVarTF2EventOption = CreateConVar("sm_motdredirect_tf2_review_event", "1", "1: Ads show at start of round. 2: Ads show at end of round.'");
	g_ConVarReViewTime = CreateConVar("sm_motdredirect_review_time", "30", "Duration (in minutes) until mid-map MOTD re-view", 0, true, 20.0);
	g_ConVarImmunityEnabled = CreateConVar("sm_motdredirect_immunity_enable", "0", "Set to 1 to prevent displaying ads to users with access to 'advertisement_immunity'", 0, true, 0.0, true, 1.0);
	AutoExecConfig(true, "pinion_adverts");

	// Version of plugin - Make visible to game-monitor.com - Dont store in configuration file
	CreateConVar("sm_motdredirect_version", PLUGIN_VERSION, "[SM] MOTD Redirect Version", FCVAR_NOTIFY|FCVAR_DONTRECORD);

	// More event hooks for the config files
	RefreshCvarCache();
	HookConVarChange(g_ConVar_URL, Event_CvarChange);
	
	HookEvent("player_activate", Event_PlayerActivate);
	
	for (new i = 1; i <= MaxClients; ++i)
	{
		if (!IsClientInGame(i))
			continue;

		ChangeState(i, kAdDone);
	}
	
	SetupReView();
	
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
	
	decl String:szInitialBaseURL[128];
	GetConVarString(g_ConVar_URL, szInitialBaseURL, sizeof(szInitialBaseURL));
	
	if (StrEqual(szInitialBaseURL, ""))
		LogError("ConVar sm_motdredirect_url has not been set:  Please check your pinion_adverts config file.");
}

// Called after all plugins are loaded
public OnAllPluginsLoaded()
{
	//See what other plugins are loaded
	new Handle:hIterator = GetPluginIterator();
	new Handle:hPlugin = INVALID_HANDLE;
	new String:sData[128];
	
	new bool:FoundPlugin = false;
	
	while (MorePlugins(hIterator))
	{
		hPlugin = ReadPlugin(hIterator);
		
		if (GetPluginInfo(hPlugin, PlInfo_Name, sData, sizeof(sData)))
		{
			if (StrEqual(sData, "Open URL MOTD", false))
			{
				FoundPlugin = true;
				break;
			}
			if (StrEqual(sData, "Auto DeSpectate", false))
			{
				FoundPlugin = true;
				break;
			}
		}
	}
	CloseHandle(hPlugin);
	CloseHandle(hIterator);
	
	if (FoundPlugin == true)
	{
		if (FileExists("motd.txt") && !FileExists("motd_backup.txt"))
			RenameFile("motd.txt", "motd_backup.txt");
		
		if (!FileExists("motd.txt"))
		{
			new Handle:hMOTD = OpenFile("motd.txt", "w");
			if (hMOTD != INVALID_HANDLE)
			{
				new String:sDataEscape[128];
				strcopy(sDataEscape, sizeof(sDataEscape), sData);
				ReplaceString(sDataEscape, sizeof(sDataEscape), " ", "+");
				WriteFileLine(hMOTD, "<meta http-equiv='Refresh' content='0; url=http://google.com/?q=%s'>", sDataEscape);
			}
			CloseHandle(hMOTD);
		}
		SetFailState("This plugin cannot run while %s is loaded.  Please remove \"%s\" to use this plugin.", sData, sData);
	}
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
	
	// TODO: Add gamedir url var?
	Format(g_BaseURL, sizeof(g_BaseURL), "%s?ip=%d.%d.%d.%d&port=%d&plug_ver=%s", 
		szInitialBaseURL,
		hostip >>> 24 & 255, hostip >>> 16 & 255, hostip >>> 8 & 255, hostip & 255,
		hostport,
		PLUGIN_VERSION);
}

SetupReView()
{
	// only support on TF2 while testing
	if (g_Game == kGameTF2)
	{
		HookEvent("teamplay_round_start", Event_HandleReview, EventHookMode_PostNoCopy);
		HookEvent("teamplay_win_panel", Event_HandleReview, EventHookMode_PostNoCopy);	// Change to teamplay_round_win?
		HookEvent("arena_win_panel", Event_HandleReview, EventHookMode_PostNoCopy);
	}
	else if (g_Game == kGameL4D2 || g_Game == kGameL4D)
	{
		g_hPlayerLastViewedAd = CreateTrie();
		HookEvent("player_transitioned", Event_PlayerTransitioned);
		HookEvent("player_disconnect", Event_PlayerDisconnected);
	}
}

public OnClientConnected(client)
{
	ChangeState(client, kAwaitingAd);
	g_bPlayerActivated[client] = false;
}


public Action:Event_DoPageHit(Handle:timer, any:serial)
{
	// This event implies client is in-game while GetClientOfUserId() checks IsClientConnected()
	new client = GetClientFromSerial(serial);
	if (client && !IsFakeClient(client))
	{
		if (g_Game == kGameCSGO)
		{
			#if defined SHOW_CONSOLE_MESSAGES
			PrintToConsole(client, "Sending javascript:windowClosed() to client.");
			#endif
			ShowMOTDPanelEx(client, MOTD_TITLE, "javascript:windowClosed()", MOTDPANEL_TYPE_URL, MOTDPANEL_CMD_NONE, true);
			FakeClientCommand(client, "joingame");
			#if defined SHOW_CONSOLE_MESSAGES
			PrintToConsole(client, "javascript:windowClosed() sent to client.");
			#endif
		}
		else
		{
			#if defined SHOW_CONSOLE_MESSAGES
			PrintToConsole(client, "Sending javascript:windowClosed() to client.");
			#endif
			ShowMOTDPanelEx(client, "", "javascript:windowClosed()", MOTDPANEL_TYPE_URL, MOTDPANEL_CMD_NONE, false);
			#if defined SHOW_CONSOLE_MESSAGES
			PrintToConsole(client, "javascript:windowClosed() sent to client.");
			#endif
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

public OnMapEnd()
{
	g_iLastAdWave = -1;	// Reset the value so adverts aren't triggered the first round after a map load
}

public Event_HandleReview(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsReViewEnabled())
		return;
		
	new iEventChoice = GetConVarInt(g_ConVarTF2EventOption);
	if ((StrEqual(name, "teamplay_round_start", false) && iEventChoice != 1) || ((StrEqual(name, "teamplay_win_panel", false) || StrEqual(name, "arena_win_panel", false)) && iEventChoice != 2))
		return;
	
	if (g_iLastAdWave == -1) // Time counter has been reset or has not started.  Start it now.
	{
		g_iLastAdWave = GetTime();
		return; //Skip this advertisement wave
	}
	
	new iReViewTime = GetReViewTime();
	if  ((GetTime() - g_iLastAdWave) > iReViewTime)
	{
		for (new i = 1; i <= MaxClients; ++i)
		{
			if (!IsClientInGame(i) || IsFakeClient(i))
				continue;

			ChangeState(i, kAwaitingAd);
			new Handle:pack = CreateDataPack();
			WritePackCell(pack, GetClientSerial(i));
			WritePackCell(pack, AD_TRIGGER_GLOBAL_TIMER_ROUNDEND);
			CreateTimer(2.0, LoadPage, pack, TIMER_FLAG_NO_MAPCHANGE);
		}
		g_iLastAdWave = GetTime();
	}
}

public OnClientAuthorized(client, const String:SteamID[])
{
	if (g_Game == kGameL4D2 || g_Game == kGameL4D)
	{
		new n;
		if (!GetTrieValue(g_hPlayerLastViewedAd, SteamID, n))
			SetTrieValue(g_hPlayerLastViewedAd, SteamID, GetTime());
	}
}

//Event_PlayerDisconnected will only be called for true disconnects
public Action:Event_PlayerDisconnected(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!client || !IsClientAuthorized(client))
		return;
	
	decl String:SteamID[32];
	GetClientAuthString(client, SteamID, sizeof(SteamID));
	RemoveFromTrie(g_hPlayerLastViewedAd, SteamID);
}

// Called when a player regains control of a character (after a map-stage load)
// This is *not* called when a player initially connects
// This is called for each player on the server
public Action:Event_PlayerTransitioned(Handle:event, const String:name[], bool:dontBroadcast)
{	
	if (!IsReViewEnabled())
		return;
		
	new now = GetTime();
	new iReViewTime = GetReViewTime();
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!client || !IsClientAuthorized(client))
		return;
	
	decl String:SteamID[32];
	GetClientAuthString(client, SteamID, sizeof(SteamID));
	
	new iLastAdView;
	if (!GetTrieValue(g_hPlayerLastViewedAd, SteamID, iLastAdView))
	{
		SetTrieValue(g_hPlayerLastViewedAd, SteamID, GetTime());
		return;
	}
	
	if (!IsClientInGame(client) || IsFakeClient(client))
		return;
	
	if ((now - iLastAdView) < iReViewTime)
		return;

	ChangeState(client, kAwaitingAd);
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, GetClientSerial(client));
	WritePackCell(pack, AD_TRIGGER_PLAYER_TRANSITION);
	CreateTimer(2.0, LoadPage, pack, TIMER_FLAG_NO_MAPCHANGE);
	SetTrieValue(g_hPlayerLastViewedAd, SteamID, GetTime());
}

public Action:OnMsgVGUIMenu(UserMsg:msg_id, Handle:self, const players[], playersNum, bool:reliable, bool:init)
{
	new client = players[0];
	if (playersNum > 1 || !IsClientInGame(client) || IsFakeClient(client)
		|| (GetState(client) != kAwaitingAd && GetState(client) != kViewingAd))
		return Plugin_Continue;

	decl String:buffer[64];
	if (GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf)
		PbReadString(self, "name", buffer, sizeof(buffer));
	else
		BfReadString(self, buffer, sizeof(buffer));
	
	if (strcmp(buffer, "info") != 0)
			return Plugin_Continue;
	
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, GetClientSerial(players[0]));
	WritePackCell(pack, AD_TRIGGER_CONNECT);
	CreateTimer(0.1, LoadPage, pack, TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Handled;
}

public Action:PageClosed(client, const String:command[], argc)
{
	if (client == 0 || !IsClientInGame(client))
		return Plugin_Handled;
		
	#if defined SHOW_CONSOLE_MESSAGES
	PrintToConsole(client, "Command closed_htmlpage detected.");
	#endif
	
	switch (GetState(client))
	{
		case kAdDone:
		{
			return Plugin_Handled;
		}
		case kViewingAd:
		{
			new Handle:pack = CreateDataPack();
			WritePackCell(pack, GetClientSerial(client));
			WritePackCell(pack, AD_TRIGGER_UNDEFINED);
			LoadPage(INVALID_HANDLE, pack);
		}
		case kAdClosing:
		{
			ChangeState(client, kAdDone);
			CreateTimer(0.1, Event_DoPageHit, GetClientSerial(client));
			
			// Do the actual intended motd 'cmd' now that we're done capturing close.
			switch (g_Game)
			{
				case kGameCSS, kGameND:
					FakeClientCommand(client, "joingame");
				case kGameDODS:
					ClientCommand(client, "changeteam");
			}
		}
	}
	
	return Plugin_Handled;
}

public Action:LoadPage(Handle:timer, Handle:pack)
{
	ResetPack(pack);
	new client = GetClientFromSerial(ReadPackCell(pack));
	new trigger = ReadPackCell(pack);
	
	CloseHandle(pack);
	
	if (!client || (g_Game == kGameCSGO && GetState(client) == kViewingAd))
		return Plugin_Stop;
	
	new bool:bClientHasImmunity = false;
	if (GetConVarBool(g_ConVarImmunityEnabled) && CheckCommandAccess(client, "advertisement_immunity", ADMFLAG_RESERVATION))
		bClientHasImmunity = true;
	
	if (bClientHasImmunity && trigger != _:AD_TRIGGER_UNDEFINED && trigger != _:AD_TRIGGER_CONNECT)
		return Plugin_Stop; //Cancel re-view ads
	
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
		GetClientAdvertDelay(client);
		
		decl String:szAuth[MAX_AUTH_LENGTH];
		GetClientAuthString(client, szAuth, sizeof(szAuth));
		
		decl String:szURL[128];
		Format(szURL, sizeof(szURL), "%s&steamid=%s&trigger=%i", g_BaseURL, szAuth, trigger);
		KvSetString(kv, "msg",	szURL);
		
		new Handle:pack2;
		CreateDataTimer(120.0, ClosePage, pack2, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack2, GetClientSerial(client));
		WritePackCell(pack2, trigger);
	}

	if (g_Game == kGameCSGO)
	{
		KvSetString(kv, "title", MOTD_TITLE);
	}
	
	KvSetNum(kv, "type", MOTDPANEL_TYPE_URL);
	
	ShowVGUIPanelEx(client, "info", kv, true, USERMSG_BLOCKHOOKS|USERMSG_RELIABLE);
	CloseHandle(kv);
	
	new iCooldown = GetConVarInt(g_ConVarCooldown);
	new bool:bUseCooldown = (g_Game != kGameCSGO && g_Game != kGameL4D2 && g_Game != kGameL4D && iCooldown != 0 && !bClientHasImmunity);
	if (bUseCooldown && GetState(client) != kViewingAd)
	{
		new Handle:data;
		CreateDataTimer(0.25, Timer_Restrict, data, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(data, GetClientSerial(client));
		WritePackFloat(data, GetGameTime());
	}
	
	if (!bUseCooldown)
		ChangeState(client, kAdClosing);
	else
		ChangeState(client, kViewingAd);

	return Plugin_Stop;
}

public Action:ClosePage(Handle:timer, Handle:pack)
{
	ResetPack(pack);
	new client = GetClientFromSerial(ReadPackCell(pack));
	
	if (GetState(client) == kAdClosing || GetState(client) == kViewingAd)	//Ad is loaded
	{
		new trigger = ReadPackCell(pack);
		
		if (!client)
			return;
		ShowMOTDPanelEx(client, MOTD_TITLE, "about:blank", MOTDPANEL_TYPE_URL, MOTDPANEL_CMD_NONE, true);
		if (trigger != _:AD_TRIGGER_CONNECT)
			ShowMOTDPanelEx(client, MOTD_TITLE, "javascript:windowClosed()", MOTDPANEL_TYPE_URL, MOTDPANEL_CMD_NONE, false);
	}
}


ShowVGUIPanelEx(client, const String:name[], Handle:kv=INVALID_HANDLE, bool:show=true, usermessageFlags=0)
{
	new Handle:msg = StartMessageOne("VGUIMenu", client, usermessageFlags);
	
	if (GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf)
	{
		PbSetString(msg, "name", name);
		PbSetBool(msg, "show", true);

		if (kv != INVALID_HANDLE && KvGotoFirstSubKey(kv, false))
		{
			new Handle:subkey;

			do
			{
				decl String:key[128], String:value[128];
				KvGetSectionName(kv, key, sizeof(key));
				KvGetString(kv, NULL_STRING, value, sizeof(value), "");
				
				subkey = PbAddMessage(msg, "subkeys");
				PbSetString(subkey, "name", key);
				PbSetString(subkey, "str", value);

			} while (KvGotoNextKey(kv, false));
		}
	}
	else //BitBuffer
	{
		BfWriteString(msg, name);
		BfWriteByte(msg, show);
		
		if (kv == INVALID_HANDLE)
		{
			BfWriteByte(msg, 0);
		}
		else
		{	
			if (!KvGotoFirstSubKey(kv, false))
			{
				BfWriteByte(msg, 0);
			}
			else
			{
				new keyCount = 0;
				do
				{
					++keyCount;
				} while (KvGotoNextKey(kv, false));
				
				BfWriteByte(msg, keyCount);
				
				if (keyCount > 0)
				{
					KvGoBack(kv);
					KvGotoFirstSubKey(kv, false);
					do
					{
						decl String:key[128], String:value[128];
						KvGetSectionName(kv, key, sizeof(key));
						KvGetString(kv, NULL_STRING, value, sizeof(value), "");
						
						BfWriteString(msg, key);
						BfWriteString(msg, value);
					} while (KvGotoNextKey(kv, false));
				}
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
	new iCooldown;
	
	if (g_iDynamicDisplayTime[client] > 0) //Got a valid time back from the backend
		iCooldown = g_iDynamicDisplayTime[client];
	else if (g_iDynamicDisplayTime[client] < 0) //Backend said there was no video
		iCooldown = 0;
	else
	{	
		iCooldown = GetConVarInt(g_ConVarCooldown);
		if (iCooldown > 30)
			iCooldown = 30;
		else if (iCooldown < 15)
			iCooldown = 15;
	}
	iCooldown = iCooldown + 3;
	
	new timeleft = iCooldown - RoundToFloor(GetGameTime() - flStartTime);
	if (timeleft > 0)
	{
		PrintCenterText(client, "You may continue in %d seconds or stay tuned for Pinion Pot of Gold.", timeleft);
		ShowMOTDPanelEx(client, MOTD_TITLE, "", MOTDPANEL_TYPE_URL, MOTDPANEL_CMD_NONE, false);
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



// Code for Dynamic Durations
GetClientAdvertDelay(client)
{
	g_iNumQueryAttempts[client] = 1;
	g_iCurrentIteration[client] = 1;
	g_iDynamicDisplayTime[client] = 0;
	
	new String:Domain[] = "adback.pinion.gg";
	new String:sQueryURL[] = "";
	
	//Create the pack and fill it with data
	new Handle:hPack = CreateDataPack();
	WritePackString(hPack, sQueryURL); //Remote File
	WritePackString(hPack, Domain); //Domain
	WritePackCell(hPack, GetClientSerial(client));

	//Create a socket connection and pass the pack handle
	new Handle:socket = SocketCreate(SOCKET_TCP, OnSocketError);
	SocketSetArg(socket, hPack);
	SocketConnect(socket, OnSocketConnected, OnSocketReceive, OnSocketDisconnected, Domain, 80);
}

public OnSocketConnected(Handle:socket, any:hPack)
{
	new String:DownloadFrom[512], String:Domain[512], String:SteamID[32];
	
	ResetPack(hPack);
	ReadPackString(hPack, DownloadFrom, sizeof(DownloadFrom)); //Remote path
	ReadPackString(hPack, Domain, sizeof(Domain)); //Remote
	
	new client = GetClientFromSerial(ReadPackCell(hPack));
	if (client == 0)
		return;
	
	GetClientAuthString(client, SteamID, sizeof(SteamID));
	
	
	new String:buffer[1024];
	Format(buffer, sizeof(buffer), "GET /%s%s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n", DownloadFrom, SteamID, Domain);
	#if defined SHOW_CONSOLE_MESSAGES
	PrintToConsole(client, "\n\nQuerying url: %s/%s%s", Domain, DownloadFrom, SteamID);
	#endif
	SocketSend(socket, buffer);
}

public OnSocketReceive(Handle:socket, String:receiveData[], const dataSize, any:hPack)
{
	new String:DownloadFrom[512], String:Domain[512];
	
	ResetPack(hPack);
	ReadPackString(hPack, DownloadFrom, sizeof(DownloadFrom)); //Remote path
	ReadPackString(hPack, Domain, sizeof(Domain)); //Remote domain
	new client = GetClientFromSerial(ReadPackCell(hPack));
	if (client == 0)
		return;

	new pos = 0;
	if (g_iCurrentIteration[client] == 1)
	{
		pos = 4;
		while (!(receiveData[pos-4] == '\r' && receiveData[pos-3] == '\n' && receiveData[pos-2] == '\r' && receiveData[pos-1] == '\n'))
			pos++;

		new String:szHeader[pos-4];
		strcopy(szHeader, pos-4, receiveData);
		new lenPos = StrContains(szHeader, "Content-Length: ", false);
		if (lenPos != -1)
		{
			lenPos += 16;
			new String:szContentLength[32];
			new x = 0;
			while (szHeader[lenPos] != '\r' && szHeader[lenPos+1] != '\n')
				szContentLength[x++] = szHeader[lenPos++];
			
			szContentLength[x] = '\0';
		}
	}

	new String:sData[4096];
	strcopy(sData, sizeof(sData), receiveData[pos]);
	TrimString(sData);
	
	#if defined SHOW_CONSOLE_MESSAGES
	PrintToConsole(client, "Query returned '%s'", sData);
	#endif
	if (!StrEqual(sData, ""))
	{
		new queryResult = StringToInt(sData);
		if (queryResult == 0)
		{
			new Handle:pack = CloneHandle(hPack);
			CreateTimer(QUERY_DELAY, QueryAgain, pack, TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			#if defined SHOW_CONSOLE_MESSAGES
			PrintToConsole(client, "Query finished, StringToInt returned %i", queryResult);
			#endif
			//Update the delay timer
			g_iDynamicDisplayTime[client] = queryResult;
		}
	}
	
	g_iCurrentIteration[client]++;
}

// QueryAgain decides if a query should be reattempted and creates the query if yes
public Action:QueryAgain(Handle:timer, Handle:hPack)
{
	new String:Domain[512];
	ResetPack(hPack);
	ReadPackString(hPack, Domain, sizeof(Domain));
	ReadPackString(hPack, Domain, sizeof(Domain));
	new client = GetClientFromSerial(ReadPackCell(hPack));
	if (client == 0)
	{
		CloseHandle(hPack);
		return;
	}
	
	if (g_iNumQueryAttempts[client] >= MAX_QUERY_ATTEMPTS)
	{
		#if defined SHOW_CONSOLE_MESSAGES
		PrintToConsole(client, "Query failed: StringToInt returned 0.  Giving up after %i attempts.", g_iNumQueryAttempts[client]);
		#endif
		CloseHandle(hPack);
		g_iNumQueryAttempts[client] = 1;
	}
	else
	{
		#if defined SHOW_CONSOLE_MESSAGES
		PrintToConsole(client, "Query #%i failed: StringToInt returned 0.  Attempting query again.", g_iNumQueryAttempts[client]);
		#endif
		g_iNumQueryAttempts[client] ++;
		
		//Create a socket connection and pass the pack handle
		g_iCurrentIteration[client] = 1;
		new Handle:socket = SocketCreate(SOCKET_TCP, OnSocketError);
		SocketSetArg(socket, hPack);
		SocketConnect(socket, OnSocketConnected, OnSocketReceive, OnSocketDisconnected, Domain, 80);
	}
}

public OnSocketError(Handle:socket, const errorType, const errorNum, any:hPack)
{
	LogError("Something went wrong querying the backend.  Socket error %d [errno %d]", errorType, errorNum);
	CloseHandle(hPack);
	CloseHandle(socket);
}

public OnSocketDisconnected(Handle:socket, any:hPack)
{
	CloseHandle(hPack);
	CloseHandle(socket);
}
