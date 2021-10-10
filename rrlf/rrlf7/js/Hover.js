function ArticlesOver(Status)
{
	if(Status == 0) document.images.articles.src = "../images/Top_Articles_Out.jpg";
	if(Status == 1) document.images.articles.src = "../images/Top_Articles_Over.jpg";
}

function SourcesOver(Status)
{
	if(Status == 0) document.images.sources.src = "../images/Top_Sources_Out.jpg";
	if(Status == 1) document.images.sources.src = "../images/Top_Sources_Over.jpg";
}

function ArtOver(Status)
{
	if(Status == 0) document.images.art.src = "../images/Top_Art_Out.jpg";
	if(Status == 1) document.images.art.src = "../images/Top_Art_Over.jpg";
}