// Inline Editing with jquery version of x-editable
// Can be adjusted on per input basis, popup errored for me so that would need work
$.fn.editable.defaults.mode = 'inline';
$.fn.editable.defaults.showbuttons = false;
$.fn.editable.defaults.onblur = 'submit';
$.fn.editable.defaults.ajaxOptions = { type: 'PUT', dataType: 'json' };
$.fn.editable.defaults.datepicker = { showOn: 'both', selectOtherMonths: true,
  buttonImage: 'https://cdnjs.cloudflare.com/ajax/libs/x-editable/1.5.1/jquery-editable/jquery-ui-datepicker/css/redmond/images/ui-icons_217bc0_256x240.png' };


function inlineEditing() {
  $('.editable_column').editable();
  $('.editable_column').closest('table').addClass('inline-edit-table');
}
$(document).ready(function () {
  inlineEditing();
});

$(document).ajaxComplete(function () {
  inlineEditing();
});

// Hack to adjust the alignment of the datepicker popup because we have a margin-left: auto #wrapper element
$.extend($.datepicker, {
  _checkOffset: function(inst, offset, isFixed) {
    var dpWidth = inst.dpDiv.outerWidth(),
        dpHeight = inst.dpDiv.outerHeight(),
        inputWidth = inst.input ? inst.input.outerWidth() : 0,
        inputHeight = inst.input ? inst.input.outerHeight() : 0,
        viewWidth = document.documentElement.clientWidth + ( isFixed ? 0 : $( document ).scrollLeft() ),
        viewHeight = document.documentElement.clientHeight + ( isFixed ? 0 : $( document ).scrollTop() );

    offset.left -= ( this._get( inst, "isRTL" ) ? ( dpWidth - inputWidth ) : 0 );
    offset.left -= ( isFixed && offset.left === inst.input.offset().left ) ? $( document ).scrollLeft() : 0;
    offset.top -= ( isFixed && offset.top === ( inst.input.offset().top + inputHeight ) ) ? $( document ).scrollTop() : 0;

    // @Daniel, my adjustment to make them align horizontally in our case
    // This isn't ideal but I've found that a margin-left: auto effects positioning
    // I expect proper solution is to loop through any parents that result in margin-left: auto (including
    // those defined indirectly like margin: auto; or margin: 0 auto; etc.) and sum their left offset
    // I did try doing the above with window.getComputedStyle or $.css but both didn't catch auto
    offset.left = offset.left - $('#wrapper').offset().left;

    // Now check if datepicker is showing outside window viewport - move to a better place if so.
    offset.left -= Math.min( offset.left, ( offset.left + dpWidth > viewWidth && viewWidth > dpWidth ) ?
        Math.abs( offset.left + dpWidth - viewWidth ) : 0 );
    offset.top -= Math.min( offset.top, ( offset.top + dpHeight > viewHeight && viewHeight > dpHeight ) ?
        Math.abs( dpHeight + inputHeight ) : 0 );

    return offset;
  }
});
