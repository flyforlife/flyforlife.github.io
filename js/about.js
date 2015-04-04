$( document ).ready(function() {
      $('a[data-toggle="pill"]').on('shown.bs.tab', function (e) {
        $( $(e.relatedTarget).attr('href') ).hide();
        $( $(e.target).attr('href') ).show();
      })
});
