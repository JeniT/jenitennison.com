//<script languag="JavaScript">
//<author>Chris@bayes.co.uk</author>
//<website>http://www.bayes.co.uk</website>
//<disclaimer>This software may be used as long as this 
//header stays intact. No responsibility is accepted
//for use of this software.</disclaimer>
//debugger;
function domtodom(svg, embed){
	//debugger;
	var svgdoc = document.embeds[embed].getSVGDocument();
	for (i=svgdoc.childNodes.length-1; i >=0 ; i--){
		svgdoc.removeChild(svgdoc.childNodes.item(i));
	}
	copyNode(svg, svgdoc, svg, svgdoc);
}
function copyNode(snode, dnode, svg, svgdoc){
	var i=0;
	var newNode = null;
	for(i=0; i < snode.childNodes.length; i++){
		switch(snode.childNodes[i].nodeType){
			case 1: //NODE_ELEMENT
				newNode = svgdoc.createElement(snode.childNodes[i].nodeName);
				copyAttributes(snode.childNodes[i], newNode);
				break;
			case 2: //NODE_ATTRIBUTE
				newNode = svgdoc.createAttribute(snode.childNodes[i].nodeName);
				break;
			case 3: //NODE_TEXT
				newNode = svgdoc.createTextNode(snode.childNodes[i].nodeValue);
				break;
			case 4: //NODE_CDATA_SECTION 
				newNode = svgdoc.createCDATASection(snode.childNodes[i].nodeValue);
				break;
			case 5: //NODE_ENTITY_REFERENCE 
				newNode = svgdoc.createEntityReference(snode.childNodes[i].nodeName);
				break;
			case 6: //NODE_ENTITY 
				break;
			case 7: //NODE_PROCESSING_INSTRUCTION 
				newNode = svgdoc.createProcessingInstruction("xml", snode.childNodes[i].nodeValue);
				break;
			case 8: //NODE_COMMENT 
				newNode = svgdoc.createComment(snode.childNodes[i].nodeValue);
				break;
			case 9: //NODE_DOCUMENT
				break
			case 10: //NODE_DOCUMENT_TYPE 
				break;
			case 11: //NODE_DOCUMENT_FRAGMENT 
				newNode = svgdoc.createDocumentFragment();
				break;
			case 12: //NODE_NOTATION 
				break;
			default:
		}
		if (newNode != null){
			dnode.appendChild(newNode);
			copyNode(snode.childNodes[i], newNode, svg, svgdoc);
		}
	}
}
function copyAttributes(sNode, dNode){
	var i=0;
	for (i=0; i < sNode.attributes.length; i++){
		dNode.setAttribute(sNode.attributes[i].nodeName, sNode.attributes[i].nodeValue);
	}
}
//</script>