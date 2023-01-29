#include <sourcemod>
#include <clientprefs>
#include <cstrike>
#include <sdktools>
#include "include/eItems.inc"
#include "include/retakes.inc"
#include "include/restorecvars.inc"

#pragma newdecls required
#pragma semicolon 1

#include "retakes_guns/global.sp"
#include "retakes_guns/utils.sp"
#include "retakes_guns/round.sp"
#include "retakes_guns/weapons.sp"
#include "retakes_guns/menus.sp"

public Plugin myinfo = {
    name = "[Retakes] Guns",
    author = "Xc_ace",
    description = "Description",
    version = "2.0",
    url = "https://github.com/Cola-Ace/Retakes-Guns"
}

public void OnPluginStart(){
    RegConsoleCmd("sm_m", Command_GeneralMenu);
    RegConsoleCmd("sm_gun", Command_PistolMenu);
    RegConsoleCmd("sm_guns", Command_PistolMenu);
    RegConsoleCmd("sm_awp", Command_AWP);

    LoadTranslations("retakes.guns.phrases");

    g_cEnabled = CreateConVar("sm_retakes_guns_enabled", "1", "0 - Disable, 1 - Enable", _, true, 0.0, true, 1.0);
    g_cMode = CreateConVar("sm_retakes_guns_mode", "0", "0 - Sequential Round, 1 - Random Round", _, true, 0.0, true, 1.0);
    g_cPistolRound = CreateConVar("sm_retakes_guns_pistol", "1", "0 - Disable, 1 - Enable", _, true, 0.0, true, 1.0);
    g_cPistolRoundNumber = CreateConVar("sm_retakes_guns_pistol_number", "5", "The numbers of pistol rounds (only works in mode 0)");
    g_cPistolRoundRandom = CreateConVar("sm_retakes_guns_pistol_random", "10", "Percentage of probability (only works in mode 1)");
    g_cForceRound = CreateConVar("sm_retakes_guns_force", "0", "0 - Disable, 1 - Enable", _, true, 0.0, true, 1.0);
    g_cForceRoundRandom = CreateConVar("sm_retakes_guns_force_random", "5", "Percentage of probability");
    g_cUtilsMinimum = CreateConVar("sm_retakes_guns_utils_minimum", "0", "Minimum of utils for player", _, true, 0.0, true, 4.0);
    g_cUtilsMaximum = CreateConVar("sm_retakes_guns_utils_maximum", "2", "Maximum of utils for player", _, true, 0.0, true, 4.0);
    g_cAWP_CT = CreateConVar("sm_retakes_guns_awp_ct", "1", "Maximum of AWP in CT");
    g_cAWP_T = CreateConVar("sm_retakes_guns_awp_t", "1", "Maximum of AWP in T");

    AutoExecConfig(true, "retakes_guns");
    ExecuteAndSaveCvars("sourcemod/retakes_guns.cfg");

    g_hPistolCT = RegClientCookie("Pistol CT", "", CookieAccess_Private);
    g_hPistolT = RegClientCookie("Pistol T", "", CookieAccess_Private);
    g_hForceCT = RegClientCookie("Force CT", "", CookieAccess_Private);
    g_hForceT = RegClientCookie("Force T", "", CookieAccess_Private);
    g_hRifleCT = RegClientCookie("Rifle CT", "", CookieAccess_Private);
    g_hRifleT = RegClientCookie("Rifle T", "", CookieAccess_Private);
    g_hRiflePistolCT = RegClientCookie("Rifle Pistol CT", "", CookieAccess_Private);
    g_hRiflePistolT = RegClientCookie("Rifle Pistol T", "", CookieAccess_Private);
    g_hAWP = RegClientCookie("AWP", "", CookieAccess_Private);

    HookEvent("round_start", Event_RoundStart);
    HookEvent("round_end", Event_RoundEnd);

    g_WeaponGeneral = new ArrayList(32);
    g_WeaponCT = new ArrayList(32);
    g_WeaponT = new ArrayList(32);
    g_WeaponForceCT = new ArrayList(32);
    g_WeaponForceT = new ArrayList(32);
    g_WeaponForceGeneral = new ArrayList(32);
}

public void OnMapStart(){
    InitWeaponList();

    g_iPistolRound = 0;
}

public void OnConfigsExecuted(){
	ServerCommand("mp_ct_default_secondary \"weapon_usp_sliencer\"");
}

public void OnClientConnected(int client){
    if (IsFakeClient(client)) return;

    FormatEx(g_GunSelect[client].pistol_ct, sizeof(GunSelect::pistol_ct), "weapon_usp_silencer");
    FormatEx(g_GunSelect[client].pistol_t, sizeof(GunSelect::pistol_t), "weapon_glock");
    FormatEx(g_GunSelect[client].force_ct, sizeof(GunSelect::force_ct), "weapon_mp9");
    FormatEx(g_GunSelect[client].force_t, sizeof(GunSelect::force_t), "weapon_mac10");
    FormatEx(g_GunSelect[client].rifle_ct, sizeof(GunSelect::rifle_ct), "weapon_m4a1");
    FormatEx(g_GunSelect[client].rifle_t, sizeof(GunSelect::rifle_t), "weapon_ak47");
    FormatEx(g_GunSelect[client].rifle_pistol_ct, sizeof(GunSelect::rifle_pistol_ct), "weapon_usp_silencer");
    FormatEx(g_GunSelect[client].rifle_pistol_t, sizeof(GunSelect::rifle_pistol_t), "weapon_glock");
    g_GunSelect[client].awp = true;
}

public void OnClientCookiesCached(int client){
    if (IsFakeClient(client)) return;

    char buffer[64];
	
    GetClientCookie(client, g_hPistolCT, buffer, sizeof(buffer));
    if (strlen(buffer) > 5) FormatEx(g_GunSelect[client].pistol_ct, sizeof(GunSelect::pistol_ct), buffer);
	
    GetClientCookie(client, g_hPistolT, buffer, sizeof(buffer));
    if (strlen(buffer) > 5) FormatEx(g_GunSelect[client].pistol_t, sizeof(GunSelect::pistol_t), buffer);

    GetClientCookie(client, g_hRiflePistolCT, buffer, sizeof(buffer));
    if (strlen(buffer) > 5) FormatEx(g_GunSelect[client].rifle_pistol_ct, sizeof(GunSelect::rifle_pistol_ct), buffer);

    GetClientCookie(client, g_hRiflePistolT, buffer, sizeof(buffer));
    if (strlen(buffer) > 5) FormatEx(g_GunSelect[client].rifle_pistol_t, sizeof(GunSelect::rifle_pistol_t), buffer);
	
    GetClientCookie(client, g_hForceCT, buffer, sizeof(buffer));
    if (strlen(buffer) > 5) FormatEx(g_GunSelect[client].force_ct, sizeof(GunSelect::force_ct), buffer);
	
    GetClientCookie(client, g_hForceT, buffer, sizeof(buffer));
    if (strlen(buffer) > 5) FormatEx(g_GunSelect[client].force_t, sizeof(GunSelect::force_t), buffer);

    GetClientCookie(client, g_hAWP, buffer, sizeof(buffer));
    if (buffer[0] != '\0') g_GunSelect[client].awp = view_as<bool>(StringToInt(buffer));

    // GetClientCookie(client, g_hPistolCT, g_GunSelect[client].pistol_ct, sizeof(GunSelect::pistol_ct));
    // GetClientCookie(client, g_hPistolT, g_GunSelect[client].pistol_t, sizeof(GunSelect::pistol_t));
    // GetClientCookie(client, g_hForceCT, g_GunSelect[client].force_ct, sizeof(GunSelect::force_ct));
    // GetClientCookie(client, g_hForceT, g_GunSelect[client].force_t, sizeof(GunSelect::force_t));
    // GetClientCookie(client, g_hRifleCT, g_GunSelect[client].rifle_ct, sizeof(GunSelect::rifle_ct));
    // GetClientCookie(client, g_hRifleT, g_GunSelect[client].rifle_t, sizeof(GunSelect::rifle_t));
    // GetClientCookie(client, g_hRiflePistolCT, g_GunSelect[client].rifle_pistol_ct, sizeof(GunSelect::rifle_pistol_ct));
    // GetClientCookie(client, g_hRiflePistolT, g_GunSelect[client].rifle_pistol_t, sizeof(GunSelect::rifle_pistol_t));

    // char awp[4];
    // GetClientCookie(client, g_hAWP, awp, sizeof(awp));
    // g_GunSelect[client].awp = view_as<bool>(StringToInt(awp));
}

public void OnClientDisconnect(int client){
    if (IsFakeClient(client)) return;

    SetClientCookie(client, g_hPistolCT, g_GunSelect[client].pistol_ct);
    SetClientCookie(client, g_hPistolT, g_GunSelect[client].pistol_t);
    SetClientCookie(client, g_hForceCT, g_GunSelect[client].force_ct);
    SetClientCookie(client, g_hForceT, g_GunSelect[client].force_t);
    SetClientCookie(client, g_hRifleCT, g_GunSelect[client].rifle_ct);
    SetClientCookie(client, g_hRifleT, g_GunSelect[client].rifle_t);
    SetClientCookie(client, g_hRiflePistolCT, g_GunSelect[client].rifle_pistol_ct);
    SetClientCookie(client, g_hRiflePistolT, g_GunSelect[client].rifle_pistol_t);
    SetClientCookie(client, g_hAWP, g_GunSelect[client].awp ? "1":"0");
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast){
    for (int i = 0; i < MaxClients; i++){
        if (IsPlayer(i)) CancelClientMenu(i, true);
    }

    return Plugin_Continue;
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast){
    if (!Retakes_Live() || !g_cEnabled.BoolValue) return Plugin_Continue;

    switch (g_cMode.IntValue){
        case 0:{
            if (g_cPistolRound.BoolValue && g_iPistolRound < g_cPistolRoundNumber.IntValue){
                g_iPistolRound++;
                PistolRound();
            }
            else FullRound();
        }

        case 1:{
            int random = GetRandomInt(1, 100);
            if (random <= g_cPistolRoundRandom.IntValue) PistolRound();
            else FullRound();
        }
    }

    return Plugin_Continue;
}

public void Retakes_OnGunsCommand(int client){
    if (GetClientTeam(client) != CS_TEAM_CT && GetClientTeam(client) != CS_TEAM_T){
        Retakes_Message(client, "%t", "Invalid Team");
        return;
    }

    PistolMenu(client);
}

public Action Command_GeneralMenu(int client, int args){
    if (GetClientTeam(client) != CS_TEAM_CT && GetClientTeam(client) != CS_TEAM_T){
        Retakes_Message(client, "%t", "Invalid Team");
        return Plugin_Continue;
    }

    GeneralMenu(client);

    return Plugin_Continue;
}

public Action Command_PistolMenu(int client, int args){
    if (GetClientTeam(client) != CS_TEAM_CT && GetClientTeam(client) != CS_TEAM_T){
        Retakes_Message(client, "%t", "Invalid Team");
        return Plugin_Continue;
    }

    PistolMenu(client);

    return Plugin_Continue;
}

public Action Command_AWP(int client, int args){
    if (GetClientTeam(client) != CS_TEAM_CT && GetClientTeam(client) != CS_TEAM_T){
        Retakes_Message(client, "%t", "Invalid Team");
        return Plugin_Continue;
    }

    AWPMenu(client);

    return Plugin_Continue;
}