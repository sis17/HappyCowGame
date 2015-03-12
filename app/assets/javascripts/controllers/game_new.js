var gameNewCtrl = hcApp.controller('GameNewCtrl', [
  '$scope', '$location', 'Restangular', '$routeParams',
  function($scope, $location, Restangular, $routeParams) {
    // get the game
    //$scope.game_users = Restangular.one('games', $routeParams.gameId).getList('game_users').$object;
    Restangular.one('games', $routeParams.gameId).get().then(function(game) {
      $scope.game = game;
    });

    // get list of users for invites
    $scope.users = Restangular.all("users").getList();
    // get list of carddecks to choose from
    $scope.decks = Restangular.all("carddecks").getList();

    $scope.create = function() {
      $scope.created = true;
      $scope.game.patch({begin:true}).then(function(response) {
        if (response.success) {
          $location.path('games/play/'+response.game.id);
        }
      }, function() {
        $scope.alert('Creation Failed', 'An error occured and the game could not be created.', 'warning', 2);
      });
    }

    $scope.saveName = function(name) {
      $scope.game.patch({name: name}).then(function(response) {
        if (response.success) {
          $scope.getGame();
          $scope.alert('Name Saved', 'The game name has been updated.', 'success', 2);
        } else {
          $scope.alert('Name Not Saved', 'The game name was not updated.', 'warning', 2);
        }
      }, function() {
        $scope.alert('Name Not Saved', 'The game name was not updated.', 'warning', 2);
      });
    }

    $scope.abandon = function() {
      Restangular.one('games', $scope.game.id).remove().then(function(response) {
        $scope.alert(response.message.title, response.message.text, response.message.type, 2);
        $location.path('games');
      }, function() {
        $scope.alert('Game Not Removed', 'The game was not removed, it still exists.', 'warning', 2);
      });
    }
    $scope.leave = function() {
      game_user_id = $scope.$storage.user.game_user.id;
      Restangular.one('game_users', game_user_id).remove().then(function(response) {
        $scope.alert(response.message.title, response.message.text, response.message.type, 2);
        $location.path('games');
      }, function() {
        $scope.alert('Leaving Failed', 'You cannot currently leave this game.', 'warning', 2);
      });
    }

    $scope.inviteUser = function(user) {
      $scope.game.patch({users:[user.id]}).then(function(response) {
        if (response.success) {
          $scope.getGame();
          //$scope.game_users = Restangular.one('games', response.game.id).getList('game_users').$object;
          $scope.alert('Invitation Success', 'The player has been added to this game.', 'success', 2);
        } else {
          $scope.alert('Invitation Failed', 'The player has NOT been added to this game.', 'warning', 2);
        }
      }, function() {
        $scope.alert('Invitation Failed', 'The player has NOT been added to this game.', 'warning', 2);
      });
    }
    $scope.canInvite = function(user) {
      if (user.id == $scope.$storage.user.id) {
        return false;
      }
      if ($scope.game.game_users) {
        for (i in $scope.game.game_users) {
          var game_user = $scope.game.game_users[i];
          if (game_user && game_user.user_id && game_user.user_id == user.id) {
            return false;
          }
        }
      }
      return true;
    }

    $scope.useDeck = function(deck) {
      $scope.game.patch({carddeck_id:deck.id}).then(function(response) {
        if (response.success) {
          $scope.getGame();
          $scope.alert('Rounds Changed', 'The number of rounds has been changed.', 'success', 2);
        } else {
          $scope.alert('Rounds Not Changed', 'The number of rounds has NOT been changed.', 'warning', 2);
        }
      }, function() {
        $scope.alert('Rounds Not Changed', 'The number of rounds has NOT been changed.', 'warning', 2);
      });
    }

    $scope.updateRounds = function() {
      $scope.game.patch({rounds_min:$scope.game.rounds_min, rounds_max:$scope.game.rounds_max}).then(
        function(response) {
          if (response.success) {
            $scope.getGame();
            $scope.alert('Rounds Changed', 'The number of rounds has been changed.', 'success', 2);
          } else {
            $scope.alert('Rounds Not Changed', 'The number of rounds has NOT been changed.', 'warning', 2);
          }
        }, function() {
          $scope.alert('Rounds Not Changed', 'The number of rounds has NOT been changed.', 'warning', 2);
      });
    }

    $scope.getGame = function() {
      Restangular.one('games', $scope.game.id).get().then(function(game) {
        $scope.game = game;
      });
    }

    $scope.$watch('game.game_users', function() {
      console.log('games_users has changed.');
    });
    $scope.$watchGroup(['game.rounds_min', 'game.rounds_max'], function() {
      console.log('game rounds has changed.');
    });
  }
]);
