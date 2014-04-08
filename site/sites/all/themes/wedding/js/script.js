(function($) { Drupal.behaviors.weddingHomepage = {
  attach: function (context) {
    //Change the text in the lang switcher
    $('ul.language-switcher-locale-url li.en a').text('EN');
    $('ul.language-switcher-locale-url li.ru a').text('RU');
    $('#navbar ul.nav li.first a').replaceWith('<a href="#homepage-intro"><i class="icon-home"></li></a>');
    $('#navbar ul.nav li>a').attr('href', function(index, attr) { 
      // workaround for http://drupal.org/node/325533#allow-currentfragment-as-a-menu-path
      return $(this).attr('href').replace(/^.*#/, '#');
    });
    $('body').attr('data-spy','scroll');
    $('#navbar').scrollspy();
    $('#navbar ul.nav li>a').click(function(){
      var link = $(this).attr('href');
    //  alert($(link).offset().top);
      $('body, html').animate( {
          scrollTop: $(link).offset().top
      }, 1200, function() {
        window.location.hash = link;
      });
      return false;
    });
    /*TODO: fix this. Currently, it doesn't work because it leaves one of the navbar items selected*/
    $('.front .brand').click(function(){
        $('body, html').animate( {
            scrollTop: 0
        }, 1200, function() {
          window.location.hash = '';
        });
      return false;
    });
  }
}
})(jQuery);
