$(document).ready(function () {
	$('div.field-with-errors').hover(function() {
	    $(this).find('div.error-message').show();
	}, function() {
	    $(this).find('div.error-message').hide();
	});
});