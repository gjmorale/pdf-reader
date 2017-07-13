
$(document).ready(function () {
    $('.check_all').click(function (event) {
        if (this.checked) {
            $(this).parents('table').find(':checkbox').each(function () {
                this.checked = true;
            });
        } else {
            $(this).parents('table').find(':checkbox').each(function () {
                this.checked = false;
            });
        }
    });
});