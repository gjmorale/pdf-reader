
$(document).ready(function () {
    $('.toggle-on-click').click(function (event) {
        if ($(this).data('toggle') == 'open') {
            $(this).parent().children('.show-on-click').each(function () {
                $(this).hide(250);
            });
            $(this).data('toggle','close')
            $(this).find('span').html("&#8711;")
        } else {
            $(this).parent().children('.show-on-click').each(function () {
                $(this).show(250);
            });
            $(this).data('toggle','open')
            $(this).find('span').html("&#8710;")
        }
    });
});