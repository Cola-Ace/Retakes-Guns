stock void InitWeaponList(){
    g_WeaponGeneral.Clear();
    g_WeaponCT.Clear();
    g_WeaponT.Clear();

    char path[PLATFORM_MAX_PATH], classname[32];

    // General
    BuildPath(Path_SM, path, sizeof(path), "configs/retakes_guns/general.txt");
    File file = OpenFile(path, "r");
    if (file == null) SetFailState("Missing general weapon file: %s", path);

    while (!file.EndOfFile() && file.ReadLine(classname, sizeof(classname))){
        TrimString(classname);
        if (classname[0] != '\0') g_WeaponGeneral.PushString(classname);
    }
    file.Close();

    // CT
    BuildPath(Path_SM, path, sizeof(path), "configs/retakes_guns/ct.txt");
    file = OpenFile(path, "r");
    if (file == null) SetFailState("Missing ct weapon file: %s", path);

    while (!file.EndOfFile() && file.ReadLine(classname, sizeof(classname))){
        TrimString(classname);
        if (classname[0] != '\0') g_WeaponCT.PushString(classname);
    }
    file.Close();

    // T
    BuildPath(Path_SM, path, sizeof(path), "configs/retakes_guns/t.txt");
    file = OpenFile(path, "r");
    if (file == null) SetFailState("Missing t weapon file: %s", path);

    while (!file.EndOfFile() && file.ReadLine(classname, sizeof(classname))){
        TrimString(classname);
        if (classname[0] != '\0') g_WeaponT.PushString(classname);
    }
    file.Close();

    // Force General
    BuildPath(Path_SM, path, sizeof(path), "configs/retakes_guns/force_general.txt");
    file = OpenFile(path, "r");
    if (file == null) SetFailState("Missing force general weapon file: %s", path);

    while (!file.EndOfFile() && file.ReadLine(classname, sizeof(classname))){
        TrimString(classname);
        if (classname[0] != '\0') g_WeaponForceGeneral.PushString(classname);
    }
    file.Close();

    // Force CT
    BuildPath(Path_SM, path, sizeof(path), "configs/retakes_guns/force_ct.txt");
    file = OpenFile(path, "r");
    if (file == null) SetFailState("Missing force ct weapon file: %s", path);

    while (!file.EndOfFile() && file.ReadLine(classname, sizeof(classname))){
        TrimString(classname);
        if (classname[0] != '\0') g_WeaponForceCT.PushString(classname);
    }
    file.Close();

    // Force T
    BuildPath(Path_SM, path, sizeof(path), "configs/retakes_guns/force_t.txt");
    file = OpenFile(path, "r");
    if (file == null) SetFailState("Missing force t weapon file: %s", path);

    while (!file.EndOfFile() && file.ReadLine(classname, sizeof(classname))){
        TrimString(classname);
        if (classname[0] != '\0') g_WeaponForceT.PushString(classname);
    }
    file.Close();
}

stock void SetClientDefuser(int client, bool hasDefuser = true){
    if (!IsPlayer(client) || GetClientTeam(client) != CS_TEAM_CT) return;
    SetEntProp(client, Prop_Send, "m_bHasDefuser", hasDefuser ? 1:0);
}

stock void SetClientArmor(int client, int value, bool hasHelmet = true){
    if (!IsPlayer(client)) return;
    SetEntProp(client, Prop_Send, "m_ArmorValue", value);
    SetEntProp(client, Prop_Send, "m_bHasHelmet", hasHelmet ? 1:0);
}

stock void StripPlayerWeapons(int client)
{
	int weapon;
	for (int i = 0; i <= 3; i++) {
		if ((weapon = GetPlayerWeaponSlot(client, i)) != -1){
			RemovePlayerItem(client, weapon);
			AcceptEntityInput(weapon, "Kill");
		}
	}
}

stock void Retakes_MessageToTeam(int team, const char[] text, any:...){
    for (int i = 0; i < MaxClients; i++){
        if (IsPlayer(i) && GetClientTeam(i) == team) Retakes_Message(i, text);
    }
}

stock void PrintHintTextToTeam(int team, const char[] text, any:...){
    for (int i = 0; i < MaxClients; i++){
        if (IsPlayer(i) && GetClientTeam(i) == team) PrintHintText(i, text);
    }
}

stock bool IsValidClient(int client){
    return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client);
}

stock bool IsPlayer(int client){
    return IsValidClient(client) && !IsFakeClient(client);
}