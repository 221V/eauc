
var timers = [];


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

function update_money_lotinfo_display(){
  console.log('bet2');
}

function do_new_bet1(e){
  var btn = e.target;
  var new_bet = btn.previousSibling.value;
  var lot_id = btn.parentNode.parentNode.dataset.id;
  
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

