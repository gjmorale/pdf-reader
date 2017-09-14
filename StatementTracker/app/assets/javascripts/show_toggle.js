
$(document).ready(function () {
    $('.toggle-on-click').click(function (event) {
        if ($(this).data('toggle') == 'open') {
            console.log("closing")
            $(this).parent().children('.show-on-click').each(function () {
                $(this).hide(250);
            });
            $(this).data('toggle','close')
        } else {
            $(this).parent().children('.show-on-click').each(function () {
                $(this).show(250);
            });
            $(this).data('toggle','open')
        }
    });
});