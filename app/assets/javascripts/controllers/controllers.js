angular.module('happyCow').controller('BaseCtrl', [
  '$scope', '$sce', '$location', 'Restangular', '$localStorage', 'notice', '$modal', '$http',
  function($scope, $sce, $location, Restangular, $localStorage, notice, $modal, $http) {
    // set the headers for authentication
    $scope.setAuthHeaders = function(id, key) {
      $http.defaults.headers.common.UserId = id;
      $http.defaults.headers.common.UserKey = key;
    }

    $scope.$storage = $localStorage;

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

    $scope.groupUsers = {
      add: function(userData) {
        $scope.$storage.groupUsers.push(userData);
        // authorise the first user, so that a game can be created
        if (!$scope.$storage.user && $scope.$storage.groupUsers.length <= 1) {
          $scope.setAuthHeaders(userData.id, userData.key);
        }
      },
      all: function() {
        if (!$scope.$storage.groupUsers) {
          $scope.$storage.groupUsers = [];
        }
        return $scope.$storage.groupUsers;
      },
      get: function(user_id) {
        for (i in $scope.$storage.groupUsers) {
          if (user_id == $scope.$storage.groupUsers[i].id) {
            return $scope.$storage.groupUsers[i]
          }
        }
        return null;
      },
      remove: function(user_id) {
        for (i in $scope.$storage.groupUsers) {
          if (user_id = $scope.$storage.groupUsers[i].id) {
            $scope.$storage.groupUsers.splice(i, 1);
            return true;
          }
        }
        return false;
      },
      logout: function() {
        $scope.$storage.groupUsers = [];
        notice('Logged Out', 'All group users have been logged out.', 'info', 4);
        $location.path('')
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

var welcomeCtrl = hcApp.controller('WelcomeCtrl', [
  '$scope',
  function($scope) {

  }
]);
