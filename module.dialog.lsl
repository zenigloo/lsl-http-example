//  DIALOG MODULE 
//  2019-2020 Zenigloo Cybernetics, Bastian <bastian@zenigloo.com>

integer IN = 87001;
integer RET = 87002;

integer from_handle;
integer to_handle;

// menu definitions
integer MENU_CHANNEL;
integer menu_listen_handle;
integer menuindex;

list order_buttons(list buttons) 
{
    return llList2List(buttons, -3, -1) + llList2List(buttons, -6, -4) +
        llList2List(buttons, -9, -7) + llList2List(buttons, -12, -10);
}
 
DialogPlus(key avatar, string message, list buttons, integer channel, integer CurMenu) 
{
    if (12 < llGetListLength(buttons)) {
        list lbut = buttons;
        list Nbuttons = [];
        if(CurMenu == -1) {
            CurMenu = 0;
            menuindex = 0;
        }
        
        if((Nbuttons = (llList2List(buttons, (CurMenu * 10), ((CurMenu * 10) + 9)) + ["Back", "Next"])) == ["Back", "Next"])
            DialogPlus(avatar, message, lbut, channel, menuindex = 0);
        else
            llDialog(avatar, message,  order_buttons(Nbuttons), channel);
    }
    else
        llDialog(avatar, message,  order_buttons(buttons), channel);
}
// end menu

// utility for sending linked message
call(integer num, string cmd, key attr,integer LINK) 
{
    llMessageLinked(LINK,num,cmd,attr);
}

parse_commands(string message) 
{
    string menu_type = llJsonGetValue(message, ["MENU"]);
    if (menu_type == "STANDARD") {
        key menu_avatar_key = llJsonGetValue(message, ["UUID"]);
        string menu_message = llJsonGetValue(message, ["MENU_MESSAGE"]);
        list menu_buttons = llParseString2List(llJsonGetValue(message, ["MENU_BUTTONS"]), ["|"], [""]);
        MENU_CHANNEL = (integer)((float)16777216 * llFrand(1.0));
        menu_listen_handle = llListen(MENU_CHANNEL, "", menu_avatar_key, "");
        DialogPlus((key) menu_avatar_key,menu_message, menu_buttons, MENU_CHANNEL, menuindex = 0);            
        return;
    }  
}

default 
{
    state_entry() 
    {
        //
    }

    link_message(integer sender_num, integer num, string message, key id) 
    {
        if (num == IN) 
        {
            parse_commands(message);
        }        
    }
    
    listen(integer channel, string name, key id, string message) 
    {
        if (channel == MENU_CHANNEL) 
        {
            llListenRemove(menu_listen_handle);
            call(RET,message,"",LINK_THIS);
        }
    }  
}

