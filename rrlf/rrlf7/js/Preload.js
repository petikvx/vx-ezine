var Picture = new Array("../images/Top_Articles_Over.jpg", "../images/Top_Sources_Over.jpg", "../images/Top_Art_Over.jpg");
var Preload = new Array();

for(var i = 0; i < Picture.length; i++)
{
	Preload[i] = new Image();
	Preload[i].src = Picture[i];
}