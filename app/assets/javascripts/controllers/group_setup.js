hcApp.controller('GroupSetupCtrl', [
  '$scope', '$location', '$modal', 'Restangular', 'notice', '$routeParams',
  function($scope, $location, $modal, Restangular, notice, $routeParams) {

    $scope.ready = false;

    Restangular.one('games', $routeParams.gameId).get().then(function(game) {
      $scope.game = game;
      $scope.$storage.groupUsers = [];
      $scope.groupUsers.add($scope.$storage.user);
    });

    $scope.login = function(user) {
      if (!$scope.groupUsers.get(user.id)) {
        var modalInstance = $modal.open({
          templateUrl: 'loginGroupUser.html',
          controller: 'LoginGroupUserCtrl',
          resolve: {
            user: function () {
              return user;
            }
          }
        });

        modalInstance.result.then(function (user) {
          user.game_users = [];
          $scope.groupUsers.add(user);
        }, function () {
          console.log('Modal dismissed at: ' + new Date());
        });
      } else {
        notice('Already Logged In', user.name+' is already logged in.', 'info', 4);
      }
    }

    $scope.logout = function(user) {
      var result = $scope.groupUsers.remove(user.id);
      if (result) {
        notice('Logged Out', user.name+' has been logged out, they need to be logged back in before you can resume the game.', 'info', 4);
      } else {
        notice('Already Logged Out', user.name+' was not logged in.', 'warning', 4);
      }
    }

    $scope.resume = function(game) {
      var notLoggedIn = [];
      for (i in $scope.game.game_users) {
        var game_user = $scope.game.game_users[i];
        if (!game_user || !$scope.groupUsers.get(game_user.user.id)) {
          notLoggedIn.push(game_user);
        }
      }

      // resume if all players are authenticated
      if (notLoggedIn.length == 0) {
        $location.path('games/play/'+game.id);
      } else {
        var playerNames = '';
        for (i in notLoggedIn) {
          playerNames += ', '+notLoggedIn[i].user.name
        }
        notice('Not All Logged In', 'You cannot resume until everyone is logged in. The players: '+playerNames+', are not logged in.', 'warning', '8');
      }
    }

  }
]);
