$(document).on('opened', '[data-reveal]', function () {
  var settings =  {
    placeholder: 'Search for a group',
    minimumInputLength: 3,
    width: '100%',
    ajax: {
      url: function () {
        return $(this).data('url');
      },
      dataType: 'json',
      quietMillis: 200,
      data: function (term, page) {
        return { q: term };
      },
      results: function (data, page) {
        return {results: data.groups};
      }
    },
    formatSelection: function(group, container) {
      return group.name;
    },
    formatResult: function(group, container) {
        return group.name;
    }
  }

  $('.groups').select2(settings);
  $('.groups.multiple').select2($.extend(settings, {multiple: true}));
});

$(function() {
  $('a[rel~="remove_collaboration"]').on('ajax:success', function(e, data, status, xhr) {
    $(this).closest('tr').remove();
  });
});
