
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
