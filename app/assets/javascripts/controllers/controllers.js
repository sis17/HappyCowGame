var baseCtrl = hcApp.controller('BaseCtrl', [
  '$scope', '$sce', '$location', 'Restangular', '$localStorage',
  function($scope, $sce, $location, Restangular, $localStorage) {
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

    $scope.alerts = [];
    $scope.alert = function(title, message, type, stick) {
      $scope.alerts.push({
        number: $scope.alerts.length,
        msg: '<strong>'+title+'</strong> '+message,
        type: type
      });
      console.log($scope.alerts);
    }
    $scope.closeAlert = function(index) {
      $scope.alerts.splice(index, 1);
      console.log($scope.alerts);
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
