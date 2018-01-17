
$(document).ready(function() { 
	$("select.select2").select2();
	$("select.select2-blank").select2({
	    placeholder: "",
	    allowClear: true
	}); 

});