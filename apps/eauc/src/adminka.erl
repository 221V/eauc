-module(adminka).
-compile([export_all, nowarn_export_all]).
-include_lib("nitro/include/nitro.hrl").
-include_lib("n2o/include/wf.hrl").

main() -> #dtl{file="null",app=eauc,bindings=[]}.


event(init) ->
  case wf:user() of
    undefined ->
      wf:redirect("/");
    _ ->
      
      wf:wire("document.head.innerHTML = document.head.innerHTML + '<link rel=\"shortcut icon\" href=\"/img/favicon.ico\" type=\"image/x-icon\">';"
        "document.title='EAUC | Admin Panel';"
        "var load_css1=document.createElement('link');load_css1.setAttribute('rel', 'stylesheet');load_css1.setAttribute('type', 'text/css');load_css1.setAttribute('href', '/css/eauc.css');document.body.appendChild(load_css1);"
        "var load_js1=document.createElement('script');load_js1.setAttribute('defer','defer');load_js1.setAttribute('src', '/js/adminka.js');document.body.appendChild(load_js1);"),
      Adminka_HTML = wf:render(#dtl{file="adminka",app=eauc,bindings=[]}),
      wf:wire(wf:f("var newDiv = document.createElement('div');newDiv.className = 'row cont';"
        "newDiv.innerHTML = '~s';document.body.appendChild(newDiv);", [wf:jse(Adminka_HTML)])),
      
      Time_Now2 = case pq:get_time_now() of
        [{Time_Now}] -> hm:timestamp2binary(Time_Now);
        _ -> Time_Now = {{2000,1,2},{3,4,0}}, hm:timestamp2binary(Time_Now)
      end,
      wf:wire(wf:f("setTimeout(function(){ bind_admin_menu();bind_auc_time_change();bind_add_lot_btn();bind_edit_lot_load_btn();bind_edit_active_lot_btn();qi('time_now').innerHTML='~s';set_time_now('~s');page_timer_tick(); }, 2000);", [unicode:characters_to_binary(Time_Now2,utf8), unicode:characters_to_binary(Time_Now2,utf8)]))
  end;


event({client,{add_lot, Name, Count, Start_Bet, Bet_Step, Lot_Prise, Start_Time, Time_Length}}) ->
  Nickname = wf:user(),
  case Nickname of
    undefined ->
      err;
    _ ->
      %% ok, logged
      
      case wf:session(status) of
        2 ->
          %% ok, admin
          
          Count2 = erlang:list_to_integer(Count),
          Start_Bet2 = erlang:list_to_integer(Start_Bet),
          Bet_Step2 = erlang:list_to_integer(Bet_Step),
          
          Valid_Start_Time = erlang:is_binary(Start_Time) and hm:valid_start_time(Start_Time),
          Valid_Time_Length = erlang:is_list(Time_Length) and hm:valid_time_length(Time_Length),
          
          Valid = ( (erlang:is_list(Name) and (Name =/= "")) and ((Count2 > 0) and (Start_Bet2 > 0)) ) and ( ((Bet_Step2 > 0) and erlang:is_list(Lot_Prise)) and ((Lot_Prise =/= "") and (Valid_Start_Time and Valid_Time_Length)) ),
          
          case Valid of
            true ->
              
              %%[{{End_Year,End_Month,End_Day},{End_Hour,End_Minit,End_Sec}}, {{Start_Year,Start_Month,Start_Day},{Start_Hour,Start_Minit,Start_Sec}}, Length_Sec |_] = hm:start_time_and_interval2end_date(Start_Time, Time_Length),
              [End_Timestamp, Start_Timestamp, Length_Sec |_] = hm:start_time_and_interval2end_date(Start_Time, Time_Length),
              Name2 = hm:htmlspecialchars(hm:trim_l(Name)),
              Lot_Prise2 = hm:htmlspecialchars(hm:trim_l(Lot_Prise)),
              
              case pq:add_new_lot(Name2, Count2, Start_Bet2, Bet_Step2, Lot_Prise2, Length_Sec, Start_Timestamp, End_Timestamp) of
                1 -> wf:wire("window.new_lot_wait = false;alert('new lot add success!!');");
                _ -> wf:wire("window.new_lot_wait = false;alert('database err!');")
              end;
            _ ->
              %% err, invalid data
              wf:wire("window.new_lot_wait = false;alert('invalid data !');")
          end;
        _ ->
          %% not admin
          err
      end
  end;


event(_) -> [].
