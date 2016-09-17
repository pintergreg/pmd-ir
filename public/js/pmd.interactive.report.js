function init(){
	$('table.tablesorter').tablesorter({
		widgets: ['zebra'],
		textSorter: {
			0 : Array.AlphanumericSort
		}
	});
}

function annotateCode(){
	var data = JSON.parse($('#jsondiv').html());
	$('.line-highlight').each(function(index) {
		//~ $(this).html(data[index]['Rule']);
		var line = Math.round(( $(this).position().top / $(this).height() ) + 1);
		
		$(this).attr("onclick", "tooltipAnnotation(this);");
		$(this).attr("title", getRelevantError(data, line));
	});
}

function getRelevantError(dataJson, lineNumber){
	var message = "";
	var no = 1;
	for(var i = 0; i < dataJson.length; i++) {
		if (dataJson[i]["Line"] == lineNumber){
			message += "\n#" + no + " (with priority " +  dataJson[i]["Priority"] + "): " + dataJson[i]["Description"];
			no++;
		}
	}
	return message.trim();
}

function tooltipAnnotation(caller){
	vex.dialog.alert({
		message: $(caller).attr("title").replace(/\n/g, '<br/>'),
		className: 'vex-theme-bottom-right-corner'
	});
}
