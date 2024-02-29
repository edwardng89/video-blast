// Originally from https://github.com/bootstrap-ruby/bootstrap-editable-rails
// bootstrap-editable-rails.js.coffee
// Modify parameters of X-editable suitable for Rails.
jQuery(function($) {
  var EditableForm;
  EditableForm = $.fn.editableform.Constructor;
  if (EditableForm.prototype.saveWithUrlHook == null) {
    EditableForm.prototype.saveWithUrlHook = function(value) {
      var originalUrl, resource;
      originalUrl = this.options.url;
      resource = this.options.resource;
      this.options.url = (params) => {
        var obj;
        // TODO: should not send when create new object
        if (typeof originalUrl === 'function') { // user's function
          return originalUrl.call(this.options.scope, params);
        } else if ((originalUrl != null) && this.options.send !== 'never') {
          // send ajax to server and return deferred object
          obj = {};
          obj[params.name] = params.value;
          // support custom inputtypes (eg address)
          if (resource) {
            params[resource] = obj;
          } else {
            params = obj;
          }
          delete params.name;
          delete params.value;
          delete params.pk;
          return $.ajax($.extend({
            url: originalUrl,
            data: params,
            type: 'PUT', // TODO: should be 'POST' when create new object
            dataType: 'json'
          }, this.options.ajaxOptions));
        }
      };
      return this.saveWithoutUrlHook(value);
    };
    EditableForm.prototype.saveWithoutUrlHook = EditableForm.prototype.save;
    return EditableForm.prototype.save = EditableForm.prototype.saveWithUrlHook;
  }
});
