#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <clientprefs>
#include <retakes>
#include "include/restorecvars.inc"

bool g_AWP[MAXPLAYERS + 1] = false;
bool g_Force_CT = false;
bool g_Force_T = false;
bool g_GunMenu[MAXPLAYERS + 1] = false;

ConVar g_Mode;
ConVar g_PistolRound;
ConVar g_PistolRoundNumber;
ConVar g_PistolRoundRandom;
ConVar g_AWP_CT;
ConVar g_AWP_T;
ConVar g_FullRound_Money;
ConVar g_ForceRound;
ConVar g_ForceRoundRandom;
ConVar g_ForceRound_Money;
ConVar g_AWP_Random;
ConVar g_Taser;
ConVar g_Taser_CT;
ConVar g_Taser_T;
ConVar g_Taser_Random;
ConVar g_Smoke_CT;
ConVar g_Smoke_T;
ConVar g_Fire_CT;
ConVar g_Fire_T;
ConVar g_Grenade_CT;
ConVar g_Grenade_T;
ConVar g_Flash_CT;
ConVar g_Flash_T;

Handle g_hPistol_CT = null;
Handle g_hPistol_T = null;
Handle g_hFull_Pistol_CT = null;
Handle g_hFull_Pistol_T = null;
Handle g_hSMG_CT = null;
Handle g_hSMG_T = null;
Handle g_hRifle_CT = null;
Handle g_hRifle_T = null;
Handle g_hAWP = null;

char g_Pistol_CT[MAXPLAYERS + 1][64];
char g_Pistol_T[MAXPLAYERS + 1][64];
char g_Full_Pistol_CT[MAXPLAYERS + 1][64];
char g_Full_Pistol_T[MAXPLAYERS + 1][64];
char g_SMG_CT[MAXPLAYERS + 1][64];
char g_SMG_T[MAXPLAYERS + 1][64];
char g_Rifle_CT[MAXPLAYERS + 1][64];
char g_Rifle_T[MAXPLAYERS + 1][64];
char g_RoundType[64];
char g_BombSite[64];
char enabled[64];
char disabled[64];

int g_Pistol_Round = 0;
int g_iAWP_CT = 0;
int g_iAWP_T = 0;
int g_igrenade_CT = 0;
int g_igrenade_T = 0;
int g_iFlash_CT = 0;
int g_iFlash_T = 0;
int g_iSmoke_CT = 0;
int g_iSmoke_T = 0;
int g_iFire_CT = 0;
int g_iFire_T = 0;
int g_iTaser_CT = 0;
int g_iTaser_T = 0;
int g_Smoke[MAXPLAYERS + 1];
int g_Flash[MAXPLAYERS + 1];
int g_Fire[MAXPLAYERS + 1];
int g_Grenade[MAXPLAYERS + 1];

Menu menus;

public Plugin myinfo = {
	name = "[Retakes] Guns",
	author = "Xc_ace",	
	description = "Retakes Guns",
	version = "1.5",
	url = "https://cncsgo.com.cn"
}

public void OnPluginStart(){
	RegConsoleCmd("sm_m", Command_GunMenu);
	RegConsoleCmd("sm_weapon", Command_Guns);
	RegConsoleCmd("sm_awp", Command_AWP);
	
	LoadTranslations("retakes.guns.phrases");
	
	g_Mode = CreateConVar("sm_retakes_mode", "0", "0 - random round, 1 - order round", _, true, 0.0, true, 1.0);
	g_PistolRound = CreateConVar("sm_retakes_pistolround", "1", "0 - disable, 1 - enabled", _, true, 0.0, true, 1.0);
	g_PistolRoundNumber = CreateConVar("sm_retakes_pistolround_number", "5", "how many rounds in pistol?(sm_retakes_mode 1)");
	g_PistolRoundRandom = CreateConVar("sm_retakes_pistolround_random", "5", "what percentage will be the pistol round?(sm_retakes_mode 0)");
	g_ForceRound = CreateConVar("sm_retakes_forceround", "1", "0 - disable, 1 - enabled", _, true, 0.0, true, 1.0);
	g_ForceRoundRandom = CreateConVar("sm_retakes_forceround_random", "5", "what percentage will be the force round?(sm_retakes_mode 0)")
	g_ForceRound_Money = CreateConVar("sm_retakes_forceround_money", "2350", "how much money in force round to buy?");
	g_AWP_CT = CreateConVar("sm_retakes_awp_ct", "1", "how many awp at most in CT?");
	g_AWP_T = CreateConVar("sm_retakes_awp_t", "1", "how many awp at most in T?");
	g_FullRound_Money = CreateConVar("sm_retakes_fullround_money", "10000", "how much money in full round to buy?");
	g_AWP_Random = CreateConVar("sm_retakes_awp_random", "75", "what percentage will have awp?");
	g_Taser = CreateConVar("sm_retakes_taser", "0", "0 - disable, 1 - enabled", _, true, 0.0, true, 1.0);
	g_Taser_CT = CreateConVar("sm_retakes_taser_ct", "1", "how many taser at most in CT?");
	g_Taser_T = CreateConVar("sm_retakes_taser_t", "1", "how many taser at most in T");
	g_Taser_Random = CreateConVar("sm_retakes_taser_random", "5", "what percentage will have taser?");
	g_Fire_CT = CreateConVar("sm_retakes_fire_ct", "2", "how many firegrende at most in CT?");
	g_Fire_T = CreateConVar("sm_retakes_fire_t", "2", "how many firegrenade at most in T?");
	g_Flash_CT = CreateConVar("sm_retakes_flash_ct", "5", "how many flashbang at most in CT?");
	g_Flash_T = CreateConVar("sm_retakes_flash_t", "5", "how many flashbang at most in T?");
	g_Grenade_CT = CreateConVar("sm_retakes_grenade_ct", "2", "how many hegrenade at most in CT?");
	g_Grenade_T = CreateConVar("sm_retakes_hegrenade_t", "2", "how many hegrenade at most in T?");
	g_Smoke_CT = CreateConVar("sm_retakes_smoke_ct", "2", "how many smoke at most in CT?");
	g_Smoke_T = CreateConVar("sm_retakes_smoke_t", "2", "how many smoke at most in T?");
	
	AutoExecConfig(true, "retakes_guns");
	
	g_hPistol_CT = RegClientCookie("Pistol CT", "", CookieAccess_Private);
	g_hPistol_T = RegClientCookie("Pistol T", "", CookieAccess_Private);
	g_hFull_Pistol_CT = RegClientCookie("Full Pistol CT", "", CookieAccess_Private);
	g_hFull_Pistol_T = RegClientCookie("Full Pistol T", "", CookieAccess_Private);
	g_hSMG_CT = RegClientCookie("SMG CT", "", CookieAccess_Private);
	g_hSMG_T = RegClientCookie("SMG T", "", CookieAccess_Private);
	g_hRifle_CT = RegClientCookie("Rifle CT", "", CookieAccess_Private);
	g_hRifle_T = RegClientCookie("Rifle T", "", CookieAccess_Private);
	g_hAWP = RegClientCookie("AWP", "", CookieAccess_Private);
	
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	
	ExecuteAndSaveCvars("sourcemod/retakes_guns.cfg");
	
	FormatEx(enabled, sizeof(enabled), "%t", "Enabled");
	FormatEx(disabled, sizeof(disabled), "%t", "Disabled");
}

public void OnAllPluginsLoaded()
{
	DisablePlugin("retakes_pistolallocator");
	DisablePlugin("retakes_standardallocator");
	DisablePlugin("retakes_ziksallocator");
	DisablePlugin("retakes_gdk_allocator");
	DisablePlugin("gunmenu");
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 0; i < MaxClients; i++){
		if (IsValidClient(i)){
			//CloseHandle(menus);
			CancelClientMenu(i);
		}
	}
}

public void Retakes_OnGunsCommand(int client)
{
	Menus_Pistol(client);
}

public void OnClientConnected(int client)
{
	Format(g_Rifle_CT[client], sizeof(g_Rifle_CT), "weapon_m4a1");
	Format(g_Pistol_CT[client], sizeof(g_Pistol_CT), "weapon_usp_silencer");
	Format(g_Full_Pistol_CT[client], sizeof(g_Full_Pistol_CT), "weapon_usp_silencer");
	Format(g_SMG_CT[client], sizeof(g_SMG_CT), "weapon_ump45");
	Format(g_Rifle_T[client], sizeof(g_Rifle_T), "weapon_ak47");
	Format(g_Pistol_T[client], sizeof(g_Pistol_T), "weapon_glock");
	Format(g_Full_Pistol_T[client], sizeof(g_Full_Pistol_T), "weapon_glock");
	Format(g_SMG_T[client], sizeof(g_SMG_T), "weapon_ump45");
	g_AWP[client] = true;
}

public void OnClientCookiesCached(int client)
{
	if (IsFakeClient(client)){
		return;
	}
	char sBuffer[64];
	
	GetClientCookie(client, g_hPistol_CT, sBuffer, sizeof(sBuffer));
	if (strlen(sBuffer) > 5){
		Format(g_Pistol_CT[client], sizeof(g_Pistol_CT), sBuffer);
	}
	
	GetClientCookie(client, g_hFull_Pistol_CT, sBuffer, sizeof(sBuffer));
	if (strlen(sBuffer) > 5){
		Format(g_Full_Pistol_CT[client], sizeof(g_Full_Pistol_CT), sBuffer);
	}
	
	GetClientCookie(client, g_hSMG_CT, sBuffer, sizeof(sBuffer));
	if (strlen(sBuffer) > 5){
		Format(g_SMG_CT[client], sizeof(g_SMG_CT), sBuffer);
	}
	
	GetClientCookie(client, g_hRifle_CT, sBuffer, sizeof(sBuffer));
	if (strlen(sBuffer) > 5){
		Format(g_Rifle_CT[client], sizeof(g_Rifle_CT), sBuffer);
	}
	
	GetClientCookie(client, g_hPistol_T, sBuffer, sizeof(sBuffer));
	if (strlen(sBuffer) > 5){
		Format(g_Pistol_T[client], sizeof(g_Pistol_T), sBuffer);
	}
	
	GetClientCookie(client, g_hFull_Pistol_T, sBuffer, sizeof(sBuffer));
	if (strlen(sBuffer) > 5){
		Format(g_Full_Pistol_T[client], sizeof(g_Full_Pistol_T), sBuffer);
	}
	
	GetClientCookie(client, g_hSMG_T, sBuffer, sizeof(sBuffer));
	if (strlen(sBuffer) > 5){
		Format(g_SMG_T[client], sizeof(g_SMG_T), sBuffer);
	}
	
	GetClientCookie(client, g_hRifle_T, sBuffer, sizeof(sBuffer));
	if (strlen(sBuffer) > 5){
		Format(g_Rifle_T[client], sizeof(g_Rifle_T), sBuffer);
	}
	GetClientCookie(client, g_hAWP, sBuffer, sizeof(sBuffer));
	if (sBuffer[0] != '\0')
	{
		g_AWP[client] = view_as<bool>(StringToInt(sBuffer));
	}
}

public void OnClientDisconnect(int client)
{
	if (IsFakeClient(client)){
		return;
	}
	SetClientCookie(client, g_hRifle_CT, g_Rifle_CT[client]);
	SetClientCookie(client, g_hPistol_CT, g_Pistol_CT[client]);
	SetClientCookie(client, g_hFull_Pistol_CT, g_Full_Pistol_CT[client]);
	SetClientCookie(client, g_hSMG_CT, g_SMG_CT[client]);
	SetClientCookie(client, g_hRifle_T, g_Rifle_T[client]);
	SetClientCookie(client, g_hPistol_T, g_Pistol_T[client]);
	SetClientCookie(client, g_hFull_Pistol_T, g_Full_Pistol_T[client]);
	SetClientCookie(client, g_hSMG_T, g_SMG_T[client]);
	SetClientCookie(client, g_hAWP, g_AWP[client] ? "1" : "0");
	g_GunMenu[client] = false;
}

public Action Command_GunMenu(int client, int argc)
{
	menus = new Menu(Handler_GunMenu);
	menus.SetTitle("%t", "Main Menu Title");
	char info[256];
	if (GetClientTeam(client) == CS_TEAM_CT){
		FormatEx(info, sizeof(info), "%t", "Main Menu Rifle", GetWeaponName(g_Rifle_CT[client]));
		menus.AddItem("rifle", info);
		FormatEx(info, sizeof(info), "%t", "Main Menu Pistol Round", GetWeaponName(g_Pistol_CT[client]));
		menus.AddItem("pistol", info);
		FormatEx(info, sizeof(info), "%t", "Main Menu Full Buy Round", GetWeaponName(g_Full_Pistol_CT[client]));
		menus.AddItem("fullpistol", info);
		FormatEx(info, sizeof(info), "%t", "Main Menu SMG", GetWeaponName(g_SMG_CT[client]));
		menus.AddItem("smg", info);
	}
	else if(GetClientTeam(client) == CS_TEAM_T){
		FormatEx(info, sizeof(info), "%t", "Main Menu Rifle", GetWeaponName(g_Rifle_T[client]));
		menus.AddItem("rifle", info);
		FormatEx(info, sizeof(info), "%t", "Main Menu Pistol Round", GetWeaponName(g_Pistol_T[client]));
		menus.AddItem("pistol", info);
		FormatEx(info, sizeof(info), "%t", "Main Menu Full Buy Round", GetWeaponName(g_Full_Pistol_T[client]));
		menus.AddItem("fullpistol", info);
		FormatEx(info, sizeof(info), "%t", "Main Menu SMG", GetWeaponName(g_SMG_T[client]));
		menus.AddItem("smg", info);
	} else {
		Retakes_Message(client, "%t", "No Spectator Select Weapon");
		return;
	}
	FormatEx(info, sizeof(info), "%t", "Main Menu AWP", g_AWP[client] ? enabled:disabled);
	menus.AddItem("awp", info);
	menus.Display(client, MENU_TIME_FOREVER);
}

public int Handler_GunMenu(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select){
		g_GunMenu[client] = true;
		char sBuffer[64];
		menu.GetItem(select, sBuffer, sizeof(sBuffer));
		if (StrEqual(sBuffer, "rifle") == true){
			Menus_Rifle(client);
		}
		else if(StrEqual(sBuffer, "pistol") == true){
			Menus_Pistol(client);
		}
		else if(StrEqual(sBuffer, "fullpistol") == true){
			Menus_Full_Pistol(client);
		}
		else if(StrEqual(sBuffer, "smg") == true){
			Menus_SMG(client);
		}
		else {
			Menus_AWP(client);
		}
	}
}

void DisablePlugin(char[] plugin)
{
	char sPath[64];
	BuildPath(Path_SM, sPath, sizeof(sPath), "plugins/%s.smx", plugin);
	if (FileExists(sPath))
	{
		char sNewPath[64];
		BuildPath(Path_SM, sNewPath, sizeof(sNewPath), "plugins/disabled/%s.smx", plugin);

		ServerCommand("sm plugins unload %s", plugin);

		if (FileExists(sNewPath))
		{
			DeleteFile(sNewPath);
		}
		RenameFile(sNewPath, sPath);

		LogMessage("%s was unloaded and moved to %s to avoid conflicts", sPath, sNewPath);
	}
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!Retakes_Live()){
		return;
	}
	g_iTaser_CT = 0;
	g_iTaser_T = 0;
	g_Force_CT = false;
	g_Force_T = false;
	if (g_Mode.BoolValue){
		if (g_Pistol_Round < g_PistolRoundNumber.IntValue && g_PistolRound.BoolValue){
			g_Pistol_Round++;
			Format(g_RoundType, sizeof(g_RoundType), "pistol");
		}
		else {
			Format(g_RoundType, sizeof(g_RoundType), "full");
			int random = GetRandomInt(1, 100);
			if (random <= g_ForceRoundRandom.IntValue){
				random = GetRandomInt(1, 2);
				if (random == 1){
					g_Force_CT = true;
				
				} else {
					g_Force_T = true;
				}
			}
		}
		GiveAllPlayerWeapon();
	}
	else {
		int random = GetRandomInt(1, 100);
	
		if (random <= g_PistolRoundRandom.IntValue && g_PistolRound.BoolValue){
			Format(g_RoundType, sizeof(g_RoundType), "pistol");
		}
		else {
			Format(g_RoundType, sizeof(g_RoundType), "full");
			random = GetRandomInt(1, 100);
			if (random <= g_ForceRoundRandom.IntValue){
				random = GetRandomInt(1, 2);
				if (random == 1){
					g_Force_CT = true;
				} else {
						g_Force_T = true;
					}
				}
		}
		GiveAllPlayerWeapon();
	}
}

public int Handler_Pistol(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select){
		char sBuffer[64];
		menu.GetItem(select, sBuffer, sizeof(sBuffer));
		if (GetClientTeam(client) == CS_TEAM_CT){
			Format(g_Pistol_CT[client], sizeof(g_Pistol_CT), sBuffer);
		}
		else if(GetClientTeam(client) == CS_TEAM_T){
			Format(g_Pistol_T[client], sizeof(g_Pistol_T), sBuffer);
		}
		if (g_GunMenu[client] == false){
			Menus_Full_Pistol(client);
		} else {
			g_GunMenu[client] = false;
			Retakes_Message(client, "%t", "Use Weapon Next Round");
		}
	}
}

public int Handler_Full_Pistol(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select){
		char sBuffer[64];
		menu.GetItem(select, sBuffer, sizeof(sBuffer));
		if (GetClientTeam(client) == CS_TEAM_CT){
			Format(g_Full_Pistol_CT[client], sizeof(g_Full_Pistol_CT), sBuffer);
		}
		else if(GetClientTeam(client) == CS_TEAM_T){
			Format(g_Full_Pistol_T[client], sizeof(g_Full_Pistol_T), sBuffer);
		}
		if (g_GunMenu[client] == false){
			Menus_SMG(client);
		} else {
			g_GunMenu[client] = false;
			Retakes_Message(client, "%t", "Use Weapon Next Round");
		}
	}
}

public int Handler_SMG(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select){
		char sBuffer[64];
		menu.GetItem(select, sBuffer, sizeof(sBuffer));
		if (GetClientTeam(client) == CS_TEAM_CT){
			Format(g_SMG_CT[client], sizeof(g_SMG_CT), sBuffer);
		}
		else if(GetClientTeam(client) == CS_TEAM_T){
			Format(g_SMG_T[client], sizeof(g_SMG_T), sBuffer);
		}
		if (g_GunMenu[client] == false){
			Menus_Rifle(client);
		} else {
			g_GunMenu[client] = false;
			Retakes_Message(client, "%t", "Use Weapon Next Round");
		}
	}
}

public int Handler_Rifle(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select){
		char sBuffer[64];
		menu.GetItem(select, sBuffer, sizeof(sBuffer));
		if (GetClientTeam(client) == CS_TEAM_CT){
			Format(g_Rifle_CT[client], sizeof(g_Rifle_CT), sBuffer);
		}
		else if(GetClientTeam(client) == CS_TEAM_T){
			Format(g_Rifle_T[client], sizeof(g_Rifle_T), sBuffer);
		}
		if (g_GunMenu[client] == false){
			Menus_AWP(client);
		} else {
			g_GunMenu[client] = false;
			Retakes_Message(client, "%t", "Use Weapon Next Round");
		}
	}
}

public int Handler_AWP(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select){
		char sBuffer[64];
		menu.GetItem(select, sBuffer, sizeof(sBuffer));
		if (strcmp(sBuffer, "1") == 0)
		{
			g_AWP[client] = true;
		}
		else
		{
			g_AWP[client] = false;
		}
		Retakes_Message(client, "%t", "Use Weapon Next Round");
	}
}

public Action Command_Guns(int client, int args)
{
	if (GetClientTeam(client) == CS_TEAM_SPECTATOR){
		Retakes_Message(client, "%t", "No Spectator Select Weapon");
		return Plugin_Handled;
	}
	Menus_Pistol(client);
	return Plugin_Continue;
}

public Action Command_AWP(int client, int args)
{
	if (GetClientTeam(client) == CS_TEAM_SPECTATOR){
		Retakes_Message(client, "%t", "No Spectator Select Weapon");
		return Plugin_Handled;
	}
	Menus_AWP(client);
	return Plugin_Continue;
}

void Menus_Pistol(int client)
{
	menus = new Menu(Handler_Pistol);
	if (GetClientTeam(client) == CS_TEAM_CT){
		menus.SetTitle("%t", "Gun Menu Pistol Round CT", GetWeaponName(g_Pistol_CT[client]));
		menus.AddItem("weapon_usp_silencer", "USP-S");
		menus.AddItem("weapon_hkp2000", "P2000");
		menus.AddItem("weapon_fiveseven", "FN57");
	}
	else if(GetClientTeam(client) == CS_TEAM_T){
		menus.SetTitle("%t", "Gun Menu Pistol Round T", GetWeaponName(g_Pistol_T[client]))
		menus.AddItem("weapon_glock", "Glock-18");
		menus.AddItem("weapon_tec9", "Tec-9");
	}
	menus.AddItem("weapon_deagle", "Desert Eagle");
	menus.AddItem("weapon_revolver", "Revolver");
	menus.AddItem("weapon_cz75a", "CZ75");
	menus.AddItem("weapon_p250", "P250");
	menus.ExitButton = true;
	menus.Display(client, MENU_TIME_FOREVER);
}

void Menus_Full_Pistol(int client)
{
	menus = new Menu(Handler_Full_Pistol);
	if (GetClientTeam(client) == CS_TEAM_CT){
		menus.SetTitle("%t", "Gun Menu Full Round Pistol CT", GetWeaponName(g_Full_Pistol_CT[client]));
		menus.AddItem("weapon_usp_silencer", "USP-S");
		menus.AddItem("weapon_hkp2000", "P2000");
		menus.AddItem("weapon_fiveseven", "FN57");
	}
	else if(GetClientTeam(client) == CS_TEAM_T){
		menus.SetTitle("%t", "Gun Menu Full Round Pistol T", GetWeaponName(g_Full_Pistol_T[client]));
		menus.AddItem("weapon_glock", "Glock-18");
		menus.AddItem("weapon_tec9", "Tec-9");
	}
	menus.AddItem("weapon_deagle", "Desert Eagle");
	menus.AddItem("weapon_revolver", "Revolver");
	menus.AddItem("weapon_cz75a", "CZ75");
	menus.AddItem("weapon_p250", "P250");
	menus.ExitButton = true;
	menus.Display(client, MENU_TIME_FOREVER);
}

void Menus_SMG(int client)
{
	menus = new Menu(Handler_SMG);
	if (GetClientTeam(client) == CS_TEAM_CT){
		menus.SetTitle("%t", "Gun Menu SMG CT", GetWeaponName(g_SMG_CT[client]));
		menus.AddItem("weapon_mp9", "MP9");
		menus.AddItem("weapon_mag7", "Mag-7");
	}
	else if(GetClientTeam(client) == CS_TEAM_T){
		menus.SetTitle("%t", "Gun Menu SMG T", GetWeaponName(g_SMG_T[client]));
		menus.AddItem("weapon_mac10", "Mac-10");
		menus.AddItem("weapon_sawedoff", "Sawed-Off");
	}
	menus.AddItem("weapon_ump45", "UMP-45");
	menus.AddItem("weapon_bizon", "PP-Bizon");
	menus.AddItem("weapon_p90", "P90");
	menus.AddItem("weapon_mp7", "MP7");
	menus.AddItem("weapon_mp5sd", "MP5-SD");
	menus.AddItem("weapon_xm1014", "XM1014");
	menus.AddItem("weapon_nova", "Nova");
	menus.ExitButton = true;
	menus.Display(client, MENU_TIME_FOREVER);
}

void Menus_Rifle(int client)
{
	menus = new Menu(Handler_Rifle);
	if (GetClientTeam(client) == CS_TEAM_CT){
		menus.SetTitle("%t", "Gun Menu Rifle CT", GetWeaponName(g_Rifle_CT[client]));
		menus.AddItem("weapon_m4a1", "M4A4");
		menus.AddItem("weapon_m4a1_silencer", "M4A1-S");
		menus.AddItem("weapon_famas", "Famas");
		menus.AddItem("weapon_aug", "AUG");
	}
	else if(GetClientTeam(client) == CS_TEAM_T){
		menus.SetTitle("%t", "Gun Menu Rifle T", GetWeaponName(g_Rifle_T[client]));
		menus.AddItem("weapon_ak47", "AK-47");
		menus.AddItem("weapon_galilar", "Galil AR");
		menus.AddItem("weapon_sg556", "SG 553");
	}
	menus.ExitButton = true;
	menus.Display(client, MENU_TIME_FOREVER);
}

void Menus_AWP(int client)
{
	menus = new Menu(Handler_AWP);
	menus.SetTitle("%t", "Gun Menu AWP", g_AWP[client] ? enabled:disabled);
	char Yes[64];
	char No[64];
	FormatEx(Yes, sizeof(Yes), "%t", "Yes");
	FormatEx(No, sizeof(No), "%t", "No");
	menus.AddItem("1", Yes);
	menus.AddItem("0", No);
	menus.Display(client, MENU_TIME_FOREVER);
}

void GiveAllPlayerWeapon()
{
	g_iAWP_CT = 0;
	g_iAWP_T = 0;
	g_igrenade_CT = 0;
	g_igrenade_T = 0;
	g_iFlash_CT = 0;
	g_iFlash_T = 0;
	g_iSmoke_CT = 0;
	g_iSmoke_T = 0;
	g_iFire_CT = 0;
	g_iFire_T = 0;
	
	ShowInfo();
	for (int i = 0; i < MaxClients; i++){
		if (IsValidClient(i)){
			g_Smoke[i] = 0;
			g_Fire[i] = 0
			g_Grenade[i] = 0;
			g_Flash[i] = 0;
			GivePlayerWeapon(i);
		}
	}
}

void GivePlayerWeapon(int client)
{
	int iMoney = 0;
	StripPlayerWeapons(client);
	if (GetClientTeam(client) == CS_TEAM_CT){
		GivePlayerItem(client, "weapon_knife");
	}
	else if(GetClientTeam(client) == CS_TEAM_T){
		GivePlayerItem(client, "weapon_knife_t");
	}
	SetEntProp(client, Prop_Send, "m_ArmorValue", 0);
	SetEntProp(client, Prop_Send, "m_bHasHelmet", 0);
	SetEntProp(client, Prop_Send, "m_bHasDefuser", 0);
	
	if (StrEqual(g_RoundType, "pistol") == true){
		iMoney = 800;
		if (GetClientTeam(client) == CS_TEAM_CT){
			GivePlayerItem(client, g_Pistol_CT[client]);
			if (StrEqual(g_Pistol_CT[client], "weapon_hkp2000") == true || StrEqual(g_Pistol_CT[client], "weapon_usp_silencer") == true){
				GiveArmor(client);
			}
			else {
				iMoney -= GetWeaponPrice(g_Pistol_CT[client]);
			}
		}
		else if (GetClientTeam(client) == CS_TEAM_T){
			GivePlayerItem(client, g_Pistol_T[client]);
			if (StrEqual(g_Pistol_T[client], "weapon_glock") == true){
				GiveArmor(client);
			}
			else {
				iMoney -= GetWeaponPrice(g_Pistol_T[client]);
			}
		}
	}
	else if(StrEqual(g_RoundType, "full") == true){
		iMoney = g_FullRound_Money.IntValue;
		if (GetClientTeam(client) == CS_TEAM_CT && g_Force_CT == false){
			int random = GetRandomInt(1, 100);
			if (random < g_AWP_Random.IntValue && g_AWP[client]){
				if (g_iAWP_CT < g_AWP_CT.IntValue){
					GivePlayerItem(client, "weapon_awp");
					iMoney -= GetWeaponPrice("weapon_awp");
					g_iAWP_CT++;
				}
				else {
					GivePlayerItem(client, g_Rifle_CT[client]);
					iMoney -= GetWeaponPrice(g_Rifle_CT[client]);
				}
			}
			else {
				GivePlayerItem(client, g_Rifle_CT[client]);
				iMoney -= GetWeaponPrice(g_Rifle_CT[client]);
			}
			GivePlayerItem(client, g_Full_Pistol_CT[client]);
			iMoney -= GetWeaponPrice(g_Full_Pistol_CT[client]);
		}
		else if (GetClientTeam(client) == CS_TEAM_T && g_Force_T == false){
			int random = GetRandomInt(1, 10);
			if (random < g_AWP_Random.IntValue && g_AWP[client]){
				if (g_iAWP_T < g_AWP_T.IntValue){
					GivePlayerItem(client, "weapon_awp");
					iMoney -= GetWeaponPrice("weapon_awp");
					g_iAWP_T++;
				}
				else {
					GivePlayerItem(client, g_Rifle_T[client]);
					iMoney -= GetWeaponPrice(g_Rifle_T[client]);
				}
			}
			else {
				GivePlayerItem(client, g_Rifle_T[client]);
				iMoney -= GetWeaponPrice(g_Rifle_T[client]);
			}
			GivePlayerItem(client, g_Full_Pistol_T[client]);
			iMoney -= GetWeaponPrice(g_Full_Pistol_T[client]);
		}
		
		if (g_ForceRound.BoolValue){
			if (GetClientTeam(client) == CS_TEAM_CT && g_Force_CT == true){
				iMoney = g_ForceRound_Money.IntValue;
				GivePlayerItem(client, g_SMG_CT[client]);
				iMoney -= GetWeaponPrice(g_SMG_CT[client]);
				if (iMoney >= GetWeaponPrice(g_Pistol_CT[client])){
					GivePlayerItem(client, g_Pistol_CT[client]);
					iMoney -= GetWeaponPrice(g_Pistol_CT[client]);
				}
				else {
					GivePlayerItem(client, "weapon_usp_silencer");
				}
			}
			else if (GetClientTeam(client) == CS_TEAM_T && g_Force_T == true){
				iMoney = g_ForceRound_Money.IntValue;
				GivePlayerItem(client, g_SMG_T[client]);
				iMoney -= GetWeaponPrice(g_SMG_T[client]);
				if (iMoney >= GetWeaponPrice(g_Pistol_T[client])){
					GivePlayerItem(client, g_Pistol_T[client]);
					iMoney -= GetWeaponPrice(g_Pistol_T[client]);
				}
				else {
					GivePlayerItem(client, "weapon_glock");
				}
			}
		}
		if (650 <= iMoney < 1000){
			GiveArmor(client);
			iMoney -= 650;
		}
		else if(iMoney >= 1000){
			GiveArmorKit(client);
			iMoney -= 1000;
		}
		if (g_Taser.BoolValue){
			int random = GetRandomInt(1, 100);
			if (random <= g_Taser_Random.IntValue){
				if (GetClientTeam(client) == CS_TEAM_CT && g_iTaser_CT < g_Taser_CT.IntValue && iMoney >= 400){
					GivePlayerItem(client, "weapon_taser");
					g_iTaser_CT++;
				}
				else if(GetClientTeam(client) == CS_TEAM_T && g_iTaser_T < g_Taser_T.IntValue && iMoney >= 400){
					GivePlayerItem(client, "weapon_taser");
					g_iTaser_T++;
				}
			}
		}
		if (GetClientTeam(client) == CS_TEAM_CT){
			if (iMoney >= 400){
				SetEntProp(client, Prop_Send, "m_bHasDefuser", 1);
				iMoney -= 400;
			}
		}
		for (int i = 0; i < 2; i++){
			if (GetClientTeam(client) == CS_TEAM_CT){
				int random = GetRandomInt(1, 4);
				if (random == 1 && iMoney >= 400 && g_iSmoke_CT < g_Smoke_CT.IntValue && g_Smoke[client] == 0){
					GivePlayerItem(client, "weapon_smokegrenade");
					g_iSmoke_CT++;
					iMoney -= 400;
					g_Smoke[client]++;
				}
				else if (random == 2 && iMoney >= 300 && g_iFlash_CT < g_Flash_CT.IntValue && g_Flash[client] < 2){
					GivePlayerItem(client, "weapon_flashbang");
					g_iFlash_CT++;
					iMoney -= 300;
					g_Flash[client]++;
				}
				else if(random == 3 && iMoney >= 600 && g_iFire_CT < g_Fire_CT.IntValue && g_Fire[client] == 0){
					GivePlayerItem(client, "weapon_incgrenade")
					g_iFire_CT++;
					iMoney -= 600;
					g_Fire[client]++;
				}
				else if(random == 4 && iMoney >= 300 && g_igrenade_CT < g_Grenade_CT.IntValue && g_Grenade[client] == 0){
					GivePlayerItem(client, "weapon_hegrenade");
					g_igrenade_CT++;
					iMoney -= 300;
					g_Grenade[client]++;
				}
			}
			else if (GetClientTeam(client) == CS_TEAM_T){
				int random = GetRandomInt(1, 4);
				if (random == 1 && iMoney >= 400 && g_iSmoke_T < g_Smoke_T.IntValue && g_Smoke[client] == 0){
					GivePlayerItem(client, "weapon_smokegrenade");
					g_iSmoke_T++;
					iMoney -= 400;
					g_Smoke[client]++;
				}
				else if (random == 2 && iMoney >= 300 && g_iFlash_T < g_Flash_T.IntValue && g_Flash[client] < 2){
					GivePlayerItem(client, "weapon_flashbang");
					g_iFlash_T++;
					iMoney -= 300;
					g_Flash[client]++;
				}
				else if(random == 3 && iMoney >= 400 && g_iFire_T < g_Fire_T.IntValue && g_Fire[client] == 0){
					GivePlayerItem(client, "weapon_incgrenade")
					g_iFire_T++;
					iMoney -= 400;
					g_Fire[client]++;
				}
				else if(random == 4 && iMoney >= 300 && g_igrenade_T < g_Grenade_T.IntValue && g_Grenade[client] == 0){
					GivePlayerItem(client, "weapon_hegrenade");
					g_igrenade_T++;
					iMoney -= 300;
					g_Grenade[client]++;
				}
			}
		}
	}
}

void GiveArmor(int client)
{
	SetEntProp(client, Prop_Send, "m_ArmorValue", 100);
}

void GiveArmorKit(int client)
{
	SetEntProp(client, Prop_Send, "m_ArmorValue", 100);
	SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
}

void StripPlayerWeapons(int client)
{
	int iWeapon;
	for (int i = 0; i <= 3; i++)
	{
		if ((iWeapon = GetPlayerWeaponSlot(client, i)) != -1)
		{
			RemovePlayerItem(client, iWeapon);
			AcceptEntityInput(iWeapon, "Kill");
		}
	}
	if ((iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_GRENADE)) != -1)
	{
		RemovePlayerItem(client, iWeapon);
		AcceptEntityInput(iWeapon, "Kill");
	}
}

void ShowInfo()
{
	char roundtype[64];
	if (StrEqual(g_RoundType, "pistol") == true){
		Format(roundtype, sizeof(roundtype), "%t", "Pistol Round");
	}
	else {
		Format(roundtype, sizeof(roundtype), "%t", "Full Buy Round");
	}
	Retakes_MessageToAll("%t", "Now Round", roundtype);
	
	Bombsite site = Retakes_GetCurrrentBombsite();
	
	if (site == BombsiteA){
		Format(g_BombSite, sizeof(g_BombSite), "%t", "Bombsite A");
	}
	else if (site == BombsiteB){
		Format(g_BombSite, sizeof(g_BombSite), "%t", "Bombsite B");
	}
	
	PrintHintTextToAll("t", "Hint Now Round", roundtype, g_BombSite);
}

bool IsValidClient(int client)
{
	if(!(1 <= client <= MaxClients) || !IsClientInGame(client))
	{
		return false;
	}
	return true;
}

char GetWeaponName(const char [] weapon)
{
	char name[256];
	if (StrEqual(weapon, "weapon_m4a1"))
		Format(name, sizeof(name), "M4A4");
	
	else if (StrEqual(weapon, "weapon_m4a1_silencer"))
		Format(name, sizeof(name), "M4A1-S");
	
	else if (StrEqual(weapon, "weapon_famas"))
		Format(name, sizeof(name), "法玛斯");
	
	else if (StrEqual(weapon, "weapon_aug"))
		Format(name, sizeof(name), "AUG");
	
	else if (StrEqual(weapon, "weapon_galilar"))
		Format(name, sizeof(name), "Galil AR");
		
	else if (StrEqual(weapon, "weapon_ak47"))
		Format(name, sizeof(name), "AK-47");
		
	else if (StrEqual(weapon, "weapon_sg556"))
		Format(name, sizeof(name), "SG 553");
		
	else if (StrEqual(weapon, "weapon_bizon"))
		Format(name, sizeof(name), "PP-Bizon");

	else if (StrEqual(weapon, "weapon_p90"))
		Format(name, sizeof(name), "P90");

	else if (StrEqual(weapon, "weapon_ump45"))
		Format(name, sizeof(name), "UMP-45");

	else if (StrEqual(weapon, "weapon_mp5sd"))
		Format(name, sizeof(name), "MP5-SD");

	else if (StrEqual(weapon, "weapon_mp7"))
		Format(name, sizeof(name), "MP7");

	else if (StrEqual(weapon, "weapon_mp9"))
		Format(name, sizeof(name), "MP9");

	else if (StrEqual(weapon, "weapon_mac10"))
		Format(name, sizeof(name), "Mac-10");

	else if (StrEqual(weapon, "weapon_deagle"))
		Format(name, sizeof(name), "Desert Eagle");

	else if (StrEqual(weapon, "weapon_revolver"))
		Format(name, sizeof(name), "Revolver");
	
	else if (StrEqual(weapon, "weapon_cz75a"))
		Format(name, sizeof(name), "CZ75");

	else if (StrEqual(weapon, "weapon_p250"))
		Format(name, sizeof(name), "P250");

	else if (StrEqual(weapon, "weapon_tec9"))
		Format(name, sizeof(name), "Tec-9");

	else if (StrEqual(weapon, "weapon_glock"))
		Format(name, sizeof(name), "Glock 18");

	else if (StrEqual(weapon, "weapon_usp_silencer"))
		Format(name, sizeof(name), "USP-S");

	else if (StrEqual(weapon, "weapon_hkp2000"))
		Format(name, sizeof(name), "P2000");

	else if (StrEqual(weapon, "weapon_fiveseven"))
		Format(name, sizeof(name), "FN57");

	else if (StrEqual(weapon, "weapon_sawedoff"))
		Format(name, sizeof(name), "Sawed-Off");

	else if (StrEqual(weapon, "weapon_mag7"))
		Format(name, sizeof(name), "Mag-7");

	else if (StrEqual(weapon, "weapon_elite"))
		Format(name, sizeof(name), "Elite");
	
	else if (StrEqual(weapon, "weapon_nova"))
		Format(name, sizeof(name), "Nova");
		
	else if (StrEqual(weapon, "weapon_xm1014"))
		Format(name, sizeof(name), "XM1014");
	
	return name;
}

int GetWeaponPrice(const char[] weapon)
{
	if (StrEqual(weapon, "weapon_m4a1"))
		return 3100;

	else if (StrEqual(weapon, "weapon_m4a1_silencer"))
		return 3100;

	else if (StrEqual(weapon, "weapon_famas"))
		return 2250;

	else if (StrEqual(weapon, "weapon_aug"))
		return 3300;

	else if (StrEqual(weapon, "weapon_galilar"))
		return 2000;

	else if (StrEqual(weapon, "weapon_ak47"))
		return 2700;

	else if (StrEqual(weapon, "weapon_sg556"))
		return 3000;

	else if (StrEqual(weapon, "weapon_awp"))
		return 4750;

	else if (StrEqual(weapon, "weapon_ssg08"))
		return 1700;

	else if (StrEqual(weapon, "weapon_bizon"))
		return 1400;

	else if (StrEqual(weapon, "weapon_p90"))
		return 2350;

	else if (StrEqual(weapon, "weapon_ump45"))
		return 1200;

	else if (StrEqual(weapon, "weapon_mp5sd"))
		return 1500;

	else if (StrEqual(weapon, "weapon_mp7"))
		return 1700;

	else if (StrEqual(weapon, "weapon_mp9"))
		return 1250;

	else if (StrEqual(weapon, "weapon_mac10"))
		return 1050;

	else if (StrEqual(weapon, "weapon_deagle"))
		return 700;

	else if (StrEqual(weapon, "weapon_revolver"))
		return 700;

	else if (StrEqual(weapon, "weapon_cz75a"))
		return 500;

	else if (StrEqual(weapon, "weapon_p250"))
		return 300;

	else if (StrEqual(weapon, "weapon_tec9"))
		return 500;

	else if (StrEqual(weapon, "weapon_glock"))
		return 0;

	else if (StrEqual(weapon, "weapon_usp_silencer"))
		return 0;

	else if (StrEqual(weapon, "weapon_hkp2000"))
		return 0;

	else if (StrEqual(weapon, "weapon_fiveseven"))
		return 500;

	else if (StrEqual(weapon, "weapon_sawedoff"))
		return 1200;

	else if (StrEqual(weapon, "weapon_mag7"))
		return 1800;

	else if (StrEqual(weapon, "weapon_elite"))
		return 500;

	else if (StrEqual(weapon, "weapon_hegrenade"))
		return 300;

	else if (StrEqual(weapon, "weapon_flashbang"))
		return 200;

	else if (StrEqual(weapon, "weapon_smokegrenade"))
		return 300;

	else if (StrEqual(weapon, "weapon_molotov"))
		return 400;

	else if (StrEqual(weapon, "weapon_incgrenade"))
		return 650;

	return 0;
}