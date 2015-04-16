var gameNewCtrl = hcApp.controller('GameNewCtrl', [
  '$scope', '$location', 'Restangular', '$routeParams', 'notice',
  function($scope, $location, Restangular, $routeParams, notice) {
    // get the game
    //$scope.game_users = Restangular.one('games', $routeParams.gameId).getList('game_users').$object;
    Restangular.one('games', $routeParams.gameId).get().then(function(game) {
      $scope.$storage.user.game_user = game.game_users[0];
      console.log($scope.$storage.user.game_user);
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
        notice('Creation Failed', 'An error occured and the game could not be created.', 'warning', 2);
      });
    }

    $scope.saveName = function(name) {
      $scope.game.patch({name: name}).then(function(response) {
        //notice(response.messages)
        //if (response.success) {
          //$scope.getGame();
        //}
      }, function() {
        notice('Name Not Saved', 'The game name was not updated.', 'warning', 2);
      });
    }

    $scope.abandon = function() {
      Restangular.one('games', $scope.game.id).remove().then(function(response) {
        notice(response.messages);
        $location.path('games');
      }, function() {
        notice('Game Not Removed', 'The game was not removed, it still exists.', 'warning', 2);
      });
    }
    $scope.leave = function() {
      game_user_id = $scope.$storage.user.game_user.id;
      Restangular.one('game_users', game_user_id).remove().then(function(response) {
        notice(response.messages);
        $location.path('games');
      }, function() {
        notice('Leaving Failed', 'You cannot currently leave this game.', 'warning', 2);
      });
    }

    $scope.selectUser = function($item, $model, $label) {
      $scope.selectedUser = $item;
    }
    $scope.unselectUser = function() {
      $scope.selectedUser = null;
    }

    $scope.inviteUser = function() {
      user = $scope.selectedUser;
      $scope.game.patch({users:[user.id]}).then(function(response) {
        if (response.success) {
          $scope.selectedUser = null;
          $scope.getGame();
          notice(response.messages);
        } else {
          notice('Invitation Failed', 'The player has NOT been added to this game.', 'warning', 2);
        }
      }, function() {
        notice('Invitation Failed', 'The player has NOT been added to this game.', 'warning', 2);
      });
    }
    $scope.availableUsers = function() {
      users = []
      for (i in $scope.users.$object) {
        user = $scope.users.$object[i]
        if (user) {
          canAdd = true
          if (user.id == $scope.$storage.user.id) {
            canAdd = false;
          }
          if ($scope.game.game_users) {
            for (i in $scope.game.game_users) {
              var game_user = $scope.game.game_users[i];
              if (game_user && game_user.user_id && game_user.user_id == user.id) {
                canAdd = false;
              }
            }
          }
          if (canAdd) {
            users.push(user)
          }
        }
      }
      return users;
    }

    $scope.useDeck = function(deck) {
      $scope.game.patch({carddeck_id:deck.id}).then(function(response) {
        if (response.success) {
          $scope.getGame();
          notice(response.messages);
        } else {
          notice('Rounds Not Changed', 'The number of rounds has NOT been changed.', 'warning', 2);
        }
      }, function() {
        notice('Rounds Not Changed', 'The number of rounds has NOT been changed.', 'warning', 2);
      });
    }

    $scope.updateRounds = function() {
      $scope.game.patch({rounds_min:$scope.game.rounds_min, rounds_max:$scope.game.rounds_max}).then(
        function(response) {
          if (response.success) {
            //$scope.getGame();
            //notice(response.messages);
          } else {
            notice('Rounds Not Changed', 'The number of rounds has NOT been changed.', 'warning', 2);
          }
        }, function() {
          notice('Rounds Not Changed', 'The number of rounds has NOT been changed.', 'warning', 2);
      });
    }

    $scope.getGame = function() {
      Restangular.one('games', $scope.game.id).get().then(function(game) {
        $scope.game = game;
      });
    }
  }
]);
