stock void GivePlayerWeapon(int client, RoundType type, ArrayList ct_grenade = view_as<ArrayList>(INVALID_HANDLE), ArrayList t_grenade = view_as<ArrayList>(INVALID_HANDLE)){
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

            if (team == CS_TEAM_CT){
                SetClientDefuser(client);

                GivePlayerItem(client, g_GunSelect[client].rifle_pistol_ct);
                GivePlayerItem(client, g_GunSelect[client].rifle_ct);
            } else {
                GivePlayerItem(client, g_GunSelect[client].rifle_pistol_t);
                GivePlayerItem(client, g_GunSelect[client].rifle_t);
            }

            ArrayList grenades = new ArrayList();
            for (int i = 0; i < GetRandomInt(g_cUtilsMinimum.IntValue, g_cUtilsMaximum.IntValue); i++){
                int index, util;
                
                if (team == CS_TEAM_CT){
                    if (ct_grenade.Length == 0) break; // no util

                    index = GetRandomInt(0, ct_grenade.Length - 1);
                    util = ct_grenade.Get(index);
                } else {
                    if (t_grenade.Length == 0) break; // no util

                    index = GetRandomInt(0, t_grenade.Length - 1);
                    util = t_grenade.Get(index);
                }

                if (util != 1 && grenades.FindValue(util) != -1) continue;
                grenades.Push(util);
                if (team == CS_TEAM_CT) ct_grenade.Erase(index);
                else t_grenade.Erase(index);
            }

            for (int i = 0; i < grenades.Length; i++){
                int util = grenades.Get(i);

                switch (util){
                    case 0:GivePlayerItem(client, "weapon_hegrenade");
                    case 1:GivePlayerItem(client, "weapon_flashbang");
                    case 2:GivePlayerItem(client, "weapon_smokegrenade");
                    case 3:GivePlayerItem(client, "weapon_molotov");
                    case 4:GivePlayerItem(client, "weapon_incgrenade");
                }
            }
        }
    }
}