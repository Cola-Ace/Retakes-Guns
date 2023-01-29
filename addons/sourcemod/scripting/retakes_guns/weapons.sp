stock void GivePlayerWeapon(int client, RoundType type){
    int team = GetClientTeam(client);

    StripPlayerWeapons(client);

    if (team == CS_TEAM_CT) GivePlayerItem(client, "weapon_knife");
	else GivePlayerItem(client, "weapon_knife_t");

    switch (type){
        case Round_PistolRound:{
            if (team == CS_TEAM_CT){
                if (StrEqual(g_GunSelect[client].pistol_ct, "weapon_usp_silencer") || StrEqual(g_GunSelect[client].pistol_ct, "weapon_hkp2000")) SetClientArmor(client, 100, false);
                else SetClientArmor(client, 0, false);

                SetClientDefuser(client, false);

                GivePlayerItem(client, g_GunSelect[client].pistol_ct);
            } else {
                if (StrEqual(g_GunSelect[client].pistol_t, "weapon_glock")) SetClientArmor(client, 100, false);
                else SetClientArmor(client, 0, false);

                GivePlayerItem(client, g_GunSelect[client].pistol_t);
            }
        }

        case Round_ForceRound:{
            SetClientArmor(client, 100, false);
            if (team == CS_TEAM_CT){
                SetClientDefuser(client, false);

                GivePlayerItem(client, g_GunSelect[client].force_ct);
                GivePlayerItem(client, "weapon_usp_silencer");
            } else {
                GivePlayerItem(client, g_GunSelect[client].force_t);
                GivePlayerItem(client, "weapon_glock");
            }
        }

        case Round_FullRound:{
            SetClientArmor(client, 100);

            ArrayList grenades = new ArrayList();
            grenades.Push(Weapon_HeGrenade);
            grenades.Push(Weapon_Flashbang);
            grenades.Push(Weapon_SmokeGrenade);

            if (team == CS_TEAM_CT){
                SetClientDefuser(client);

                GivePlayerItem(client, g_GunSelect[client].rifle_pistol_ct);
                GivePlayerItem(client, g_GunSelect[client].rifle_ct);

                grenades.Push(Weapon_IncGrenade);
            } else {
                GivePlayerItem(client, g_GunSelect[client].rifle_pistol_t);
                GivePlayerItem(client, g_GunSelect[client].rifle_t);

                grenades.Push(Weapon_Molotov);
            }

            for (int i = 0; i < GetRandomInt(g_cUtilsMinimum.IntValue, g_cUtilsMaximum.IntValue); i++){
                int index = GetRandomInt(0, grenades.Length - 1);
                int util = grenades.Get(index);

                switch (util){
                    case 0:GivePlayerItem(client, "weapon_hegrenade");
                    case 1:GivePlayerItem(client, "weapon_flashbang");
                    case 2:GivePlayerItem(client, "weapon_smokegrenade");
                    case 3:GivePlayerItem(client, "weapon_molotov");
                    case 4:GivePlayerItem(client, "weapon_incgrenade");
                }

                grenades.Erase(index);
            }
        }
    }
}