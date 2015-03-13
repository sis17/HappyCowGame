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
