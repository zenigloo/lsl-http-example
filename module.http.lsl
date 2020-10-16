//  HTTP MODULE 
//  2019-2020 Zenigloo Cybernetics, Bastian <bastian@zenigloo.com>

integer IN = 99100;
integer RET = 99101;
string url;
string request_for;
string params;
string method;
key qid;

integer DEBUG = 0;
debug (string m)
{
  if(DEBUG)
  {
    llOwnerSay("*** HTTP MODULE : \n" + m);
  }
}

// utility for sending linked message
call(integer num, string cmd, key attr,integer LINK) 
{
  llMessageLinked(LINK,num,cmd,attr);
}
key doServerCall( string url,  string method, list options ) 
{
  string opts = "/";
  integer i;
  string mimetype = "application/json";

  if (method == "POST")
  {
    if (llList2String(options,0) != "*")
      opts = llList2String(options,0);
    else
      opts = "";
  }
  else if (llList2String(options,0) != "*")
  {
    // api GET endpoints /{param}/{param..2} ...
    for( i=0; i<llGetListLength(options); i+=2 ) 
    {
      if( i )
        opts += "/";
        opts += llList2String( options, i ) +
              "/" +
              llEscapeURL( llList2String(options,i+1) );
    }       
  }
  if (method == "POST")
  {
    return llHTTPRequest(
      url,
      [
        HTTP_METHOD, method,
        HTTP_MIMETYPE, mimetype,
        HTTP_CUSTOM_HEADER, "Authorization", "xyz.123"
      ],
        opts
      );
  }
  return llHTTPRequest(
    url + opts,
    [
      HTTP_METHOD, method,
      HTTP_MIMETYPE, mimetype,
      HTTP_CUSTOM_HEADER, "Authorization", "xyz.123"
    ],
      ""
  );
}

default
{
  state_entry()
  {
    debug("\n HTTP MODULE INIT ..");
  }

  link_message(integer sender_num, integer num, string message, key id) 
  {
    if (num == IN) 
    {
      debug("message : \n " + message);
      list m =  llParseString2List(message, ["|"], [""]);
      url = llList2String(m,0);
      params = llList2String(m,1);
      request_for = llList2String(m,2);
      method = llList2String(m,3);
      DEBUG = (integer)llList2String(m,4);
      debug(" url : " + url + "\n params : " + params + "\n request for : " + request_for + "\n method : " + method);
      qid = doServerCall(url,method,[params]); 
    }        
  }
    http_response(key id, integer status, list metadata, string response) 
    {
      if (qid)
      {
        debug(" request for : " + request_for + "\n response : " + response);
        call(RET,response + "|" + request_for,"",LINK_THIS);
      }
    }
}