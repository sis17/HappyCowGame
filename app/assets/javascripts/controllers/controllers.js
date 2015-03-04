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
      }
    };

    $scope.alerts = [];
    $scope.alert = function(title, message, type, stick) {
      $scope.alerts.push({number: $scope.alerts.length, title: title, message: message, type: type, stick: stick});
    }
    $scope.clearAlert = function(id) {
      if (id > -1) {
        $scope.alerts.splice(id, 1);
      }
    }

    $scope.debug = function() {
      return $scope.user.get();
    }

  }
]);

var welcomeCtrl = hcApp.controller('WelcomeCtrl', [
  '$scope',
  function($scope) {

  }
]);
