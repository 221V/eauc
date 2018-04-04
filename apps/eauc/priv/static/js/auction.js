
var timers = [];
var lots_bets_count = [];
var user_money = 0;

function true_time(v){
  if(v < 10){return '0' + v;}
  return v;
}

function page_timer_tick(){
  var re = /^[0-9]{4}\/[0-9]{2}\/[0-9]{2}\s[0-9]{2}:[0-9]{2}:[0-9]{2}$/i;
  var v0 = qi('time_now').innerHTML;
  if(re.test(v0)){
    var v1 = v0.split(' ');
    var v2 = v1[1].split(':');
    var date0 = v1[0].split('/');
    var sec = Number(v2[2]);
    var min = Number(v2[1]);
    var hour = Number(v2[0]);
    var day = Number(date0[2]);
    timers[0] = setTimeout(function tick(){
      sec++;
      if(sec == 60){sec = 0;min++;}
      if(min == 60){min = 0;hour++;}
      if(hour == 24){hour = 0;day++;}
      qi('time_now').innerHTML = date0[0] + '/' + date0[1] + '/' + true_time(day) + ' ' + true_time(hour) + ':' + true_time(min) + ':' + true_time(sec);
      timers[0] = setTimeout(tick, 999);
    }, 100);
  }
}

function page_timers_back(){
  var re = /^[0-9]{2,5}:[0-9]{2}:[0-9]{2}$/i;
  var els = document.querySelectorAll('.a_lots');
  els.forEach(function(el){
  
  var id = Number(el.dataset.id);
  var el2 = el.firstElementChild;
  var v0 = el2.innerHTML;
  if(re.test(v0)){
    var v1 = v0.split(':');
    var sec = Number(v1[2]);
    var min = Number(v1[1]);
    var hour = Number(v1[0]);
    
    timers[id] = setTimeout(function tick(){
      sec--;
      if(sec < 0){sec = 60;min--;}
      if(min < 0){min = 60;hour--;}
      if(hour < 0){hour = 0;}
      el2.innerHTML = true_time(hour) + ':' + true_time(min) + ':' + true_time(sec);
      timers[id] = setTimeout(tick, 999);
    }, 100);
  }
  });
}

function stop_timer(id){
  clearTimeout(timers[id]);
}

function go_logout(){
  if(window.logout_wait !== true){
    var timerId = setTimeout(function tick(){
      if(window.active){
        window.logout_wait = true;
        ws.send(enc(tuple( atom('client'), tuple(atom('logout')) )));
      }else{
        timerId = setTimeout(tick, 200);
      }
    }, 100);
  }
}

function logout_bind(){
  qi('logout').addEventListener("click", go_logout, false);
}

function add_url(html){
  var parent = qi('hello_user');
  var newp = document.createElement('p');
  newp.innerHTML = html;
  parent.insertBefore(newp, parent.children[1]);
}

function do_reload_active(){
  if(window.reload_wait !== true){
    var timerId = setTimeout(function tick(){
      if(window.active){
        window.reload_wait = true;
        ws.send(enc(tuple( atom('client'), tuple(atom('reload_active')) )));
      }else{
        timerId = setTimeout(tick, 200);
      }
    }, 100);
  }
}

function reload_active_bind(){
  qi('reload_active_lots').addEventListener("click", do_reload_active, false);
}

function do_new_bet1(e){
  if(window.user_money > 0){
  var btn = e.target;
  var new_bet = btn.previousSibling.value;
  var lot_id = btn.parentNode.parentNode.dataset.id;
  if(window.user_money >= new_bet){
  if(window.bet1_wait !== true){
    var timerId = setTimeout(function tick(){
      if(window.active){
        window.bet1_wait = true;
        ws.send(enc(tuple( atom('client'), tuple(atom('new_bet1'), number(lot_id), number(new_bet) )  )));
      }else{
        timerId = setTimeout(tick, 200);
      }
    }, 100);
  }
  }else{
    alert('You need more money !');
  }
 }else{
   alert('You need more money !');
 }
}

function new_bet1_bind(){
  var els = document.querySelectorAll('.new_bet');
  els.forEach(function(el){
    el.addEventListener("click", function(e){do_new_bet1(e);}, false);
  });
}

function new_bet1_unbind(){
  var els = document.querySelectorAll('.new_bet');
  els.forEach(function(el){
    el.removeEventListener("click", function(e){do_new_bet1(e);}, false);
  });
}

function update_display_user_money(){
  if(window.upd_user_money_wait !== true){
    var timerId = setTimeout(function tick(){
      if(window.active){
        window.upd_user_money_wait = true;
        ws.send(enc(tuple( atom('client'), tuple(atom('update_user_money') )  )));
      }else{
        timerId = setTimeout(tick, 200);
      }
    }, 100);
  }
}

function update_display_active_lots(){
  var ids = "";
  var els = document.querySelectorAll('.a_lots');
  els.forEach(function(el){
    if(el.classList.contains("hide") === false){
      ids = ids + el.dataset.id + ',';
    }
  });
  if(ids.length > 0){
    ids = ids.substr(0, ids.length - 1);
    if(window.upd_active_lots_wait !== true){
      var timerId = setTimeout(function tick(){
        if(window.active){
          window.upd_active_lots_wait = true;
          ws.send(enc(tuple( atom('client'), tuple(atom('update_active_lots'), utf8_toByteArray(ids) ) )));
        }else{
          timerId = setTimeout(tick, 200);
        }
      }, 100);
    }
  }
}

function do_update_display_active_lots(arr){
  // '[ [ Id, Status, \'Timer_Time\', Lot_Bet_Input, Bet_Count, Bet_Last, \'Nickname_Last\' ], ... ]'
  // Status - 1=active, 2=finished
  if(arr !== '[]'){ arr = JSON.parse(arr); }else{ return ;}
  var els = document.querySelectorAll('.a_lots');
  arr.forEach(function(arr_el){
    els.forEach(function(el){
      if(el.classList.contains("hide") === false){
        var id = arr_el[0];
        if(Number(el.dataset.id) === id){
          if(arr_el[1] !== 1){
            el.classList.add("hide");
          }else{
            //clearTimeout(timers[id]);
            //el.querySelector('.a_lot_time').innerHTML = arr_el[2];
            if(lots_bets_count[id] !== arr_el[4]){
            lots_bets_count[id] = arr_el[4];
            el.querySelector('.a_lot_nickname_last').innerHTML = arr_el[6];
            el.querySelector('.a_lot_bet_last').innerHTML = '$ ' + arr_el[5];
            el.querySelector('.a_lot_bet_count').innerHTML = arr_el[4];
            var inp1 = el.querySelector('.a_lot_bet');
            inp1.querySelector('input').value = arr_el[3];
            inp1.querySelector('input').min = arr_el[3];
            }
          }
        }
      }
    });
  });
  //page_timers_back();
}

