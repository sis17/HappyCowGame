$(document).ready(function() {
  $('#menu-round').popover({
    container: 'body',
    placement: 'bottom',
    html: true,
    content: function() {
      return $('#menu-round-content').html();
    }
  });

  $('#menu-score').popover({
    container: 'body',
    placement: 'bottom',
    html: true,
    content: function() {
      return $('#menu-score-content').html();
    }
  });

  $('#menu-player').popover({
    container: 'body',
    placement: 'bottom',
    html: true,
    content: function() {
      return $('#menu-player-content').html();
    }
  });

  $('.ration-popover').popover({
    container: 'body',
    placement: 'bottom',
    html: true,
    content: function() {
      return $(this).next().html();
    }
  });
});
