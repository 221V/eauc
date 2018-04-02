
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


function bind_admin_menu(){
  var btn_ids = [ 'menu_add_lot', 'menu_a_lot_edit', 'menu_last_bets_all', 'menu_last_bets_by_lot_id' ];
  var btns = [ qi(btn_ids[0]), qi(btn_ids[1]), qi(btn_ids[2]), qi(btn_ids[3]) ];
  var menublocks = [ qi('add_lot'), qi('a_lot_edit'), qi('last_bets_all'), qi('last_bets_by_lot_id') ];
  btn_ids.forEach(function(el_id,j){
    btns[j].addEventListener("click", function(e){
      var btnt = e.target;
      menublocks.forEach(function(el2){
      el2.style.display = 'none';
      });
      
      btn_ids.forEach(function(el_id2, i){
      btns[j].classList.remove("active");
      if(el_id == btn_ids[i]){ menublocks[i].style.display = 'block'; }
      });
      btnt.classList.add("active");
      
    }, false);
  });
}

function set_time_now(a){
  var a2 = a.substr(0, a.length - 3);
  qi('add_lot_start_time').value = a2;
}

function date_time2date_for_server(a){
  var re1 = /^[0-9]{2}\.[0-9]{2}\.[0-9]{4},[0-9]{2}:[0-9]{2}$/i;  //datetime
  //var re2 = /^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}$/i;  //datetime
  var re3 = /^[0-9]{4}\/[0-9]{2}\/[0-9]{2}[\s]{1}[0-9]{2}:[0-9]{2}$/i;  //datetime
  
  if(re1.test(a) === true){
    var v0 = a.split(',');
    var v1 = v0[0].split('.');
    return v1[2] + '/' + v1[1] + '/' + v1[0] + ' ' + v0[1];
  }else{
    if(re3.test(a) === true){ return a; }
    return '0';
  }
}

function endtime_by_start(start_time, interval){
  //calc end time by start time and interval
  var start_timestamp = Date.parse(start_time);
  if(isNaN(start_timestamp)){
    var v0 = start_time.split(',');
    var v1 = v0[0].split('.');
    start_timestamp = Date.parse( v1[2] + '/' + v1[1] + '/' + v1[0] + ' ' + v0[1] );
  }
  var interval1 = interval.split(':');
  var end_timestamp = start_timestamp + ((Number(interval1[0])*24*60*60 + Number(interval1[1])*60*60 + Number(interval1[2])*60 + Number(interval1[3]))*1000);//millisec (sec * 1000)
  var end_time0 = new Date(end_timestamp);
  var end_time_month = end_time0.getMonth() + 1;
  var end_time_day = end_time0.getDate();
  var end_time_hours = end_time0.getHours();
  var end_time_minits = end_time0.getMinutes();
  if(end_time_month < 10){ end_time_month = '0' + end_time_month; }
  if(end_time_day < 10){ end_time_day = '0' + end_time_day; }
  if(end_time_hours < 10){ end_time_hours = '0' + end_time_hours; }
  if(end_time_minits < 10){ end_time_minits = '0' + end_time_minits; }
  return end_time0.getFullYear() + '/' + end_time_month + '/' + end_time_day + ' ' + end_time_hours + ':' + end_time_minits;
}

function time_length_by_start_end(start_time, end_time){
  //calc interval by start time and end time
  var start_timestamp = Date.parse(start_time);
  var end_timestamp = Date.parse(end_time);
  
  if(isNaN(start_timestamp)){
    var v0 = start_time.split(',');
    var v1 = v0[0].split('.');
    start_timestamp = Date.parse( v1[2] + '/' + v1[1] + '/' + v1[0] + ' ' + v0[1] );
  }
  if(isNaN(end_timestamp)){
    var vn0 = end_time.split(',');
    var vn1 = vn0[0].split('.');
    end_timestamp = Date.parse( vn1[2] + '/' + vn1[1] + '/' + vn1[0] + ' ' + vn0[1] );
  }
  
  var all_sec = Math.floor((end_timestamp - start_timestamp)/1000);
  if(all_sec < 1){ return NaN; }
  if(all_sec < 60){
    if(all_sec < 10){ all_sec = '0' + all_sec; }
    return '00:00:00:' + all_sec;
  }
  var sec = all_sec % 60;
  if(sec < 10){ sec = '0' + sec; }
  var all_min = Math.floor(all_sec/60);
  if(all_min < 60){
    if(all_min < 10){ all_min = '0' + all_min; }
    return '00:00:' + all_min + ':' + sec;
  }
  var min = all_min % 60;
  if(min < 10){ min = '0' + min; }
  var all_hour = Math.floor(all_min/60);
  if(all_hour < 24){
    if(all_hour < 10){ all_hour = '0' + all_hour; }
    return '00:' + all_hour + ':' + min + ':' + sec;
  }
  var hour = all_hour % 24;
  if(hour < 10){ hour = '0' + hour; }
  var day = Math.floor(all_hour/24);
  if(day > 99){ return '99:' + hour + ':' + min + ':' + sec; }
  if(day < 10){ day = '0' + day; }
  return day + ':' + hour + ':' + min + ':' + sec;
}

function valid_addlot_info(){
  var re1 = /^[0-9]{2}\.[0-9]{2}\.[0-9]{4},[0-9]{2}:[0-9]{2}$/i;  //datetime
  //var re2 = /^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}$/i;  //datetime
  var re3 = /^[0-9]{4}\/[0-9]{2}\/[0-9]{2}[\s]{1}[0-9]{2}:[0-9]{2}$/i;  //datetime
  var re4 = /^[0-9]{2}:[0-9]{2}:[0-9]{2}:[0-9]{2}$/i;  //time interval length
  
  var valid_lot_name = (qi('add_lot_name').value.trim() !== "");
  var valid_lot_count = Number(qi('add_lot_count').value) > 0;
  var valid_start_bet = Number(qi('add_lot_start_bet').value) > 0;
  var valid_bet_step = Number(qi('add_lot_bet_step').value) > 0;
  var valid_lot_prise = (qi('add_lot_prise').value.trim() !== "");
  
  var valid_start_time = re1.test(qi('add_lot_start_time').value);
  //if(valid_start_time === false){ valid_start_time = re2.test(qi('add_lot_start_time').value); }
  if(valid_start_time === false){ valid_start_time = re3.test(qi('add_lot_start_time').value); }
  var valid_time_length = re4.test(qi('add_lot_time_length').value);
  //var valid_end_time = re1.test(qi('add_lot_end_time').value);
  //if(valid_end_time === false){ valid_end_time = re2.test(qi('add_lot_end_time').value); }
  //if(valid_end_time === false){ valid_end_time = re3.test(qi('add_lot_end_time').value); }
  
  return valid_lot_name && valid_lot_count && valid_start_bet && valid_bet_step && valid_lot_prise && valid_start_time && valid_time_length;
}

function do_auc_time_change(e){
  var el_id = e.target.id;
  
  var re1 = /^[0-9]{2}\.[0-9]{2}\.[0-9]{4},[0-9]{2}:[0-9]{2}$/i;  //datetime
  var re2 = /^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}$/i;  //datetime
  var re3 = /^[0-9]{4}\/[0-9]{2}\/[0-9]{2}[\s]{1}[0-9]{2}:[0-9]{2}$/i;  //datetime
  var re4 = /^[0-9]{2}:[0-9]{2}:[0-9]{2}:[0-9]{2}$/i;  //time interval length
  
  //console.log(e);
  //console.log(el_id);
  var startv = qi('add_lot_start_time').value;
  var lengthv = qi('add_lot_time_length').value;
  var endv = qi('add_lot_end_time').value;
  
  if((startv == '') && (lengthv == '') && (endv == '')){
    alert('lot\'s time err !!');
    return ;
  }
  
  if(el_id === 'add_lot_start_time'){
    if(startv == ''){
      alert('lot\'s time err !!');
      return ;
    }
    if((startv !== '') && (lengthv !== '')){
      //end by start and length
      if((re1.test(startv) || re2.test(startv) || re3.test(startv)) && re4.test(lengthv)){
        var endv2 = endtime_by_start(startv, lengthv);
        qi('add_lot_end_time').value = endv2;
        return ;
      }else{
        alert('lot\'s time err !!');
        return ;
      }
      
    }else if((startv !== '') && (endv !== '')){
      //length by start and end
      if((re1.test(startv) || re2.test(startv) || re3.test(startv)) && (re1.test(endv) || re2.test(endv) || re3.test(endv))){
        var time_length = time_length_by_start_end(startv, endv);
        qi('add_lot_time_length').value = time_length;
      }else{
        alert('lot\'s time err !!');
        return ;
      }
      
    }else{
      alert('lot\'s time err !!');
      return ;
    }
    
  }else if(el_id === 'add_lot_time_length'){
    if(lengthv == ''){
      //length by start and end
      //if((re1.test(startv) || re2.test(startv) || re3.test(startv)) && (re1.test(endv) || re2.test(endv) || re3.test(endv))){
        //var time_length = time_length_by_start_end(startv, endv);
        //qi('add_lot_time_length').value = time_length;
      //}else{
        alert('lot\'s time err !!');
        return ;
      //}
      
    }else{
      //end by start and length
      if((re1.test(startv) || re2.test(startv) || re3.test(startv)) && re4.test(lengthv)){
        var endv2 = endtime_by_start(startv, lengthv);
        qi('add_lot_end_time').value = endv2;
        return ;
      }else{
        alert('lot\'s time err !!');
        return ;
      }
      
    }
    
  }else{
    //el_id === 'add_lot_end_time'
    if((endv == '') && (startv == '')){
      alert('lot\'s time err !!');
      return ;
    }
    if((startv !== '') && (lengthv !== '')){
      //end by start and length
      if((re1.test(startv) || re2.test(startv) || re3.test(startv)) && re4.test(lengthv)){
        var endv2 = endtime_by_start(startv, lengthv);
        qi('add_lot_end_time').value = endv2;
        return ;
      }else{
        alert('lot\'s time err !!');
        return ;
      }
    
    }else if((startv !== '') && (endv !== '')){
      //length by start and end
      if((re1.test(startv) || re2.test(startv) || re3.test(startv)) && (re1.test(endv) || re2.test(endv) || re3.test(endv))){
        var time_length = time_length_by_start_end(startv, endv);
        qi('add_lot_time_length').value = time_length;
      }else{
        alert('lot\'s time err !!');
        return ;
      }
      
    }else{
      alert('lot\'s time err !!');
      return ;
    }
    
  }
}

function bind_auc_time_change(){
  qi('add_lot_start_time').addEventListener("change", function(e){do_auc_time_change(e);}, false);
  qi('add_lot_time_length').addEventListener("change", function(e){do_auc_time_change(e);}, false);
  qi('add_lot_end_time').addEventListener("change", function(e){do_auc_time_change(e);}, false);
}

function do_add_lot(){
  if(valid_addlot_info()){
    if(window.new_lot_wait !== true){
      var timerId = setTimeout(function tick(){
        if(window.active){
          window.new_lot_wait = true;
          var start_time_timestamp = date_time2date_for_server(qi('add_lot_start_time').value);
          ws.send(enc(tuple( atom('client'), tuple(atom('add_lot'), querySource('add_lot_name'), querySource('add_lot_count'), querySource('add_lot_start_bet'), querySource('add_lot_bet_step'), querySource('add_lot_prise'), bin(start_time_timestamp), querySource('add_lot_time_length') ) )));
        }else{
          timerId = setTimeout(tick, 200);
        }
      }, 100);
    }
  }else{
    alert('lot\'s data err !!');
  }
}

function do_edit_lot_load(){
  alert('do edit lot load !');
}

function do_edit_active_lot(){
  alert('do edit active lot !');
}

function bind_add_lot_btn(){
  var el = qi('add_lot_btn');
  if((window.dobind_add_lot !== true) && el){
    window.dobind_add_lot = true;
    el.addEventListener("click", do_add_lot, false);
  }
}

function bind_edit_lot_load_btn(){
  var el = qi('edit_lot_id_load');
  if((window.dobind_edit_lot_load !== true) && el){
    window.dobind_edit_lot_load = true;
    el.addEventListener("click", do_edit_lot_load, false);
  }
}

function bind_edit_active_lot_btn(){
  var el = qi('a_edit_lot_btn');
  if((window.dobind_edit_active_lot !== true) && el){
    window.dobind_edit_active_lot = true;
    el.addEventListener("click", do_edit_active_lot, false);
  }
}











