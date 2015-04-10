var baseCtrl = angular.module('happyCow').controller('BaseCtrl', [
  '$scope', '$sce', '$location', 'Restangular', '$localStorage', 'notice', '$modal',
  function($scope, $sce, $location, Restangular, $localStorage, notice, $modal) {
    $scope.$storage = $localStorage;
    if (!$scope.$storage.user) {
      $location.path('login');
    }

    $scope.user = {
      data: null,
      assign: function(userData) {
        $scope.$storage.user = userData;
      },
      logout: function() {
        $scope.$storage.user = null;
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

var welcomeCtrl = hcApp.controller('WelcomeCtrl', [
  '$scope',
  function($scope) {

  }
]);
