$(document).on('change', '.anchor-model-js', function () {
  let url = $(this).data('relation-fields-path');
  let selectedModel = $(this).find(":selected").val();

  $.ajax({
    url: url,
    data: { selected_model: selectedModel }
  });
});
