var gameNewCtrl = hcApp.controller('GameNewCtrl', [
  '$scope', '$location', 'Restangular',
  function($scope, $location, Restangular) {

    // if the game id doesn't exist, get the game setup
    if (!$scope.$storage.game || !$scope.$storage.game.id) {
      Restangular.all('games').post({
        new: true,
        game: {
          name: '',
          carddeck_id: 1,
          rounds_min: 8,
          rounds_max: 8
        },
        users: [$scope.$storage.user.id]
      }).then(function(response) {
        if (response.success) {
          $scope.alert('Game Initialised', 'Now simply fill in information to get setup.', 'success', 2);
          Restangular.one('games', response.game.id).get().then(function(game) {
            $scope.$storage.user.game_user = game.game_users[0];
            $scope.$storage.game = game;
            $scope.game = game;
          });
        } else {
          $scope.alert('Initalisation Failed', 'An error occured and the game could not be initialised.', 'warning', 2);
        }
      }, function() {
        $scope.alert('Initalisation Failed', 'An error occured and the game could not be initialised.', 'warning', 2);
      });

    // if the game id exists, just get the game object
    } else {
      Restangular.one('games', $scope.$storage.game.id).get().then(function(game) {
        $scope.$storage.game = game;
        $scope.game = game;
      });
    }

    // get list of users for invites
    $scope.users = Restangular.all("users").getList();
    // get list of carddecks to choose from
    $scope.decks = Restangular.all("carddecks").getList();

    $scope.create = function() {
      var game_id = $scope.game.id;
      $scope.game.patch({begin:true}).then(function(response) {
        if (response.success) {
          Restangular.one('games', game_id).get().then(function(game) {
            $scope.game = game;
            $scope.$storage.game = game;
            $location.path('games/play');
          });
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
      Restangular.one('games', $scope.game.id).remove().then(function() {
        $scope.$storage.game = {};
        $scope.alert('The Game Was Removed', 'The game has been removed.', 'success', 2);
        $location.path('games');
      }, function() {
        $scope.alert('Game Not Removed', 'The game was not removed, it still exists.', 'warning', 2);
      });
    }

    $scope.inviteUser = function(user) {
      $scope.game.patch({users:[user.id]}).then(function(response) {
        if (response.success) {
          $scope.getGame();
          $scope.alert('Invitation Success', 'The player has been added to this game.', 'success', 2);
        } else {
          $scope.alert('Invitation Failed', 'The player has NOT been added to this game.', 'warning', 2);
        }
      }, function() {
        $scope.alert('Invitation Failed', 'The player has NOT been added to this game.', 'warning', 2);
      });
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
        $scope.$storage.game = game;
        $scope.game = game;
      });
    }
  }
]);
