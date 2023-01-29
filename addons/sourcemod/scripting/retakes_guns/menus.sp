// General
public int Handler_GeneralMenu(Menu menu, MenuAction action, int client, int select){
    switch (action){
        case MenuAction_Select:{
            char index[8];
            menu.GetItem(select, index, sizeof(index));

            switch (StringToInt(index)){
                case 0:RifleMenu(client);
                case 1:PistolMenu(client);
                case 2:PistolMenu(client, true);
                case 3:ForceMenu(client);
                case 4:AWPMenu(client);
            }
        }

        case MenuAction_End:{
            delete menu;
        }
    }

    return 0;
}

stock void GeneralMenu(int client){
    Menu menu = new Menu(Handler_GeneralMenu);
    menu.SetTitle("%t", "General Menu Title");

    char output[256], display[256], yes[32], no[32];
    FormatEx(yes, sizeof(yes), "%t", "Yes");
    FormatEx(no, sizeof(no), "%t", "No");

    if (GetClientTeam(client) == CS_TEAM_CT){
        eItems_GetWeaponDisplayNameByClassName(g_GunSelect[client].rifle_ct, display, sizeof(display));
        FormatEx(output, sizeof(output), "%t", "General Menu Rifle", display);
        menu.AddItem("0", output);

        eItems_GetWeaponDisplayNameByClassName(g_GunSelect[client].pistol_ct, display, sizeof(display));
        FormatEx(output, sizeof(output), "%t", "General Menu Pistol", display);
        menu.AddItem("1", output);

        eItems_GetWeaponDisplayNameByClassName(g_GunSelect[client].rifle_pistol_ct, display, sizeof(display));
        FormatEx(output, sizeof(output), "%t", "General Menu Full Pistol", display);
        menu.AddItem("2", output);

        eItems_GetWeaponDisplayNameByClassName(g_GunSelect[client].force_ct, display, sizeof(display));
        FormatEx(output, sizeof(output), "%t", "General Menu Force", display);
        menu.AddItem("3", output);

        FormatEx(output, sizeof(output), "%t", "General Menu AWP", g_GunSelect[client].awp ? yes:no);
        menu.AddItem("4", output);
    } else {
        eItems_GetWeaponDisplayNameByClassName(g_GunSelect[client].rifle_t, display, sizeof(display));
        FormatEx(output, sizeof(output), "%t", "General Menu Rifle", display);
        menu.AddItem("0", output);

        eItems_GetWeaponDisplayNameByClassName(g_GunSelect[client].pistol_t, display, sizeof(display));
        FormatEx(output, sizeof(output), "%t", "General Menu Pistol", display);
        menu.AddItem("1", output);

        eItems_GetWeaponDisplayNameByClassName(g_GunSelect[client].rifle_pistol_t, display, sizeof(display));
        FormatEx(output, sizeof(output), "%t", "General Menu Full Pistol", display);
        menu.AddItem("2", output);

        eItems_GetWeaponDisplayNameByClassName(g_GunSelect[client].force_t, display, sizeof(display));
        FormatEx(output, sizeof(output), "%t", "General Menu Force", display);
        menu.AddItem("3", output);

        FormatEx(output, sizeof(output), "%t", "General Menu AWP", g_GunSelect[client].awp ? yes:no);
        menu.AddItem("4", output);
    }

    menu.ExitButton = true;
    menu.ExitBackButton = false;
    menu.Display(client, MENU_TIME_FOREVER);
}

// Pistol
public int Handler_FullPistolMenu(Menu menu, MenuAction action, int client, int select){
    switch (action){
        case MenuAction_Select:{
            int team = GetClientTeam(client);

            if (team == CS_TEAM_CT) menu.GetItem(select, g_GunSelect[client].rifle_pistol_ct, sizeof(GunSelect::rifle_pistol_ct));
            else menu.GetItem(select, g_GunSelect[client].rifle_pistol_t, sizeof(GunSelect::rifle_pistol_t));

            ForceMenu(client);
        }

        case MenuAction_End:{
            delete menu;
        }
    }

    return 0;
}

public int Handler_PistolMenu(Menu menu, MenuAction action, int client, int select){
    switch (action){
        case MenuAction_Select:{
            int team = GetClientTeam(client);

            if (team == CS_TEAM_CT) menu.GetItem(select, g_GunSelect[client].pistol_ct, sizeof(GunSelect::pistol_ct));
            else menu.GetItem(select, g_GunSelect[client].pistol_t, sizeof(GunSelect::pistol_t));
            
            PistolMenu(client, true);
        }

        case MenuAction_End:{
            delete menu;
        }
    }

    return 0;
}

stock void PistolMenu(int client, bool full = false){
    Menu menu = new Menu(full ? Handler_FullPistolMenu:Handler_PistolMenu);

    int team = GetClientTeam(client);

    char display[64], classname[32];
    eItems_GetWeaponDisplayNameByClassName(team == CS_TEAM_CT ? (full ? g_GunSelect[client].rifle_pistol_ct:g_GunSelect[client].pistol_ct):(full ? g_GunSelect[client].rifle_pistol_t:g_GunSelect[client].pistol_t), display, sizeof(display));

    menu.SetTitle("%t", full ? "Full Pistol Menu Title":"Pistol Menu Title", display)

    if (team == CS_TEAM_CT){
        for (int i = 0; i < g_WeaponCT.Length; i++){
            g_WeaponCT.GetString(i, classname, sizeof(classname));
            if (eItems_GetWeaponSlotByClassName(classname) != CS_SLOT_SECONDARY) continue;
            eItems_GetWeaponDisplayNameByClassName(classname, display, sizeof(display));
            menu.AddItem(classname, display);
        }
    } else {
        for (int i = 0; i < g_WeaponT.Length; i++){
            g_WeaponT.GetString(i, classname, sizeof(classname));
            if (eItems_GetWeaponSlotByClassName(classname) != CS_SLOT_SECONDARY) continue;
            eItems_GetWeaponDisplayNameByClassName(classname, display, sizeof(display));
            menu.AddItem(classname, display);
        }
    }

    for (int i = 0; i < g_WeaponGeneral.Length; i++){
        g_WeaponGeneral.GetString(i, classname, sizeof(classname));
        if (eItems_GetWeaponSlotByClassName(classname) != CS_SLOT_SECONDARY) continue;
        eItems_GetWeaponDisplayNameByClassName(classname, display, sizeof(display));
        menu.AddItem(classname, display);
    }

    menu.ExitButton = true;
    menu.ExitBackButton = false;
    menu.Display(client, MENU_TIME_FOREVER);
}

// Force
public int Handler_ForceMenu(Menu menu, MenuAction action, int client, int select){
    switch (action){
        case MenuAction_Select:{
            int team = GetClientTeam(client);

            if (team == CS_TEAM_CT) menu.GetItem(select, g_GunSelect[client].force_ct, sizeof(GunSelect::force_ct));
            else menu.GetItem(select, g_GunSelect[client].force_t, sizeof(GunSelect::force_t));
            
            RifleMenu(client);
        }

        case MenuAction_End:{
            delete menu;
        }
    }

    return 0;
}

stock void ForceMenu(int client){
    Menu menu = new Menu(Handler_ForceMenu);

    char display[64], classname[32];
    int team = GetClientTeam(client);
    eItems_GetWeaponDisplayNameByClassName(team == CS_TEAM_CT ? g_GunSelect[client].force_ct:g_GunSelect[client].force_t, display, sizeof(display));
    menu.SetTitle("%t", "Force Menu Title", display);

    if (team == CS_TEAM_CT){
        for (int i = 0; i < g_WeaponForceCT.Length; i++){
            g_WeaponForceCT.GetString(i, classname, sizeof(classname));
            eItems_GetWeaponDisplayNameByClassName(classname, display, sizeof(display));
            menu.AddItem(classname, display);
        }
    } else {
        for (int i = 0; i < g_WeaponForceT.Length; i++){
            g_WeaponForceT.GetString(i, classname, sizeof(classname));
            eItems_GetWeaponDisplayNameByClassName(classname, display, sizeof(display));
            menu.AddItem(classname, display);
        }
    }

    for (int i = 0; i < g_WeaponForceGeneral.Length; i++){
        g_WeaponForceGeneral.GetString(i, classname, sizeof(classname));
        eItems_GetWeaponDisplayNameByClassName(classname, display, sizeof(display));
        menu.AddItem(classname, display);
    }

    menu.ExitButton = true;
    menu.ExitBackButton = false;
    menu.Display(client, MENU_TIME_FOREVER);
}

// Rifle
public int Handler_RifleMenu(Menu menu, MenuAction action, int client, int select){
    switch (action){
        case MenuAction_Select:{
            int team = GetClientTeam(client);

            if (team == CS_TEAM_CT) menu.GetItem(select, g_GunSelect[client].rifle_ct, sizeof(GunSelect::rifle_ct));
            else menu.GetItem(select, g_GunSelect[client].rifle_t, sizeof(GunSelect::rifle_t));

            AWPMenu(client);
        }

        case MenuAction_End:{
            delete menu;
        }
    }

    return 0;
}

stock void RifleMenu(int client){
    Menu menu = new Menu(Handler_RifleMenu);

    int team = GetClientTeam(client);

    char display[64], classname[32];
    eItems_GetWeaponDisplayNameByClassName(team == CS_TEAM_CT ? g_GunSelect[client].rifle_ct:g_GunSelect[client].rifle_t, display, sizeof(display));

    menu.SetTitle("%t", "Rifle Menu Title", display)

    if (team == CS_TEAM_CT){
        for (int i = 0; i < g_WeaponCT.Length; i++){
            g_WeaponCT.GetString(i, classname, sizeof(classname));
            if (eItems_GetWeaponSlotByClassName(classname) != CS_SLOT_PRIMARY) continue;
            eItems_GetWeaponDisplayNameByClassName(classname, display, sizeof(display));
            menu.AddItem(classname, display);
        }
    } else {
        for (int i = 0; i < g_WeaponT.Length; i++){
            g_WeaponT.GetString(i, classname, sizeof(classname));
            if (eItems_GetWeaponSlotByClassName(classname) != CS_SLOT_PRIMARY) continue;
            eItems_GetWeaponDisplayNameByClassName(classname, display, sizeof(display));
            menu.AddItem(classname, display);
        }
    }

    for (int i = 0; i < g_WeaponGeneral.Length; i++){
        g_WeaponGeneral.GetString(i, classname, sizeof(classname));
        if (eItems_GetWeaponSlotByClassName(classname) != CS_SLOT_PRIMARY) continue;
        eItems_GetWeaponDisplayNameByClassName(classname, display, sizeof(display));
        menu.AddItem(classname, display);
    }

    menu.ExitButton = true;
    menu.ExitBackButton = false;
    menu.Display(client, MENU_TIME_FOREVER);
}

// Awp
public int Handler_AWPMenu(Menu menu, MenuAction action, int client, int select){
    switch (action){
        case MenuAction_Select:{
            char item[16];
            menu.GetItem(select, item, sizeof(item));
            g_GunSelect[client].awp = view_as<bool>(StringToInt(item));

            Retakes_Message(client, "%t", "Appear Next Round");
        }

        case MenuAction_End:{
            delete menu;
        }
    }

    return 0;
}

stock void AWPMenu(int client){
    Menu menu = new Menu(Handler_AWPMenu);

    char yes[32], no[32];
    FormatEx(yes, sizeof(yes), "%t", "Yes");
    FormatEx(no, sizeof(no), "%t", "No");

    menu.SetTitle("%t", "Use AWP", g_GunSelect[client].awp ? yes:no);
    menu.AddItem("1", yes);
    menu.AddItem("0", no);

    menu.ExitButton = true;
    menu.ExitBackButton = false;
    menu.Display(client, MENU_TIME_FOREVER);
}