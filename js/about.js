$( document ).ready(function() {
      $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
        $( $(e.relatedTarget).attr('href') ).hide();
        $( $(e.target).attr('href') ).show();
      })
});
