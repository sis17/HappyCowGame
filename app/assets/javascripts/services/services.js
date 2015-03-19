var services = angular.module('happyCowServices', ['ngResource']);

services.factory('notice', ['$timeout', '$document', function($timeout, $document) {
  var notices = $('#notices');
  return function(title, message, type, stick) {
    if( Object.prototype.toString.call( title ) === '[object Array]' ) {
      for (i in title) {
        message = title[i];
        var number = parseInt(notices.data('number'));
        notices.data('number',++number);
        notices.prepend(
          '<div id="alert-'+(number)+'" class="alert alert-'+message.type+' alert-dismissible" role="alert">'+
            '<button type="button" class="close" data-dismiss="alert" aria-label="Close">'+
              '<span aria-hidden="true">&times;</span></button>'+
              '<strong>'+message.title+'</strong> '+message.text+
          '</div>'
        );

        var time = message.time;
        if (stick > 0) {
          $timeout(function() {
            notices.find('#alert-'+number).fadeOut().remove();
          }, (time)*1000);
        }
      }
    } else {
      var number = parseInt(notices.data('number'));
      notices.data('number',++number);
      var msg = '<strong>'+title+'</strong> '+message;
      notices.prepend(
        '<div id="alert-'+(number)+'" class="alert alert-'+type+' alert-dismissible" role="alert">'+
          '<button type="button" class="close" data-dismiss="alert" aria-label="Close">'+
            '<span aria-hidden="true">&times;</span></button>'+msg+
        '</div>'
      );

      if (stick > 0) {
        $timeout(function() {
          console.log('removing alert number '+number);
          notices.find('#alert-'+number).fadeOut().remove();
        }, (stick)*1000);
      }
    }
    /*var number = parseInt(notices.data('number'));
    notices.data('number',++number);
    var msg = '<strong>'+title+'</strong> '+message;
    notices.prepend(
      '<div id="alert-'+(number)+'" class="alert alert-'+type+' alert-dismissible" role="alert">'+
        '<button type="button" class="close" data-dismiss="alert" aria-label="Close">'+
          '<span aria-hidden="true">&times;</span></button>'+msg+
      '</div>'
    );

    if (stick > 0) {
      $timeout(function() {
        console.log('removing alert number '+number);
        notices.find('#alert-'+number).fadeOut().remove();
      }, (stick)*1000);
    }*/
  };
}]);
