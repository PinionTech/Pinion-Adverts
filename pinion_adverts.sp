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
	./addons/sourcemod/plugins/pinion_adverts.smx
	./cfg/sourcemod/pinion_adverts.cfg

Configuration Variables: See pinion_adverts.cfg.

------------------------------------------------------------------------------------------------------------------------------------

Changelog
	1.12.20 <-> 2013 7/18 - Caelan Borowiec
		Fixed a case where delay queries would not be started
		Fixed a case where delay times from the backend could be cached
	1.12.19 <-> 2013 7/16 - David Banham
		Stop redirecting the page to about:blank before cleanup can be done
	1.12.18 <-> 2013 6/5 - Caelan Borowiec
		Removed "Pot of Gold" message
		Added check to prevent more than one query thread per client
		Added a check to prevent queries running for clients with immunity
		Changed query handing to query as long as the player is in the default cooldown
		Debug improvements to EasyHTTP and Helper_GetAdStatus_Complete
		Fixed an issue that could happen if the plugin received no data from a query
		Improved some debug messages
		Changed the backend interface to expect data in JSON
		Fixed the html page remaining loaded after the panel is closed.
	1.12.17 <-> 2013 5/29 - Hotfix Based on 1.12.16
		Increased polling rate
		Changed the default wait time to a hard-coded 30 seconds
		Disabled debug mode
	1.12.16 <-> 2013 4/25 - Caelan Borowiec
		Fixed an issue with the plugin loading a blank motd window
		Made SteamTools the prefered extension for queries
		Replaced cURL/Socket code with a wrapper for EasyHTTP.inc
			- (Plugin now requires EasyHTTP.inc to compile)
		Added a countermeasure to prevent players from blocking the closed_htmlpage command
		Changed the "you must wait" message to only display when a delay has been loaded from the backend.
		Removed bounds on the page-delay timer
		Changed the default wait time to a hard-coded 43 seconds
		Removed hard-coded 3 second addition to the delay
		Plugin will not run queries on games where dynamic page-delay durations are not supported
		Plugin no longer requires cURL/Socket to be installed on games where dynamic page-delay durations are not supported
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
#undef REQUIRE_PLUGIN
#tryinclude <updater>
#define REQUIRE_PLUGIN
#define STRING(%1) %1, sizeof(%1)
#include <EasyHTTP>
#include <json>

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
	AD_TRIGGER_UNDEFINED = 0,						// No data, this should never happen
	AD_TRIGGER_CONNECT,								// Player joined the server
	AD_TRIGGER_PLAYER_TRANSITION,				// L4D/L4D2 player regained control of a character after a stage transition
	AD_TRIGGER_GLOBAL_TIMER,						// Not currently used
	AD_TRIGGER_GLOBAL_TIMER_ROUNDEND,		// Re-view advertisement triggered at round end/round start
};

// Plugin definitions
#define PLUGIN_VERSION "1.12.20"
public Plugin:myinfo =
{
	name = "Pinion Adverts",
	author = "Multiple contributors",
	description = "Pinion in-game advertisements helper",
	version = PLUGIN_VERSION,
	url = "http://www.pinion.gg/"
};

// The number of times to attempt to query adback.pinion.gg
#define MAX_QUERY_ATTEMPTS 20
//The number of seconds to delay between failed query attempts
#define QUERY_DELAY 3.0
// The number of seconds players will wait if the backend doesnt respond
#define DEF_COOLDOWN 30

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
new Handle:g_ConVarReView;
new Handle:g_ConVarReViewTime;
new Handle:g_ConVarImmunityEnabled;
new Handle:g_ConVarTF2EventOption;

// Globals required/used by dynamic delay code
new g_iNumQueryAttempts[MAXPLAYERS +1] = 1;
new g_iDynamicDisplayTime[MAXPLAYERS +1] = 0;
new bool:g_bIsMapActive = false;
new bool:g_bIsQueryRunning[MAXPLAYERS +1] = false;
new Float:g_fPlayerCooldownStartedAt[MAXPLAYERS +1] = 0.0;


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
	
	// Backwards compatibility pre csgo/sm1.5
	MarkNativeAsOptional("GetUserMessageType");
	
	// Mark Socket natives as optional
	MarkNativeAsOptional("SocketIsConnected");
	MarkNativeAsOptional("SocketCreate");
	MarkNativeAsOptional("SocketBind");
	MarkNativeAsOptional("SocketConnect");
	MarkNativeAsOptional("SocketDisconnect");
	MarkNativeAsOptional("SocketListen");
	MarkNativeAsOptional("SocketSend");
	MarkNativeAsOptional("SocketSendTo");
	MarkNativeAsOptional("SocketSetOption");
	MarkNativeAsOptional("SocketSetReceiveCallback");
	MarkNativeAsOptional("SocketSetSendqueueEmptyCallback");
	MarkNativeAsOptional("SocketSetDisconnectCallback");
	MarkNativeAsOptional("SocketSetErrorCallback");
	MarkNativeAsOptional("SocketSetArg");
	MarkNativeAsOptional("SocketGetHostName");

	// Mark SteamTools natives as optional
	MarkNativeAsOptional("Steam_IsVACEnabled");
	MarkNativeAsOptional("Steam_GetPublicIP");
	MarkNativeAsOptional("Steam_RequestGroupStatus");
	MarkNativeAsOptional("Steam_RequestGameplayStats");
	MarkNativeAsOptional("Steam_RequestServerReputation");
	MarkNativeAsOptional("Steam_IsConnected");
	MarkNativeAsOptional("Steam_SetRule");
	MarkNativeAsOptional("Steam_ClearRules");
	MarkNativeAsOptional("Steam_ForceHeartbeat");
	MarkNativeAsOptional("Steam_AddMasterServer");
	MarkNativeAsOptional("Steam_RemoveMasterServer");
	MarkNativeAsOptional("Steam_GetNumMasterServers");
	MarkNativeAsOptional("Steam_GetMasterServerAddress");
	MarkNativeAsOptional("Steam_SetGameDescription");
	MarkNativeAsOptional("Steam_RequestStats");
	MarkNativeAsOptional("Steam_GetStat");
	MarkNativeAsOptional("Steam_GetStatFloat");
	MarkNativeAsOptional("Steam_IsAchieved");
	MarkNativeAsOptional("Steam_GetNumClientSubscriptions");
	MarkNativeAsOptional("Steam_GetClientSubscription");
	MarkNativeAsOptional("Steam_GetNumClientDLCs");
	MarkNativeAsOptional("Steam_GetClientDLC");
	MarkNativeAsOptional("Steam_GetCSteamIDForClient");
	MarkNativeAsOptional("Steam_SetCustomSteamID");
	MarkNativeAsOptional("Steam_GetCustomSteamID");
	MarkNativeAsOptional("Steam_RenderedIDToCSteamID");
	MarkNativeAsOptional("Steam_CSteamIDToRenderedID");
	MarkNativeAsOptional("Steam_GroupIDToCSteamID");
	MarkNativeAsOptional("Steam_CSteamIDToGroupID");
	MarkNativeAsOptional("Steam_CreateHTTPRequest");
	MarkNativeAsOptional("Steam_SetHTTPRequestNetworkActivityTimeout");
	MarkNativeAsOptional("Steam_SetHTTPRequestHeaderValue");
	MarkNativeAsOptional("Steam_SetHTTPRequestGetOrPostParameter");
	MarkNativeAsOptional("Steam_SendHTTPRequest");
	MarkNativeAsOptional("Steam_DeferHTTPRequest");
	MarkNativeAsOptional("Steam_PrioritizeHTTPRequest");
	MarkNativeAsOptional("Steam_GetHTTPResponseHeaderSize");
	MarkNativeAsOptional("Steam_GetHTTPResponseHeaderValue");
	MarkNativeAsOptional("Steam_GetHTTPResponseBodySize");
	MarkNativeAsOptional("Steam_GetHTTPResponseBodyData");
	MarkNativeAsOptional("Steam_WriteHTTPResponseBody");
	MarkNativeAsOptional("Steam_ReleaseHTTPRequest");
	MarkNativeAsOptional("Steam_GetHTTPDownloadProgressPercent");

	// Mark cURL natives as optional
	MarkNativeAsOptional("curl_easy_init");
	MarkNativeAsOptional("curl_easy_setopt_string");
	MarkNativeAsOptional("curl_easy_setopt_int");
	MarkNativeAsOptional("curl_easy_setopt_int_array");
	MarkNativeAsOptional("curl_easy_setopt_int64");
	MarkNativeAsOptional("curl_OpenFile");
	MarkNativeAsOptional("curl_httppost");
	MarkNativeAsOptional("curl_slist");
	MarkNativeAsOptional("curl_easy_setopt_handle");
	MarkNativeAsOptional("curl_easy_setopt_function");
	MarkNativeAsOptional("curl_load_opt");
	MarkNativeAsOptional("curl_easy_perform");
	MarkNativeAsOptional("curl_easy_perform_thread");
	MarkNativeAsOptional("curl_easy_send_recv");
	MarkNativeAsOptional("curl_send_recv_Signal");
	MarkNativeAsOptional("curl_send_recv_IsWaiting");
	MarkNativeAsOptional("curl_set_send_buffer");
	MarkNativeAsOptional("curl_set_receive_size");
	MarkNativeAsOptional("curl_set_send_timeout");
	MarkNativeAsOptional("curl_set_recv_timeout");
	MarkNativeAsOptional("curl_get_error_buffer");
	MarkNativeAsOptional("curl_easy_getinfo_string");
	MarkNativeAsOptional("curl_easy_getinfo_int");
	MarkNativeAsOptional("curl_easy_escape");
	MarkNativeAsOptional("curl_easy_unescape");
	MarkNativeAsOptional("curl_easy_strerror");
	MarkNativeAsOptional("curl_version");
	MarkNativeAsOptional("curl_protocols");
	MarkNativeAsOptional("curl_features");
	MarkNativeAsOptional("curl_OpenFile");
	MarkNativeAsOptional("curl_httppost");
	MarkNativeAsOptional("curl_formadd");
	MarkNativeAsOptional("curl_slist");
	MarkNativeAsOptional("curl_slist_append");
	MarkNativeAsOptional("curl_hash_file");
	MarkNativeAsOptional("curl_hash_string");
	
	return APLRes_Success;
}

// Configure Environment
public OnPluginStart()
{
	EasyHTTPCheckExtensions();
	if(!g_bCURL && !g_bSockets && ! g_bSteamTools && g_Game != kGameCSGO && g_Game != kGameL4D2 && g_Game != kGameL4D)
		SetFailState("For this plugin to run you need ONE of these extensions installed:\n\
			cURL - http://forums.alliedmods.net/showthread.php?t=152216\n\
			SteamTools - http://forums.alliedmods.net/showthread.php?t=129763\n\
			Socket - http://forums.alliedmods.net/showthread.php?t=67640");

	// Catch the MOTD
	new UserMsg:VGUIMenu = GetUserMessageId("VGUIMenu");
	if (VGUIMenu == INVALID_MESSAGE_ID)
		SetFailState("Failed to find VGUIMenu usermessage");
	
	HookUserMessage(VGUIMenu, OnMsgVGUIMenu, true);
	AddCommandListener(PageClosed, "closed_htmlpage");
	
	// Specify console variables used to configure plugin
	g_ConVar_URL = CreateConVar("sm_motdredirect_url", "", "Target URL to replace MOTD");
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
		Updater_AddPlugin(UPDATE_URL);
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
				WriteFileLine(hMOTD, "Pinion cannot run while %s is loaded.  Please remove \"%s\" to use this plugin.", sData, sData);
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
	g_bIsMapActive = false;
}

public OnMapStart()
{
	g_bIsMapActive = true;
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
	g_fPlayerCooldownStartedAt[client] = 0.0;
	g_bIsQueryRunning[client] = false;
	g_iDynamicDisplayTime[client] = 0;
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
		new timeleft;
		GetMapTimeLeft(timeleft);
		
		new String:SteamID[32];
		GetClientAuthString(client, SteamID, sizeof(SteamID));
		g_fPlayerCooldownStartedAt[client] = GetGameTime();
		
		new bool:bUseCooldown = (g_Game != kGameCSGO && g_Game != kGameL4D2 && g_Game != kGameL4D);
		if ((timeleft > 120 || timeleft < 0) && g_bIsMapActive && bUseCooldown && IsClientInForcedCooldown(client) && !g_bIsQueryRunning[client])
		{
			g_bIsQueryRunning[client] = true;
			#if defined SHOW_CONSOLE_MESSAGES
			PrintToConsole(client, "Preparing to run query...");
			#endif
			CreateTimer(1.0, DelayQuery, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
		}
		
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
	

	new bool:bUseCooldown = (g_Game != kGameCSGO && g_Game != kGameL4D2 && g_Game != kGameL4D && !bClientHasImmunity);
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

// Delays a easy HTTP query by 1 second
public Action:DelayQuery(Handle:timer, any:serial)
{
	new client = GetClientFromSerial(serial);
	g_iNumQueryAttempts[client] = 1;
	g_iDynamicDisplayTime[client] = 0;
	GetClientAdvertDelayEasyHTTP(client);
}

//Returns true if the client is waiting to close the MOTD
public bool:IsClientInForcedCooldown(client)
{
	#if defined SHOW_CONSOLE_MESSAGES
	PrintToConsole(client, "Checking forced cooldown.");
	#endif
	
	
	if (g_iDynamicDisplayTime[client] != 0)
	{
		#if defined SHOW_CONSOLE_MESSAGES
		PrintToConsole(client, "The backend has already updated the value for this client");
		#endif
		return false; // Backend has responded
	}
	
	new bool:bClientHasImmunity = (GetConVarBool(g_ConVarImmunityEnabled) && CheckCommandAccess(client, "advertisement_immunity", ADMFLAG_RESERVATION));
	new bool:bUseCooldown = (g_Game != kGameCSGO && g_Game != kGameL4D2 && g_Game != kGameL4D && !bClientHasImmunity);
	if (!bUseCooldown)
	{
		#if defined SHOW_CONSOLE_MESSAGES
		PrintToConsole(client, "Cooldown does not apply to this client");
		#endif
		return false;	//Cooldown does not apply to this target
	}
	
	if (g_fPlayerCooldownStartedAt[client] != 0)
	{
		new timeleft = DEF_COOLDOWN - RoundToFloor(GetGameTime() - g_fPlayerCooldownStartedAt[client]);
		if (timeleft > 0)
		{
			#if defined SHOW_CONSOLE_MESSAGES
			PrintToConsole(client, "Client is in cooldown for %i more seconds", timeleft);
			#endif
			return true;
		}
	}
	return false;
}

public Action:ClosePage(Handle:timer, Handle:pack)
{
	ResetPack(pack);
	new client = GetClientFromSerial(ReadPackCell(pack));
	
	if (!client)
		return;
	
	if (GetState(client) == kAdClosing || GetState(client) == kViewingAd)	//Ad is loaded
	{
		if (GetClientTeam(client) != 0) // player has joined a team
			ShowMOTDPanelEx(client, MOTD_TITLE, "about:blank", MOTDPANEL_TYPE_URL, MOTDPANEL_CMD_NONE, false);
		else // Player still needs the menu open
			ShowMOTDPanelEx(client, MOTD_TITLE, "http://Pinion.gg", MOTDPANEL_TYPE_URL, MOTDPANEL_CMD_NONE, true);
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
	
	new iCooldown = DEF_COOLDOWN; // Default cooldown
	
	if (g_iDynamicDisplayTime[client] > 0) //Got a valid time back from the backend
	{
		iCooldown = g_iDynamicDisplayTime[client]; // Use backend's value
	}
	else if (g_iDynamicDisplayTime[client] < 0) //Backend said there was nothing
	{
		iCooldown = 0; // Ditch the cooldown
	}
	//else // The backend didn't respond with anything valid!
	
	new timeleft = iCooldown - RoundToFloor(GetGameTime() - flStartTime);
	if (timeleft > 0)
	{
		if (g_iDynamicDisplayTime[client] > 0)
			PrintCenterText(client, "You may continue in %d seconds.", timeleft);
		else
			PrintCenterText(client, "Loading...");
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


public Action:QueryAgain(Handle:timer, any:serial)
{
	new client = GetClientFromSerial(serial);
	g_iNumQueryAttempts[client]++;
	GetClientAdvertDelayEasyHTTP(client);
}

GetClientAdvertDelayEasyHTTP(client)
{
	if (client == 0)
		return;
	
	new String:sQueryURL[84] = "http://adback.pinion.gg/v2/duration/";
	new String:SteamID[32];
	GetClientAuthString(client, SteamID, sizeof(SteamID));
	
	StrCat(sQueryURL, sizeof(sQueryURL), SteamID);
	
	#if defined SHOW_CONSOLE_MESSAGES
	PrintToConsole(client, "\n\nQuerying URL: %s", sQueryURL);
	#endif
	
	// Request a customized ad delay for the client
	if(!EasyHTTP(sQueryURL, Helper_GetAdStatus_Complete, GetClientUserId(client)))
	{
		LogError("Sending EasyHTTP request failed.");
		#if defined SHOW_CONSOLE_MESSAGES
		PrintToConsole(client, "Sending EasyHTTP request failed.");
		#endif
		return;
	}
}

public Helper_GetAdStatus_Complete(any:userid, const String:sQueryData[], bool:success, error)
{
	// Make sure our client is still ingame
	new client = GetClientOfUserId(userid);
	if(!client || !IsClientInGame(client))
		return;
		
	#if defined SHOW_CONSOLE_MESSAGES
	PrintToConsole(client, "Query #%i returned '%s'", g_iNumQueryAttempts[client], sQueryData);
	#endif
		
	// Check if the request failed for whatever reason
	if(!success || StrEqual(sQueryData, ""))
	{
		LogError("Request failed. EasyHTTP reported failure.  Error: %i", error);
		#if defined SHOW_CONSOLE_MESSAGES
		PrintToConsole(client, "Request failed. EasyHTTP reported failure or no data was returned.  Error: %i", error);
		PrintToConsole(client, "Retrying query...");
		#endif
		CreateTimer(QUERY_DELAY, QueryAgain, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
		return;
	}
	
	new JSON:hJson = json_decode(sQueryData); 
	new queryResult = -1;
	
	if (hJson != JSON_INVALID && json_get_cell(hJson, "duration", queryResult) && queryResult > -1) // result was valid json, and had valid data in it
	{
		#if defined SHOW_CONSOLE_MESSAGES
		PrintToConsole(client, "Query finished, backend returned delay of %i", queryResult);
		#endif
		//Update the delay timer
		g_iDynamicDisplayTime[client] = queryResult;
		g_bIsQueryRunning[client] = false;
		return;
	}
	//else if (g_iNumQueryAttempts[client] >= MAX_QUERY_ATTEMPTS)
	else if (!IsClientInForcedCooldown(client))
	{
		#if defined SHOW_CONSOLE_MESSAGES
		PrintToConsole(client, "Query failed: Giving up after %i attempts.", g_iNumQueryAttempts[client]);
		#endif
		g_iNumQueryAttempts[client] = 1;
		g_bIsQueryRunning[client] = false;
		return;
	}
	else
	{ 
		#if defined SHOW_CONSOLE_MESSAGES
		PrintToConsole(client, "Query failed: Retrying...", sQueryData);
		#endif
		
		CreateTimer(QUERY_DELAY, QueryAgain, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
		return;
	}
}
