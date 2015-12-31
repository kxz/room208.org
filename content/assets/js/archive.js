(function () {
  $('.abbreviated').each(function () {
    var article = this, $article = $(this);
    var inview = new Waypoint.Inview({
      element: article,
      enter: function () {
        $article.load(
          $article.find('a').attr('href') + ' article',
          function () {
            $(this).replaceWith($(this).find('article'));
            Waypoint.refreshAll();
          }
        );
        inview.destroy();
      }
    })
  });
}());
