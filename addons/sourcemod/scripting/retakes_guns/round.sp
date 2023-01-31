stock void PistolRound(){
    char output[512], type[32], bombsite[32];
    FormatEx(type, sizeof(type), "%t", "Pistol Round");

    Retakes_MessageToAll("%t", "Now Round", type);

    FormatEx(bombsite, sizeof(bombsite), "%t", Retakes_GetCurrrentBombsite() == BombsiteA ? "Bombsite A":"Bombsite B");
    FormatEx(output, sizeof(output), "%t", "Hint Now Round", type, bombsite);
    PrintHintTextToAll(output);

    for (int i = 0; i < MaxClients; i++){
        if (IsPlayer(i) && (GetClientTeam(i) == CS_TEAM_CT || GetClientTeam(i) == CS_TEAM_T)) GivePlayerWeapon(i, Round_PistolRound);
    }
}

stock void FullRound(){
    ArrayList ct_grenade = new ArrayList();
    ArrayList t_grenade = new ArrayList();

    for (int i = 0; i < g_cSmokeCT.IntValue; i++) ct_grenade.Push(Weapon_SmokeGrenade);
    for (int i = 0; i < g_cSmokeT.IntValue; i++) t_grenade.Push(Weapon_SmokeGrenade);
    for (int i = 0; i < g_cFlashCT.IntValue; i++) ct_grenade.Push(Weapon_Flashbang);
    for (int i = 0; i < g_cFlashT.IntValue; i++) t_grenade.Push(Weapon_Flashbang);
    for (int i = 0; i < g_cFireCT.IntValue; i++) ct_grenade.Push(Weapon_IncGrenade);
    for (int i = 0; i < g_cFireT.IntValue; i++) t_grenade.Push(Weapon_Molotov);
    for (int i = 0; i < g_cHeGrenadeCT.IntValue; i++) ct_grenade.Push(Weapon_HeGrenade);
    for (int i = 0; i < g_cHeGrenadeT.IntValue; i++) t_grenade.Push(Weapon_HeGrenade);

    char output[512], type[32], bombsite[32];
    FormatEx(bombsite, sizeof(bombsite), "%t", Retakes_GetCurrrentBombsite() == BombsiteA ? "Bombsite A":"Bombsite B");

    if (g_cForceRound.BoolValue && GetRandomInt(1, 100) <= g_cForceRoundRandom.IntValue){ // force
        int team = GetRandomInt(2, 3); // force team
        ArrayList players = new ArrayList();

        // for force team
        FormatEx(type, sizeof(type), "%t", "Force Round");

        FormatEx(output, sizeof(output), "%t", "Now Round", type);
        Retakes_MessageToTeam(team, output);

        FormatEx(output, sizeof(output), "%t", "Hint Now Round", type, bombsite);
        PrintHintTextToTeam(team, output);

        // for full team
        FormatEx(type, sizeof(type), "%t", "Full Round");
        FormatEx(output, sizeof(output), "%t", "Hint Now Round", type, bombsite);
        PrintHintTextToTeam(team == CS_TEAM_CT ? CS_TEAM_T:CS_TEAM_CT, output);
        
        FormatEx(output, sizeof(output), "%t", "Now Round", type);
        Retakes_MessageToTeam(team == CS_TEAM_CT ? CS_TEAM_T:CS_TEAM_CT, output);

        for (int i = 0; i < MaxClients; i++){
            if (!IsPlayer(i)) continue;

            if (GetClientTeam(i) == team) GivePlayerWeapon(i, Round_ForceRound);
            else if (GetClientTeam(i) == (team == CS_TEAM_CT ? CS_TEAM_T:CS_TEAM_CT)){
                if (g_GunSelect[i].awp) players.Push(i);
                GivePlayerWeapon(i, Round_FullRound, ct_grenade, t_grenade);
            }
        }

        // awp
        for (int i = 0; i < (team == CS_TEAM_CT ? g_cAWP_T.IntValue:g_cAWP_CT.IntValue); i++){
            if (players.Length == 0) break;

            int index = GetRandomInt(0, players.Length - 1);
            int client = players.Get(index);

            int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
            RemovePlayerItem(client, weapon);
            AcceptEntityInput(weapon, "Kill");

            GivePlayerItem(client, "weapon_awp");
            players.Erase(index);
        }

        return;
    }

    FormatEx(type, sizeof(type), "%t", "Full Round");
    Retakes_MessageToAll("%t", "Now Round", type);

    FormatEx(output, sizeof(output), "%t", "Hint Now Round", type, bombsite);
    PrintHintTextToAll(output);

    ArrayList ct_awp = new ArrayList();
    ArrayList t_awp = new ArrayList();
    for (int i = 0; i < MaxClients; i++){
        if (!IsPlayer(i)) continue;

        GivePlayerWeapon(i, Round_FullRound, ct_grenade, t_grenade);
        if (g_GunSelect[i].awp){
            if (GetClientTeam(i) == CS_TEAM_CT) ct_awp.Push(i);
            else if (GetClientTeam(i) == CS_TEAM_T) t_awp.Push(i);
        }
    }

    // awp
    for (int i = 0; i < g_cAWP_CT.IntValue; i++){
        if (ct_awp.Length == 0) break;

        int index = GetRandomInt(0, ct_awp.Length - 1);
        int client = ct_awp.Get(index);

        int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
        RemovePlayerItem(client, weapon);
        AcceptEntityInput(weapon, "Kill");

        GivePlayerItem(client, "weapon_awp");
        ct_awp.Erase(index);
    }

    for (int i = 0; i < g_cAWP_T.IntValue; i++){
        if (t_awp.Length == 0) break;

        int index = GetRandomInt(0, t_awp.Length - 1);
        int client = t_awp.Get(index);

        int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
        RemovePlayerItem(client, weapon);
        AcceptEntityInput(weapon, "Kill");

        GivePlayerItem(client, "weapon_awp");
        t_awp.Erase(index);
    }
}