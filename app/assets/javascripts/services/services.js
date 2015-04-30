var services = angular.module('happyCowServices', []);

services.factory('notice', ['$timeout', '$document', function($timeout, $document) {
  var notices = $('#notices');

  // set a time out, when finished it will fade out the notice
  var removeNotice = function(number, seconds) {
    $timeout(function() {
      notices.find('#alert-'+number).fadeOut().remove();
    }, (seconds)*1000);
  }

  // create the HTML for a Bootstrap Alert
  var buildNotice = function(type, message) {
    var number = parseInt(notices.data('number'));
    notices.data('number',++number);

    notices.prepend('<div id="alert-'+number+'" class="alert alert-'+type+' alert-dismissible" role="alert">'+
      '<button type="button" class="close" data-dismiss="alert" aria-label="Close">'+
      '<span aria-hidden="true">&times;</span></button>'+message+'</div>');
    return number;
  }

  return function(title, text, type, time) {
    // create a number of notices, if the first parameter is infact an array
    if( Object.prototype.toString.call( title ) === '[object Array]' ) {
      for (i in title) { // in this case title is actually an array of messages
        message = title[i];
        var number = buildNotice(message.type, '<strong>'+message.title+'</strong> '+message.text);
        removeNotice(number, message.time);
      }

    // create a single notice
    } else {
      var number = buildNotice(type, '<strong>'+title+'</strong> '+text));
      removeNotice(number, time);
    }
  };
}]);
