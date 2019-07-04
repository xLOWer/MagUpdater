var i, t = 0,
	c = $("cd"),
    p = $("pd"),// progress
    pc = $("pdc"),// progress container
    s = $("sbs"),// start button
    d = $("tdiv"),
    u = $("sd"),
    itbl = $("itbl"),
	txt=["Ошибка вывода данных обновления", "Прошло: ", "Обновление завершено! ", "Ошибка во время обновления,повторите попытку!<br>", "обновлено ", "Отмена обновления"],
	pth = "/abt/updater?x=";
	cs = ["update_done", "update_fail"];

fu();

s.onclick = function() 
{
	hide(s);
	removeClass(d, cs[0]);
	removeClass(d, cs[1]);
	t = 0;

	ajax(pth+"START_UPDATE",
		function (e) {fail(e);}, 
		null
	);
	
	i = setInterval(UpdateStatus, 1e3);
	show(p);
	show(pc);
};

function fu()
{
	hide(p);
	hide(pc);		

	ajax(pth+"INFO",
		function (e) { itbl.innerHTML = txt[0]; }, 
		function (e) { itbl.innerHTML = e.target.responseText; }
	);
}

function EndUpdate()
{
	UpdateStatus();	
	clearInterval(i);
	show(s);
	d.innerHTML = txt[2] + new Date(1e3 * t).toISOString().substr(11, 8);
	addClass(d,cs[0]);
	fu();
}


function UpdateStatus() 
{	
	ajax(pth+"STATUS",
		function (e) { itbl.innerHTML = txt[0]; }, 
		function (e) { setp(JSON.parse(e.target.responseText)); }
	);
	
	d.innerHTML = txt[1] + new Date(1e3 * t++).toISOString().substr(11, 8);
}

function setp(e)
{
	if(e[0] === "9") EndUpdate();
	p.style.width = (100 / 9 * e[0]) + "%";
	c.innerHTML = txt[4] + e[0]+"/9";
}

function fail(e)
{
	console.log("fail: " + e.target.responseText);
    clearInterval(i);
	d.innerHTML = txt[3] + e.target.responseText;
	addClass(d, cs[1] );
	fu();
}

/***************************************************************************************/

function ajax(url, onerr, onld)
{
	var xhr = new XMLHttpRequest();	
	xhr.open("GET", url, true);
	xhr.onload = function (e) 
	{
		if (xhr.readyState === 4)
			if (xhr.status === 200) onld(e);
			else onerr(e);
	};
	xhr.onerror = onerr;
	xhr.send();
}

function $(e){return document.getElementById(e)}	

/***************************************************************************************/

function getRealDisplay(elem) {
	if (elem.currentStyle) {
		return elem.currentStyle.display
	} else if (window.getComputedStyle) {
		var computedStyle = window.getComputedStyle(elem, null )

		return computedStyle.getPropertyValue("display")
	}
}

function hide(el) {
	if (!el.getAttribute("displayOld")) {
		el.setAttribute("displayOld", el.style.display)
	}

	el.style.display = "none"
}

displayCache = {}

function isHidden(el) {
	var width = el.offsetWidth, height = el.offsetHeight,
		tr = el.nodeName.toLowerCase() === "tr"

	return width === 0 && height === 0 && !tr ?
		true : width > 0 && height > 0 && !tr ? false :	getRealDisplay(el)
}

function show(el) {

	if (getRealDisplay(el) != "none") return

	var old = el.getAttribute("displayOld");
	el.style.display = old || "";

	if ( getRealDisplay(el) === "none" ) {
		var nodeName = el.nodeName, body = document.body, display

		if ( displayCache[nodeName] ) {
			display = displayCache[nodeName]
		} else {
			var testElem = document.createElement(nodeName)
			body.appendChild(testElem)
			display = getRealDisplay(testElem)

			if (display === "none" ) {
				display = "block"
			}

			body.removeChild(testElem)
			displayCache[nodeName] = display
		}

		el.setAttribute("displayOld", display)
		el.style.display = display
	}
}

function removeClass(obj, cls) {
	var classes = obj.className.split(" ");

	for (var i = 0; i < classes.length; i++)
		if (classes[i] == cls) 
			classes.splice(i--, 1);			
	obj.className = classes.join(" ");
}

function addClass(obj, cls) {
	var arr;
	arr = obj.className.split(" ");
	if (arr.indexOf(cls) == -1) 
		obj.className += " " + cls;	
} 
