
/*
Modify links to boxes here
*/
/*var linkMap={
	"camera":"http://www.google.com",
	"interoperability":"EnsPortal.ProductionConfig.zen?$NAMESPACE=PYTHON&IRISUserName=SuperUser&IRISPassword=SYS",
	"objectdetection":"EnsPortal.BPLEditor.zen?NAMESPACE=PYTHON&BP=od.DetectObject.bpl&IRISUserName=SuperUser&IRISPassword=SYS"
}
function window_open(url)
{
	var winReference = window.open();
	winReference.location = url;
	winReference.parent.focus();
}
window.onload=function() {
	for (key in linkMap) {
		var elem=document.getElementById(key); 
		elem.onclick=function() {
			window_open(linkMap[this.getAttribute("id")]);
		};
		console.log(linkMap[key]);
	};
}*/

function sendImage(index) {
	request={};
	request.path="shelf_images";
	request.file="Fruitshelf"+str(index);
	// construct an HTTP requests
  	var xhr = new XMLHttpRequest();
  	xhr.open("POST", "https://www.google.com", true);
  	xhr.setRequestHeader('Content-Type', 'application/json; charset=UTF-8');
  	// send the collected data as JSON
  	xhr.send(JSON.stringify(request));
  	xhr.onloadend = function () {
    	alert("Image sent for recognition")
  	};
}