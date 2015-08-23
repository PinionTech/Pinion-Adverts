/* pinion_adverts_lite.sp
Name: Pinion Adverts Lite
See changelog for complete list of authors and contributors

Description:
	Causes client to access a webpage when player has chosen a team.  Left 4 Dead will use
	player left start area / checkpoint.  The url will have have /host_ip/hostport/steamid
	added to it.  

Installation:
	Place compiled plugin (pinion_adverts_lite.smx) into your plugins folder.
	The configuration file (pinion_adverts_lite.cfg) is generated automatically.
	Changes to cvars made in console take effect immediately.

Files:
	./addons/sourcemod/plugins/pinion_adverts_lite.smx
	./cfg/sourcemod/pinion_adverts_lite.cfg

Configuration Variables: See pinion_adverts_lite.cfg.

------------------------------------------------------------------------------------------------------------------------------------
*/

#define PLUGIN_VERSION "0.0.2"
/*
Changelog
	
	0.0.* <-> 2015 - Caelan Borowiec
		Initial 'Lite' version changes

*/

#include <sourcemod>
#undef REQUIRE_PLUGIN
#tryinclude <updater>
#define REQUIRE_PLUGIN
#define STRING(%1) %1, sizeof(%1)

#pragma semicolon 1

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
public Plugin:myinfo =
{
	name = "Pinion Adverts Lite",
	author = "Multiple contributors",
	description = "Pinion in-game advertisements helper",
	version = PLUGIN_VERSION,
	url = "http://www.pinion.gg/"
};

// Some games require a title to explicitly be set (while others don't even show the set title)
#define MOTD_TITLE "Sponsor Message"

#define UPDATE_URL "http://bin.pinion.gg/bin/pinion_adverts_lite/updatefile.txt"

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
	kGameNMRIH,
	kGameFoF,
	kGameZPS,
	kGameDAB,
	kGameGES,
	kGameHidden,
};
new const String:g_SupportedGames[EGame][] = {
	"cstrike",
	"hl2mp",
	"dod",
	"tf",
	"left4dead",
	"left4dead2",
	"nucleardawn",
	"csgo",
	"nmrih",
	"fof",
	"zps",
	"dab",
	"gesource",
	"hidden"
};
new EGame:g_Game = kGameUnsupported;

// Console Variables
new Handle:g_ConVar_Community;

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
	
	
	AddCommandListener(PageClosed, "closed_htmlpage");
	
	// Specify console variables used to configure plugin
	g_ConVar_Community = CreateConVar("sm_motdredirect_community", "", "Target URL to replace MOTD");
	AutoExecConfig(true, "pinion_adverts_lite");

	// Version of plugin - Make visible to game-monitor.com - Dont store in configuration file
	CreateConVar("sm_motdredirect_version", PLUGIN_VERSION, "[SM] MOTD Redirect Version", FCVAR_NOTIFY|FCVAR_DONTRECORD);

	// More event hooks for the config files
	RefreshCvarCache();
	HookConVarChange(g_ConVar_Community, Event_CvarChange);
	
	for (new i = 1; i <= MaxClients; ++i)
	{
		if (!IsClientInGame(i))
			continue;

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
		Updater_AddPlugin(UPDATE_URL);
}
#endif

// Occurs after round_start
public OnConfigsExecuted()
{
	// Synchronize Cvar Cache after configuration loaded
	RefreshCvarCache();
	
	decl String:szCommunityName[128];
	GetConVarString(g_ConVar_Community, szCommunityName, sizeof(szCommunityName));
	
	if (StrEqual(szCommunityName, ""))
		LogError("ConVar sm_motdredirect_community has not been set:  Please check your pinion_adverts config file.");
}

// Called after all plugins are loaded
public OnAllPluginsLoaded()
{
	// Handle the motd_text.txt setup here
	if (FileExists("motd_text.txt")) // File exists: check contents
	{
		new Handle:hMOTD_Text = OpenFile("motd_text.txt", "r");
		new String:sOldMOTD[2048]; 
		ReadFileString(hMOTD_Text, sOldMOTD, 2048);
		CloseHandle(hMOTD_Text);
		
		if (StrContains(sOldMOTD, "Welcome to Team Fortress 2\n\nOur map rotation is:\n-", false) != -1)
		{
			if(!FileExists("motd_text_backup.txt"))
			{
				new Handle:hMOTD_Text_Backup = OpenFile("motd_text_backup.txt", "w");
				WriteFileString(hMOTD_Text_Backup, sOldMOTD, true);
				CloseHandle(hMOTD_Text_Backup);
			}
			RewriteTextMOTD();
		}
	}
	else	//There is no motd_text: lets write one
		RewriteTextMOTD();
}

RewriteTextMOTD()
{
	new Handle:hMOTD_Text = OpenFile("motd_text.txt", "w");
	WriteFileString(hMOTD_Text, "Community Message:\n\n\
You appear to have HTML MOTDs disabled.\n\
Please help to support this community by enabling them!\n\n\
Type cl_disablehtmlmotd 0 into console, or follow these steps:\n\
- Press Escape\n\
- Select Options\n\
- Select Multiplayer\n\
- Select Advanced\n\
- Uncheck Disable HTML MOTDs", true);
	CloseHandle(hMOTD_Text);
}


// Synchronize Cvar Cache when change made
public Event_CvarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	RefreshCvarCache();
}

RefreshCvarCache()
{
	// Build and cache url/ip/port string
	decl String:szCommunityName[128];
	GetConVarString(g_ConVar_Community, szCommunityName, sizeof(szCommunityName));
	
	ReplaceString(szCommunityName, sizeof(szCommunityName), " ", "");
	
	new hostip = GetConVarInt(FindConVar("hostip"));
	new hostport = GetConVarInt(FindConVar("hostport"));
	
	// Format: http://motd.pinion.gg/motd/communityname/game/etcetc
	Format(g_BaseURL, sizeof(g_BaseURL), "http://motd.pinion.gg/motd/%s/%s/?ip=%d.%d.%d.%d&po=%d",
		szCommunityName,
		g_SupportedGames[g_Game],
		hostip >>> 24 & 255, hostip >>> 16 & 255, hostip >>> 8 & 255, hostip & 255,
		hostport);
		
}

public OnClientConnected(client)
{
	ChangeState(client, kAwaitingAd);
}

public OnClientPostAdminCheck(client)
{
	if (g_Game == kGameNMRIH || g_Game == kGameZPS || g_Game == kGameDAB || g_Game == kGameGES || g_Game == kGameHidden)
	{
		if (IsFakeClient(client) || (GetState(client) != kAwaitingAd && GetState(client) != kViewingAd))
			return;
		
		new Handle:pack = CreateDataPack();
		WritePackCell(pack, GetClientSerial(client));
		WritePackCell(pack, AD_TRIGGER_CONNECT);
		CreateTimer(0.1, LoadPage, pack, TIMER_FLAG_NO_MAPCHANGE);
		
		return;
	}
}

public Action:Event_DoPageHit(Handle:timer, any:serial)
{
	// This event implies client is in-game while GetClientOfUserId() checks IsClientConnected()
	new client = GetClientFromSerial(serial);
	if (client && !IsFakeClient(client))
	{
		if (g_Game == kGameCSGO)
			ShowMOTDPanelEx(client, MOTD_TITLE, "javascript:windowClosed()", MOTDPANEL_TYPE_URL, MOTDPANEL_CMD_NONE, true);
		else if (g_Game == kGameNMRIH || g_Game == kGameZPS || g_Game == kGameDAB || g_Game == kGameGES || g_Game == kGameHidden)
			ShowMOTDPanelEx(client, "", "about:blank", MOTDPANEL_TYPE_URL, MOTDPANEL_CMD_NONE, false);
		else if (g_Game != kGameTF2)
			ShowMOTDPanelEx(client, "", "javascript:windowClosed()", MOTDPANEL_TYPE_URL, MOTDPANEL_CMD_NONE, false);
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


public Action:LoadPage(Handle:timer, Handle:pack)
{
	ResetPack(pack);
	new client = GetClientFromSerial(ReadPackCell(pack));
	new trigger = ReadPackCell(pack);
	CloseHandle(pack);
	
	if (!client || (g_Game == kGameCSGO && GetState(client) == kViewingAd))
		return Plugin_Stop;
	
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
		
		decl String:szAuth[MAX_AUTH_LENGTH];
		GetClientAuthId(client, AuthId_Steam2, szAuth, sizeof(szAuth));
		
		decl String:szURL[128];
		Format(szURL, sizeof(szURL), "%s&si=%s", g_BaseURL, szAuth);
		Format(szURL, sizeof(szURL), "%s&pv=%s&tr=%i", szURL, PLUGIN_VERSION, trigger);
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
	
	ChangeState(client, kAdClosing);

	return Plugin_Stop;
}

public Action:ClosePage(Handle:timer, Handle:pack)
{
	ResetPack(pack);
	new client = GetClientFromSerial(ReadPackCell(pack));
	
	if (!client)
		return;
	
	if (GetState(client) == kAdClosing || GetState(client) == kViewingAd)	//Ad is loaded
	{
		if (GetClientTeam(client) != 0 || g_Game == kGameNMRIH) // player has joined a team
			ShowMOTDPanelEx(client, MOTD_TITLE, "about:blank", MOTDPANEL_TYPE_URL, MOTDPANEL_CMD_NONE, false);
		else // Player still needs the menu open
			ShowMOTDPanelEx(client, MOTD_TITLE, "https://unikrn.com/sites/um100", MOTDPANEL_TYPE_URL, MOTDPANEL_CMD_NONE, true);
	}
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
				case kGameCSS, kGameCSGO:
					FakeClientCommand(client, "joingame");
				case kGameDODS, kGameND:
					ClientCommand(client, "changeteam");
			}
		}
	}
	
	return Plugin_Handled;
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
		|| g_Game == kGameNMRIH
		|| g_Game == kGameFoF
		|| g_Game == kGameZPS
		|| g_Game == kGameDAB
		;
}

