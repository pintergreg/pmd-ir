function init(){
	
	$('table.tablesorter').tablesorter({
		widgets: ['zebra'],
		textSorter: {
			0 : Array.AlphanumericSort
		}
	});
}

function sendPost(file, line){
	//~ $.ajax({
		//~ type: "POST",
		//~ url: "/pmd/source",
		//~ data: data,
		//~ success: success,
		//~ dataType: dataType
	//~ });
	
	$.post( "/pmd/source", { "file": file, "line": line } );
}

function alma(){
	$.ajax({
		type: "GET",
		url: "/pmd/source",
		data: { "file": "/tmp/file.txt", "line": 42 },
		success: function(){
			$("#message").html("Successfully registered");
			alert("Successfully registered");
		},
		error: function(){
			$("#message").html("Not Successful");
			alert("Not Successful");
		}
	});
}
