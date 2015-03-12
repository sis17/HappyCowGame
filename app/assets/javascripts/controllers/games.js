var welcomeCtrl = hcApp.controller('GamesCtrl', [
  '$scope', '$location', 'Restangular',
  function($scope, $location, Restangular) {
    $scope.game_users = Restangular.one('users', $scope.$storage.user.id).getList('game_users');

    $scope.selectGame = function(game_user) {
      Restangular.one('games', game_user.game.id).get().then(function(game) {
        $scope.$storage.user.game_user = game_user;
        $scope.game = game;
      }, function() {
        $scope.alert('Game Not Found', 'Sorry about this, but we can\'t find that game.', 'danger', 2);
      });
    }

    $scope.unselectGame = function() {
      $scope.$storage.user.game_user = null;
      $scope.game = null;
      $scope.$storage.game = null;
    }

    $scope.abandon = function(game_id) {
      Restangular.one('games', game_id).remove().then(function(response) {
        $scope.game_users = Restangular.one('users', $scope.$storage.user.id).getList('game_users');
        $scope.unselectGame();
        $scope.alert(response.message.title, response.message.text, response.message.type, 2);
      }, function() {
        $scope.alert('Game Not Removed', 'The game could not be removed, it still exists.', 'warning', 2);
      });
    }

    $scope.leave = function() {
      game_user_id = $scope.$storage.user.game_user.id;
      Restangular.one('game_users', game_user_id).remove().then(function(response) {
        $scope.game_users = Restangular.one('users', $scope.$storage.user.id).getList('game_users');
        $scope.unselectGame();
        $scope.alert(response.message.title, response.message.text, response.message.type, 2);
      }, function() {
        $scope.alert('Leaving Failed', 'You cannot currently leave this game.', 'warning', 2);
      });
    }

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
        $scope.alert(response.message.title, response.message.text, response.message.type, 2);
        if (response.success) {
          $location.path('games/new/'+response.game.id);
        }
      }, function() {
        $scope.alert('Initalisation Failed', 'An error occured and the game could not be initialised.', 'warning', 2);
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
