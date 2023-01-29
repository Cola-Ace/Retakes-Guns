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
    char output[512], type[32], bombsite[32];
    FormatEx(bombsite, sizeof(bombsite), "%t", Retakes_GetCurrrentBombsite() == BombsiteA ? "Bombsite A":"Bombsite B");

    if (g_cForceRound.BoolValue && GetRandomInt(1, 100) <= g_cForceRoundRandom.IntValue){ // force
        int team = GetRandomInt(2, 3); // force team
        ArrayList players = new ArrayList();

        // for force team
        FormatEx(type, sizeof(type), "%t", "Force Round");
        FormatEx(output, sizeof(output), "%t", "Hint Now Round", type, bombsite);

        Retakes_MessageToTeam(team, "%t", "Now Round", type);

        PrintHintTextToTeam(team, output);

        // for full team
        FormatEx(type, sizeof(type), "%t", "Full Round");
        FormatEx(output, sizeof(output), "%t", "Hint Now Round", type, bombsite);
        PrintHintTextToTeam(team == CS_TEAM_CT ? CS_TEAM_T:CS_TEAM_CT, output);
        Retakes_MessageToTeam(team == CS_TEAM_CT ? CS_TEAM_T:CS_TEAM_CT, "%t", "Now Round", type);

        for (int i = 0; i < MaxClients; i++){
            if (!IsPlayer(i)) continue;

            if (GetClientTeam(i) == team) GivePlayerWeapon(i, Round_ForceRound);
            else if (GetClientTeam(i) == (team == CS_TEAM_CT ? CS_TEAM_T:CS_TEAM_CT)){
                if (g_GunSelect[i].awp) players.Push(i);
                GivePlayerWeapon(i, Round_FullRound);
            }
        }

        // awp
        for (int i = 0; i < (team == CS_TEAM_CT ? g_cAWP_T.IntValue:g_cAWP_CT.IntValue); i++){
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
    FormatEx(output, sizeof(output), "%t", "Hint Now Round", type, bombsite);
    Retakes_MessageToAll("%t", "Now Round");
    PrintHintTextToAll(output);

    ArrayList ct_awp = new ArrayList();
    ArrayList t_awp = new ArrayList();
    for (int i = 0; i < MaxClients; i++){
        if (!IsPlayer(i)) continue;

        GivePlayerWeapon(i, Round_FullRound);
        if (g_GunSelect[i].awp){
            if (GetClientTeam(i) == CS_TEAM_CT) ct_awp.Push(i);
            else if (GetClientTeam(i) == CS_TEAM_T) t_awp.Push(i);
        }
    }

    // awp
    for (int i = 0; i < g_cAWP_CT.IntValue; i++){
        int index = GetRandomInt(0, ct_awp.Length - 1);
        int client = ct_awp.Get(index);

        int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
        RemovePlayerItem(client, weapon);
        AcceptEntityInput(weapon, "Kill");

        GivePlayerItem(client, "weapon_awp");
        ct_awp.Erase(index);
    }

    for (int i = 0; i < g_cAWP_T.IntValue; i++){
        int index = GetRandomInt(0, t_awp.Length - 1);
        int client = t_awp.Get(index);

        int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
        RemovePlayerItem(client, weapon);
        AcceptEntityInput(weapon, "Kill");

        GivePlayerItem(client, "weapon_awp");
        t_awp.Erase(index);
    }
}