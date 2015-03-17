var loginCtrl = hcApp.controller('LoginCtrl', [
  '$scope', '$location', 'Restangular', 'notice',
  function($scope, $location, Restangular, notice) {
    if (!$scope.user) {
      $scope.user = {};
    }

    $scope.login = function(user) {
      Restangular.service('login').post({email: user.email, password: user.password}).then(function (response) {

        console.log(response);
        if (response.success) {
          $scope.user.assign(response.user);
          $location.path('games');
        } else {
          notice(response.message.title, response.message.text, response.message.type, 5)
        }
      }, function() {
        notice('Uh Oh', 'The request could not be completed.', 'danger', 4);
      });
    }
  }
]);

var registerCtrl = hcApp.controller('RegisterCtrl', [
  '$scope',
  function($scope) {

  }
]);
