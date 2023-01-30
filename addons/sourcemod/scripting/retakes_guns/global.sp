enum struct GunSelect {
    char pistol_ct[32];
    char pistol_t[32];
    char force_ct[32];
    char force_t[32];
    char rifle_ct[32];
    char rifle_t[32];
    char rifle_pistol_ct[32];
    char rifle_pistol_t[32];
    bool awp;
}

enum RoundType {
    Round_PistolRound = 0,
    Round_ForceRound = 1,
    Round_FullRound = 2
}

enum GrenadeType {
    Weapon_HeGrenade = 0,
    Weapon_Flashbang = 1,
    Weapon_SmokeGrenade = 2,
    Weapon_Molotov = 3,
    Weapon_IncGrenade = 4
}

ConVar g_cEnabled,
g_cMode,
g_cPistolRound,
g_cPistolRoundNumber,
g_cPistolRoundRandom,
g_cForceRound,
g_cForceRoundRandom,
g_cUtilsMinimum,
g_cUtilsMaximum,
g_cAWP_CT,
g_cAWP_T,
// Utils
g_cSmokeCT,
g_cSmokeT,
g_cFlashCT,
g_cFlashT,
g_cFireCT,
g_cFireT,
g_cHeGrenadeCT,
g_cHeGrenadeT;

Handle g_hPistolCT,
g_hPistolT,
g_hForceCT,
g_hForceT,
g_hRifleCT,
g_hRifleT,
g_hRiflePistolCT,
g_hRiflePistolT,
g_hAWP;

int g_iPistolRound;

ArrayList g_WeaponGeneral,
g_WeaponCT,
g_WeaponT,
g_WeaponForceCT,
g_WeaponForceT,
g_WeaponForceGeneral;

GunSelect g_GunSelect[MAXPLAYERS + 1];