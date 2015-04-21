var loginCtrl = hcApp.controller('LoginCtrl', [
  '$scope', '$location', 'Restangular', 'notice',
  function($scope, $location, Restangular, notice) {
    if (!$scope.user) {
      $scope.user = {};
    }

    $scope.login = function(user) {
      Restangular.service('login').post({email: user.email, password: user.password}).then(function (response) {
        notice(response.messages)
        if (response.success) {
          response.user.key = response.key;
          $scope.user.assign(response.user);
          $location.path('games');
        }
      }, function() {
        notice('Uh Oh', 'The request could not be completed.', 'warning', 4);
      });
    }
  }
]);

var registerCtrl = hcApp.controller('RegisterCtrl', [
  '$scope', '$location', 'Restangular', 'notice',
  function($scope, $location, Restangular, notice) {
    if (!$scope.user) {
      $scope.user = {};
    }

    $scope.register = function(user) {
      if (!user.email || user.email.length < 1) {
        notice('Email is Required', 'Please provide an email to register.', 'warning', 4);
      } else if (!user.name || user.name.length < 1) {
        notice('Name is Required', 'Please provide a name to register.', 'warning', 4);
      } else if (!user.password || user.password.length < 1) {
        notice('Password is Required', 'Please provide a password to register.', 'warning', 4);
      } else if (user.password != user.password_conf) {
        notice('Oops', 'Please make sure your password and confirmation password match.', 'warning', 4);
      } else {
        Restangular.all('users').post({user:user}).then(function(response) {
          notice(response.messages);
          if (response.success && response.user) {
            response.user.key = response.key;
            $scope.user.assign(response.user);
            $location.path('games');
          }
        }, function() {
          notice('Uh Oh', 'An error occured. Registration could not be completed.', 'warning', 4);
        });
      }
    }
  }
]);
