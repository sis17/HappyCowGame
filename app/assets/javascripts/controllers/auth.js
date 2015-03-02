var loginCtrl = hcApp.controller('LoginCtrl', [
  '$scope', '$location', 'Restangular',
  function($scope, $location, Restangular) {
    if (!$scope.user) {
      $scope.user = {};
    }

    $scope.login = function(user) {
      Restangular.service('login').post({email: user.email, password: user.password}).then(function (response) {
      
        console.log(response);
        if (response.success) {
          $scope.user.assign(response.user);
          $location.path('games')
        } else {
          $scope.message = response.message.text;
        }
      }, function() {
        $scope.message = {title: '', text: "The request could not be completed.", type: 'danger'};
      });
    }
  }
]);

var registerCtrl = hcApp.controller('RegisterCtrl', [
  '$scope',
  function($scope) {

  }
]);
