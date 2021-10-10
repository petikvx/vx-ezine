' Article: Polymorphism using XML
'
' Written by ANAkTOS[MATRiX] 
' for MTX#3 zine
' 
' Credits to Rajaat


'Variables
Dim xmlDoc
Dim parsedDoc
Dim nodeList
Dim currNode
Dim count

'Initialize randomizer
Randomize 

'Create 1 instance of an XML Object 
'turn of asynchronous comminication
'preserve WhiteSpace/tabs/newlines/etc 
Set xmlDoc = CreateObject("Microsoft.XMLDOM")
xmlDoc.async = false
xmlDoc.preserveWhiteSpace = true

'Load the XML document
xmlDoc.load("polyxml.xml")

'Call the engine and presend the result
WScript.Echo PolyGenerate(xmlDoc.documentElement)









































' ---- The Engine start here ----






'General dispatcher
Function PolyGenerate(xmlElement)

	if( xmlElement.nodeTypeString="text") then
		PolyGenerateRemoveElement(xmlElement)
		Exit Function
	end if
	
	if( xmlElement.tagName = "all" ) then
		PolyGenerate= PolyGenerateAll(xmlElement)
		Exit Function
	end if	
	 
	if( xmlElement.tagName = "select" ) then
		PolyGenerate= PolyGenerateSelect(xmlElement)
		Exit Function
	end if	

	if( xmlElement.tagName = "random" ) then
		PolyGenerate= PolyGenerateRandom(xmlElement)
		Exit Function
	end if	

	if( xmlElement.tagName = "shift" ) then
		PolyGenerate= PolyGenerateShift(xmlElement)
		Exit Function
	end if	

	if( xmlElement.tagName = "code" ) then
		PolyGenerate= PolyGenerateCode(xmlElement)
		Exit Function
	end if	
	
	if( xmlElement.tagName = "outtext" ) then
		PolyGenerate= PolyGenerateText(xmlElement)
		Exit Function
	end if	
	
	PolyGenerate= PolyGenerateAll(xmlElement)
	
End Function 



'Evaluate all childs.
'Only move to the next child if the 
'current has been fully evaluated.
Function PolyGenerateAll(xmlElement)
	Do 
		PolyGenerateAll= PolyGenerateAll & PolyGenerate( xmlElement.firstChild ) 
	Loop While(xmlElement.childNodes.Length>0)
	PolyGenerateRemoveElement(xmlElement)
End Function



'Leave only one child and remove the rest.
'Then evaluate it.
Function PolyGenerateSelect(xmlElement)
	'keep only one child in the element 
	xmlElement.appendChild(xmlElement.childNodes.item( int(xmlElement.childNodes.Length * rnd) ))	  	
	  For Count = 1 to xmlElement.childNodes.Length-1
	    xmlElement.removeChild( xmlElement.childNodes.item(0) )	   
	Next
	'Evaluate only the first (and only) child
	set childElement= xmlElement.childNodes.item( 0 )
	PolyGenerateSelect= PolyGenerate( childElement )
	PolyGenerateRemoveEmptyElement(xmlElement)
End Function 



'Evaluate one child each time, randomly.
Function PolyGenerateRandom(xmlElement)
	set childElement= xmlElement.childNodes.item( int(xmlElement.childNodes.Length * rnd) )
	PolyGenerateRandom= PolyGenerate( childElement )
	PolyGenerateRemoveEmptyElement(xmlElement)
End Function



'Evaluate one child each time, Starting with the first.
'Move with the next only if the previous if fully evaluated
Function PolyGenerateShift(xmlElement)	
	PolyGenerateShift= PolyGenerate( xmlElement.firstChild )
	PolyGenerateRemoveEmptyElement(xmlElement)
End Function 



'execute code
Function PolyGenerateCode(xmlElement)
	eval(PolyGenerateText=xmlElement.text)
	PolyGenerateRemoveElement(xmlElement)
End Function



'emmit data
Function PolyGenerateText(xmlElement)
	PolyGenerateText=xmlElement.text
	PolyGenerateRemoveElement(xmlElement)
End Function 



'remove element only if it's empty
Function PolyGenerateRemoveEmptyElement(xmlElement)
	if (xmlElement.childNodes.Length=0) then
		PolyGenerateRemoveElement(xmlElement)
	end if
End Function



'remove element nevertheless
Function PolyGenerateRemoveElement(xmlElement)
	set ParentElement= xmlElement.parentNode
	ParentElement.removeChild(xmlElement)
End Function





' ---- The Engine end here ----

