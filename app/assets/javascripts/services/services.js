var services = angular.module('happyCowServices', ['ngResource']);

services.factory('notice', ['$timeout', '$document', function($timeout, $document) {
  var notices = $('#notices');
  return function(title, message, type, stick) {
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
        notices.find('#alert-'+number).remove();
      }, (stick)*1000);
    }
  };
      /*if (!$localStorage.alerts) {
        $localStorage.alerts = [];
      }
      var index = $localStorage.alerts.push({
        number: $scope.alerts.length,
        msg: '<strong>'+title+'</strong> '+message,
        type: type
      }) - 1;
      // clear the alert after a number of seconds
      if (stick > 0) {
        $timeout(function() {
          $scope.closeAlert(index);
        }, (stick)*1000);
      }
    },
    get: function() {
      return $localStorage.alerts
    },
    close: function(index) {
      $localStorage.alerts.splice(index, 1);
    }
  };*/
 }]);
