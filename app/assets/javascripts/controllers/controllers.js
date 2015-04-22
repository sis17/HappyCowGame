angular.module('happyCow').controller('BaseCtrl', [
  '$scope', '$sce', '$location', 'Restangular', '$localStorage', 'notice', '$modal', '$http',
  function($scope, $sce, $location, Restangular, $localStorage, notice, $modal, $http) {
    // set the headers for authentication
    $scope.setAuthHeaders = function(id, key) {
      $http.defaults.headers.common.UserId = id;
      $http.defaults.headers.common.UserKey = key;
    }

    $scope.failedGet = function(response) {
      console.log(response);
      if (response.status == 401 && response.statusText.indexOf("Unauthorized") >= 0) {
        notice('Not Authorised', 'Sorry, you are not logged in, please login and try again.', 'warning', 6);
        $location.path('login');
      } else {
        notice('Network Error', 'Sorry, we couldn`t get the information to make this work.', 'danger', 5);
      }
    }
    $scope.failedUpdate = function(response) {
      console.log(response);
      if (response.status == 401 && response.statusText.indexOf("Unauthorized") >= 0) {
        notice('Not Authorised', 'Sorry, you are not logged in, please login and try again.', 'warning', 6);
        $location.path('login');
      } else {
        notice('Network Error', 'Sorry, we couldn`t save that information right now.', 'danger', 5);
      }
    }

    $scope.$storage = $localStorage;
    if (!$scope.$storage.auth_games) {
      $scope.$storage.auth_games = {};
    }

    if (!$scope.$storage.user) {
      $location.path('login');
    } else {
      $scope.setAuthHeaders($scope.$storage.user.id, $scope.$storage.user.key);
    }

    $scope.user = {
      data: null,
      assign: function(userData) {
        $scope.$storage.user = userData;
        // set the headers for authentication
        $scope.setAuthHeaders(userData.id, userData.key);
      },
      logout: function() {
        $scope.$storage.user = null;
        $http.defaults.headers.common.UserId = null;
        $http.defaults.headers.common.UserKey = '';
        notice('Logged Out', 'Your session has been successfully ended.', 'info', 4);
        $location.path('login')
      },
      get: function() {
        return $scope.$storage.user;
      },
      isCreator: function(game) {
        if (game && game.creater_id) {
          return $scope.$storage.user.id == game.creater_id;
        }
        return false;
      }
    };

    $scope.auth_games = {
      logIn: function(game_id, user) {
        if (!$scope.$storage.auth_games[game_id]) {
          $scope.$storage.auth_games[game_id] = {};
        }
        $scope.$storage.auth_games[game_id][user.id] = user;
      },
      all: function(game_id) {
        if (!$scope.$storage.auth_games[game_id]) {
          $scope.$storage.auth_games[game_id] = {};
        }
        return $scope.$storage.auth_games[game_id];
      },
      loggedIn: function(game_id, user_id) {
        return $scope.$storage.auth_games[game_id][user_id]
      },
      logOut: function(game_id, user_id) {
        $scope.$storage.auth_games[game_id][user_id] = null;
      }
    }


    $scope.instructions = function() {
      var modalInstance = $modal.open({
        templateUrl: 'instructions.html',
        controller: 'InstructionsCtrl',
        size: 'lg',
        resolve: {
          user: function () {
            return $scope.user;
          }
        }
      });

      modalInstance.result.then(function () {
        // do nothing
      }, function () {
        $log.info('Modal dismissed at: ' + new Date());
      });
    }

    $scope.debug = function() {
      //return $scope.user.get();
    }

  }
]);
angular.module('happyCow').controller('TurnChangeNoticeCtrl',
  function ($scope, $modalInstance, user) {
    $scope.user = user;

    $scope.cancel = function () {
      $modalInstance.dismiss('cancel');
    };
});
angular.module('happyCow').controller('LoginUserCtrl',
  function (notice, $scope, $modalInstance, Restangular, user) {
    $scope.user = user;

    $scope.login = function () {
      Restangular.service('login').post({email: user.email, password: user.password}).then(function (response) {
        notice(response.messages)
        if (response.success) {
          $scope.user = response.user;
          $scope.user.key = response.key; // add the key to authenticate
          $modalInstance.close($scope.user);
        }
      }, function() {
        notice('Uh Oh', 'The request could not be completed.', 'warning', 4);
      });
    };

    $scope.cancel = function () {
      $modalInstance.dismiss('cancel');
    };
});

angular.module('happyCow').controller('WelcomeCtrl', [
  '$scope',
  function($scope) {

  }
]);
