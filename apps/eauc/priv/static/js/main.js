
function true_time(v){
  if(v < 10){return '0' + v;}
  return v;
}

function time_tick_tick(){
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
    var timerId = setTimeout(function tick(){
      sec++;
      if(sec == 60){sec = 0;min++;}
      if(min == 60){min = 0;hour++;}
      if(hour == 24){hour = 0;day++;}
      qi('time_now').innerHTML = date0[0] + '/' + date0[1] + '/' + true_time(day) + ' ' + true_time(hour) + ':' + true_time(min) + ':' + true_time(sec);
      timerId = setTimeout(tick, 990);
    }, 100);
  }
}

function go_login(){
  var re = /^(.)+@(.)+\.(.+)$/i;/*login-email*/
  var login_value = qi('login').value;
  var valid = (login_value !== '') && (qi('password').value !== '') && (re.test(login_value));
  if(valid){
    if(window.login_wait !== true){
      var timerId = setTimeout(function tick(){
        if(window.active){
          window.login_wait = true;
          ws.send(enc(tuple( atom('client'), tuple(atom('login'), querySource('login'), querySource('password')) )));
        }else{
          timerId = setTimeout(tick, 200);
        }
      }, 100);
    }
  }else{ alert('login data err !'); }
}

function login_form_bind(){
  qi('login_btn').addEventListener("click", go_login, false);
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

function auction_url_or_not(){
  if(window.is_logged == true){ return '<br><p><a href="/auction/">Go to auction</a></p>'; }
  return '<br><p>Please Log In for participate auction !</p>';
}

function do_reload_finished(){
  if(window.reload_wait !== true){
    var timerId = setTimeout(function tick(){
      if(window.active){
        window.reload_wait = true;
        ws.send(enc(tuple( atom('client'), tuple(atom('reload_finished')) )));
      }else{
        timerId = setTimeout(tick, 200);
      }
    }, 100);
  }
}

function reload_finished_bind(){
  qi('reload_finished_main').addEventListener("click", do_reload_finished, false);
}

function reload_finished_unbind(){
  var btn = qi('reload_finished_main');
  if(btn){
    btn.removeEventListener("click", do_reload_finished, false);
  }
}

function add_url(html){
  var parent = qi('hello_user');
  var newp = document.createElement('p');
  newp.innerHTML = html;
  parent.insertBefore(newp, parent.children[1]);
}


