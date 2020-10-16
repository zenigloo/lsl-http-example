//  LSL HTTP CALL EXAMPLE 
//  2019-2020 Zenigloo Cybernetics, Bastian <bastian@zenigloo.com>
//
//  depedencies:
//  module.dialog.lsl
//  module.http.lsl
//

integer HTTP = 0;
integer MENU = 2;
list CHAN = [99100,99101,87001,87002];

string version = "0.1";
integer DEV = 1;
integer DEBUG = 1;
debug (string m)
{
  if(DEBUG)
  {
    llOwnerSay("\n" + m);
  }
}
string BASE_URL()
{
    if (DEV) return "https://jsonplaceholder.typicode.com/todos";
    return "https://jsonplaceholder.typicode.com/todos";
}

//GENERAL UTILITY
call(integer num, string cmd, key attr,integer LINK) 
{
  llMessageLinked(LINK,num,cmd,attr);
}
// DIALOG
string currentMenu;
menu_test(key UUID)
{
  currentMenu = "menu_test";
  string btns;
  btns = "USERS";
  btns +="| NOP";
  string msg =".\n** Demo : " + version + "\n";
  string json = llList2Json(JSON_OBJECT, 
    ["MENU", "STANDARD", 
     "UUID", UUID,"MENU_MESSAGE",msg,
     "MENU_BUTTONS",btns]);
  call((integer)llList2String(CHAN,MENU),json,"",LINK_THIS);
}

http(string url,string params,string request_for, string method, string dbg)
{
    string m = url + "|" + params + "|" + request_for + "|" + method + "|dbg";
    call((integer)llList2String(CHAN,HTTP),m,"",LINK_THIS);
}

default
{
    state_entry()
    {
        debug("\n** client init \n** development : " + (string)DEV + "\n** base url : " + BASE_URL());
    }

    touch_start(integer total_number)
    {
        debug("** click ");
        menu_test(llGetOwner());
    }

    link_message(integer sender_num, integer num, string message, key id)
    {
        if (num == (integer)llList2String(CHAN,HTTP+1))
        {
            list m =  llParseString2List(message, ["|"], [""]);
            string request_for = llList2String(m,1);
            string response = llList2String(m,0);
            if (request_for == "test-call")
            {
                debug ("** response for test-call \n " + response); 
                return;
            }
            debug("HTTP RET : \n" + message);
        }
        if (num == (integer)llList2String(CHAN,MENU+1))
        {
            llOwnerSay("MENU RET : \n" + message);
            if (message == "USERS")
            {
                http(
                    BASE_URL(),
                    "1","test-call","GET",(string)DEBUG
                );
            }
        }        
    }
}
