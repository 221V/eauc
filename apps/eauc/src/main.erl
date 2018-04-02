-module(main).
-compile([export_all, nowarn_export_all]).
-include_lib("nitro/include/nitro.hrl").
-include_lib("n2o/include/wf.hrl").

main() ->
  #dtl{file="main",app=eauc,bindings=[]}.


event(init) ->
  Time_Now2 = case pq:get_time_now() of
    [{Time_Now}] -> hm:timestamp2binary(Time_Now);
    _ -> hm:timestamp2binary(<<"">>)
  end,
  Nickname = wf:user(),
  %io:format("nick: ~p~n",[Nickname]),
  case Nickname of
    undefined ->
      
      Login_Form_HTML = hg:generate_login_form(),
      wf:wire(wf:f("qi('login_form').innerHTML='~s';login_form_bind();window.is_logged=false;"
                   "qi('login_form').style.display='block';"
                   "qi('time_now').innerHTML='~s';time_tick_tick();", [unicode:characters_to_binary(Login_Form_HTML,utf8), unicode:characters_to_binary(Time_Now2,utf8)]));
    _ ->
      %wf:redirect("/auction/")
      Uid = wf:session(uid),
      
      Account_Money = case pq:get_user_money_by_id(Uid) of
        [{User_Money}] ->
          [ <<"$ ">>, erlang:integer_to_binary(erlang:floor(User_Money/100)) ];
        _ ->
          User_Money = <<"">>,
          <<"$ database err">>
      end,
      
      Hello_User_HTML = hg:hello_user(Nickname, Uid),
      wf:wire(wf:f("qi('hello_user').innerHTML='~s';window.is_logged=true;"
                   "qi('hello_user').style.display='block';logout_bind();"
                   "qi('usermoney').innerHTML='~s';"
                   "qi('time_now').innerHTML='~s';time_tick_tick();", [unicode:characters_to_binary(Hello_User_HTML,utf8), unicode:characters_to_binary(Account_Money,utf8), unicode:characters_to_binary(Time_Now2,utf8)])),
      case wf:session(status) of
        2 ->
          Admin_Url_HTML = hg:hello_admin_url(),
          wf:wire(wf:f("add_url('~s');", [unicode:characters_to_binary(Admin_Url_HTML,utf8)]));
        _ -> ok
      end
  end,
  
  Finished_Lots_Data = pq:get_finished_lots(10, 0),
  Finished_Lots_HTML = hg:generate_finished_lots_main(Finished_Lots_Data, []),
  Reload_Finished_Btn_HTML = hg:generate_reload_finished_lots_main(),
  wf:wire(wf:f("qi('lots_history').innerHTML = auction_url_or_not() + '~s~s';"
               "reload_finished_bind();", [unicode:characters_to_binary(Reload_Finished_Btn_HTML,utf8), unicode:characters_to_binary(Finished_Lots_HTML,utf8)]));


event({client,{login, Login, Pass}}) when erlang:is_list(Login), erlang:is_list(Pass) ->
  Login2 = hm:trim_l(Login),
  Valid = ((Login =/= "") and hm:is_valid_email(Login2)) and (Pass =/= ""),
  
  case Valid of
    true ->
      
      case pq:get_user_login(Login2) of
        [{_, _, _, 0}] -> wf:wire("window.login_wait=false;alert('account banned !');");
        [{Uid, Nickname, Password, Status}] ->
          
          Pass2 = hm:trim_l(Pass),
          case Password =:= erlang:list_to_binary(hm:hash_pass(Pass2)) of
            true ->
              
              case Status of
                1 -> ok;
                2 -> wf:session(status, Status)
              end,
              wf:session(uid, Uid),
              wf:user(Nickname),
              %wf:redirect("/auction/");
              
              Account_Money = case pq:get_user_money_by_id(Uid) of
                [{User_Money}] ->
                  [ <<"$ ">>, erlang:integer_to_binary(erlang:floor(User_Money/100)) ];
                _ ->
                  User_Money = <<"">>,
                  <<"$ database err">>
              end,
              
              Hello_User_HTML = hg:hello_user(Nickname, Uid),
              Finished_Lots_Data = pq:get_finished_lots(10, 0),
              Finished_Lots_HTML = hg:generate_finished_lots_main(Finished_Lots_Data, []),
              Reload_Finished_Btn_HTML = hg:generate_reload_finished_lots_main(),
              
              wf:wire(wf:f("qi('login_form').style.display='none';qi('login').value='';qi('password').value='';"
                 "qi('hello_user').innerHTML='~s';qi('hello_user').style.display='block';"
                 "qi('usermoney').innerHTML='~s';logout_bind();"
                 "window.is_logged=true;qi('lots_history').innerHTML = auction_url_or_not() + '~s~s';"
                 "reload_finished_bind();", [unicode:characters_to_binary(Hello_User_HTML,utf8), unicode:characters_to_binary(Account_Money,utf8), unicode:characters_to_binary(Reload_Finished_Btn_HTML,utf8), unicode:characters_to_binary(Finished_Lots_HTML,utf8)])),
              
              case wf:session(status) of
                2 ->
                  Admin_Url_HTML = hg:hello_admin_url(),
                  wf:wire(wf:f("add_url('~s');", [unicode:characters_to_binary(Admin_Url_HTML,utf8)]));
                _ -> ok
              end;
            _ -> wf:wire("window.login_wait=false;alert('invalid login and/or password !');")
          end;
        [] -> wf:wire("window.login_wait=false;alert('invalid login and/or password !');");
        _ -> wf:wire("window.login_wait=false;alert('db error !');")
      end;
    _ ->
      wf:wire("window.login_wait=false;alert('invalid login and/or password !');")
  end;


event({client,{reload_finished}}) ->
  Finished_Lots_Data = pq:get_finished_lots(10, 0),
  Finished_Lots_HTML = hg:generate_finished_lots_main(Finished_Lots_Data, []),
  Reload_Finished_Btn_HTML = hg:generate_reload_finished_lots_main(),
  
  wf:wire(wf:f("qi('lots_history').innerHTML = auction_url_or_not() + '~s~s';"
    "reload_finished_bind();window.reload_wait=false;", [unicode:characters_to_binary(Reload_Finished_Btn_HTML,utf8), unicode:characters_to_binary(Finished_Lots_HTML,utf8)]));


event({client,{logout}}) ->
  wf:logout(),
  wf:redirect("/");


event(_) -> [].
