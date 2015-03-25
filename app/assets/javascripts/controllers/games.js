var welcomeCtrl = hcApp.controller('GamesCtrl', [
  '$scope', '$location', 'Restangular', 'notice', '$modal',
  function($scope, $location, Restangular, notice, $modal) {
    $scope.game_users = Restangular.one('users', $scope.$storage.user.id).getList('game_users');

    $scope.selectGame = function(game_user) {
      if (game_user.game && game_user.game.id) {
        Restangular.one('games', game_user.game.id).get().then(function(game) {
          $scope.$storage.user.game_user = game_user;
          $scope.game = game;
        }, function() {
          notice('Game Not Found', 'Sorry about this, but we can\'t find that game.', 'danger', 2);
        });
      } else {
        notice('No Game Exists', 'Sorry, we can\'t find your game for you, it may have been deleted', 'warning', 0);
      }
    }

    $scope.unselectGame = function() {
      $scope.$storage.user.game_user = null;
      $scope.game = null;
    }

    $scope.abandon = function(game_id) {
      Restangular.one('games', game_id).remove().then(function(response) {
        $scope.game_users = Restangular.one('users', $scope.$storage.user.id).getList('game_users');
        $scope.unselectGame();
        notice(response.messages);
      }, function() {
        notice('Game Not Removed', 'The game could not be removed, it still exists.', 'warning', 2);
      });
    }

    $scope.leave = function () {
      var modalInstance = $modal.open({
        templateUrl: 'leaveGame.html',
        controller: 'LeaveGameCtrl',
        resolve: {
          game: function () {
            return $scope.game;
          }
        }
      });

      modalInstance.result.then(function (game) {
        game_user_id = $scope.$storage.user.game_user.id;
        Restangular.one('game_users', game_user_id).remove().then(function(response) {
          $scope.game_users = Restangular.one('users', $scope.$storage.user.id).getList('game_users');
          $scope.unselectGame();
          notice(response.messages);
        }, function() {
          notice('Leaving Failed', 'You cannot currently leave this game.', 'warning', 2);
        });
      }, function () {
        console.log('Modal dismissed at: ' + new Date());
      });
    };

    $scope.newGame = function() {
      Restangular.all('games').post({
        new: true,
        game: {
          name: '',
          carddeck_id: 1,
          rounds_min: 8,
          rounds_max: 8
        },
        user_id: $scope.$storage.user.id
      }).then(function(response) {
        notice(response.messages);
        if (response.success) {
          $location.path('games/new/'+response.game.id);
        }
      }, function() {
        notice('Initalisation Failed', 'An error occured and the game could not be initialised.', 'warning', 2);
      });
    }

    $scope.countFinished = function() {
      var count = 0;
      for (i in $scope.game_users.$object) {
        if ($scope.game_users.$object[i] && $scope.game_users.$object[i].game && $scope.game_users.$object[i].game.stage > 1) {
          count++;
        }
      }
      return count;
    }

    $scope.countPlaying = function() {
      var count = 0;
      for (i in $scope.game_users.$object) {
        if ($scope.game_users.$object[i] && $scope.game_users.$object[i].game && $scope.game_users.$object[i].game.stage == 1) {
          count++;
        }
      }
      return count;
    }

    $scope.translatePhase = function(phaseNum) {
      switch(phaseNum) {
        case 1:
          return 'Event';
        case 2:
          return 'Cards';
        case 3:
          return 'Movement';
        case 4:
          return 'Review';
      }
    }
  }
]);

angular.module('happyCow').controller('LeaveGameCtrl',
  function (notice, $scope, $modalInstance, game) {
    $scope.game = game;

    $scope.yes = function () {
      $modalInstance.close($scope.game);
    };

    $scope.cancel = function () {
      $modalInstance.dismiss('cancel');
    };
});
