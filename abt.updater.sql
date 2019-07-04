CREATE OR REPLACE PROCEDURE ABT.updater(x IN VARCHAR2 DEFAULT 'MAIN') IS
	action VARCHAR2(64):=UPPER(x);
	p_sig VARCHAR2(32);
	v_comment VARCHAR2(512);
	v_out VARCHAR2(512);
BEGIN
	IF action='STATUS' THEN 
		SELECT SYS_CONTEXT('USERENV','SERVER_HOST')||TO_CHAR(SYSDATE,'_ddmmyyyy') INTO p_sig FROM dual;
		abt.update_api.get@"orcl.update.wera"(action,p_sig,v_out);
		htp.prn(v_out);
	END IF;

	IF action = 'INFO'
	THEN
		begin
			SELECT NAME INTO V_COMMENT FROM REF_STORES WHERE 
				upper(name) NOT LIKE upper('%уценка%')
				AND id IN (SELECT unique ID_STORE_SENDER FROM DOC_GOODS)
				AND sortid = 999;
			EXCEPTION WHEN OTHERS THEN 
				SELECT NAME INTO V_COMMENT FROM REF_STORES WHERE upper(name) NOT LIKE upper('%уценка%')AND sortid = 999;
		END;
		htp.prn('Склад:<b>'||v_comment||'</b>');			
	END IF;

	IF action='MAIN' THEN
  		htp.prn('<HTML><title>Обновление справочников</title>
<BODY>
<center>
<div id="citd">При возникновении проблем:<br>support.db@wera-rus.com</div>
<div id="itbl"></div>
<div id="tdiv"></div>
<div id="sbs">Начать обновление</div>
<div class="sd"></div>
<div id="pdc"><div id="pd"></div></div>
<div id="cd"></div>
</center>
</BODY>
</HTML>
<!--<link  href="http://localhost/edi/upd/style.css" rel="stylesheet">
<script src="http://localhost/edi/upd/script.js"></script>-->
<style>
body{margin:0;padding:0}#tdiv{padding:0 15px;width:500px;margin:5px}#tdiv,.update_done,.update_fail,.update_process{padding-top:20px;color:#000;width:50%;height:80px;font-size:30px}.update_done{background-color:#b2f27d}.update_fail{background-color:#f2573c}.sd{font-size:15px}#citd{font-weight:700;background:#e55;padding:50px 0;font-size:2.5em;color:#000}#pdc{height:30px;width:45%;background:#ddd}#pd{height:30px;width:0%;background:#95d852;float:left}#sbs{background:#ddd;width:450px;padding:25px 45px;font-size:2.5em;margin:10px}#sbs:hover{background:#ccf}#aub{position:fixed;bottom:10px;color:gray;background:#fdd;width:250px;padding:15px 35px;font-size:1em;margin:10px}#aub:hover{background:#faa;color:red}
</style>
<script>
var i,t=0,c=$("cd"),p=$("pd"),pc=$("pdc"),s=$("sbs"),d=$("tdiv"),u=$("sd"),itbl=$("itbl"),txt=["Ошибка вывода данных обновления","Прошло: ","Обновление завершено! ","Ошибка во время обновления,повторите попытку!<br>","обновлено ","Отмена обновления"],pth="/abt/updater?x=";function fu(){hide(p),hide(pc),ajax(pth+"INFO",function(t){itbl.innerHTML=txt[0]},function(t){itbl.innerHTML=t.target.responseText})}function EndUpdate(){UpdateStatus(),clearInterval(i),show(s),d.innerHTML=txt[2]+new Date(1e3*t).toISOString().substr(11,8),addClass(d,cs[0]),fu()}function UpdateStatus(){ajax(pth+"STATUS",function(t){itbl.innerHTML=txt[0]},function(t){setp(JSON.parse(t.target.responseText))}),d.innerHTML=txt[1]+new Date(1e3*t++).toISOString().substr(11,8)}function setp(t){"9"===t[0]&&EndUpdate(),p.style.width=100/9*t[0]+"%",c.innerHTML=txt[4]+t[0]+"/9"}function fail(t){console.log("fail: "+t.target.responseText),clearInterval(i),d.innerHTML=txt[3]+t.target.responseText,addClass(d,cs[1]),fu()}function ajax(t,e,n){var a=new XMLHttpRequest;a.open("GET",t,!0),a.onload=function(t){4===a.readyState&&(200===a.status?n(t):e(t))},a.onerror=e,a.send()}function $(t){return document.getElementById(t)}function getRealDisplay(t){return t.currentStyle?t.currentStyle.display:window.getComputedStyle?window.getComputedStyle(t,null).getPropertyValue("display"):void 0}function hide(t){t.getAttribute("displayOld")||t.setAttribute("displayOld",t.style.display),t.style.display="none"}function isHidden(t){var e=t.offsetWidth,n=t.offsetHeight,a="tr"===t.nodeName.toLowerCase();return 0===e&&0===n&&!a||(!(0<e&&0<n)||a)&&getRealDisplay(t)}function show(t){if("none"==getRealDisplay(t)){var e=t.getAttribute("displayOld");if(t.style.display=e||"","none"===getRealDisplay(t)){var n,a=t.nodeName,s=document.body;if(displayCache[a])n=displayCache[a];else{var i=document.createElement(a);s.appendChild(i),"none"===(n=getRealDisplay(i))&&(n="block"),s.removeChild(i),displayCache[a]=n}t.setAttribute("displayOld",n),t.style.display=n}}}function removeClass(t,e){for(var n=t.className.split(" "),a=0;a<n.length;a++)n[a]==e&&n.splice(a--,1);t.className=n.join(" ")}function addClass(t,e){-1==t.className.split(" ").indexOf(e)&&(t.className+=" "+e)}cs=["update_done","update_fail"],fu(),s.onclick=function(){hide(s),removeClass(d,cs[0]),removeClass(d,cs[1]),t=0,ajax(pth+"START_UPDATE",function(t){fail(t)},null),i=setInterval(UpdateStatus,1e3),show(p),show(pc)},displayCache={};
</script>
');
END IF;


	IF action='START_UPDATE' THEN 
		abt.pkg_update.START_UPDATE(); 
	END IF;

EXCEPTION WHEN OTHERS THEN htp.prn(SQLERRM||' | '||v_out);
END updater;
/
