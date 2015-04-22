var gameNewCtrl = hcApp.controller('GameSetupCtrl', [
  '$scope', '$location', 'Restangular', '$routeParams', 'notice', '$modal',
  function($scope, $location, Restangular, $routeParams, notice, $modal) {
    // set user as logged in
    $scope.setAuthHeaders($scope.$storage.user.id, $scope.$storage.user.key);

    // get the game
    Restangular.one('games', $routeParams.gameId).get().then(function(game) {
      // set the logged in user's game user
      $scope.$storage.user.game_user = game.game_users[0];
      $scope.game = game;
      // set the logged in user as automatically authenticated
      $scope.$storage.auth_games[game.id] = {};
      $scope.auth_games.logIn(game.id, $scope.$storage.user);
    }, function(response) {
      $scope.failedGet(response);
    });

    // get list of users for invites
    $scope.users = [];
    Restangular.all("users").getList().then(function(users) {
      $scope.users = users;
    }, function(response) {
      $scope.failedGet(response);
    });

    // get list of carddecks to choose from
    $scope.decks = [];
    Restangular.all("carddecks").getList().then(function(decks) {
      $scope.decks = decks;
    }, function(response) {
      $scope.failedGet(response);
    });

    $scope.create = function() {
      $scope.created = true;
      $scope.game.patch({begin:true}).then(function(response) {
        if (response.success) {
          $scope.game = response.game;
          $scope.begin();
        } else {
          $scope.created = false;
          notice('Creation Failed', 'An error occured and the game could not be created fully.', 'warning', 2);
        }
      }, function(response) {
        $scope.failedGet(response);
      });
    }
    $scope.begin = function() {
      // check everyone is logged in
      var all_assigned = true;
      console.log($scope.$storage.auth_games[$scope.game.id]);
      for (i in $scope.game.game_users) {
        var game_user = $scope.game.game_users[i];
        if (!game_user.network) {
          if (!$scope.auth_games.loggedIn($scope.game.id, game_user.user.id)) {
            console.log(game_user.user);
            all_assigned = false;
          }
        }
      }

      if (all_assigned) {
        $location.path('games/play/'+$scope.game.id);
      } else {
        notice('Players Not Logged In', 'All players either need to be set as distant (playing on another machine), or logged in.', 'warning', 6);
      }
    }

    $scope.saveName = function(name) {
      $scope.game.patch({name: name}).then(function(response) {
      }, function() {
        notice('Name Not Saved', 'The game name was not updated.', 'warning', 2);
      });
    }

    $scope.abandon = function() {
      Restangular.one('games', $scope.game.id).remove().then(function(response) {
        notice(response.messages);
        $location.path('games');
      }, function(response) {
        notice('Game Not Removed', 'The game was not removed, it still exists.', 'warning', 2);
        $scope.failedUpdate(response);
      });
    }
    $scope.leave = function() {
      game_user_id = $scope.$storage.user.game_user.id;
      Restangular.one('game_users', game_user_id).remove().then(function(response) {
        notice(response.messages);
        $location.path('games');
      }, function(response) {
        notice('Leaving Failed', 'You cannot currently leave this game.', 'warning', 2);
        $scope.failedUpdate(response);
      });
    }

    $scope.selectUser = function($item, $model, $label) {
      $scope.selectedUser = $item;
    }
    $scope.unselectUser = function() {
      $scope.selectedUser = null;
    }

    $scope.inviteUser = function(user) {
      //user = $scope.selectedUser;
      $scope.game.patch({users:[user.id]}).then(function(response) {
        if (response.success) {
          $scope.selectedUser = null;
          $scope.getGame();
          notice(response.messages);
        } else {
          notice('Invitation Failed', 'The player has NOT been added to this game.', 'warning', 2);
        }
      }, function(response) {
        notice('Invitation Failed', 'The player has NOT been added to this game.', 'warning', 2);
        $scope.failedUpdate(response);
      });
    }
    $scope.availableUsers = function() {
      users = []
      for (i in $scope.users) {
        user = $scope.users[i]
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

    $scope.setNetwork = function(game_user, on) {
      Restangular.one('game_users', game_user.id).patch({network:( on ? 1 : 0 )}).then(function(response) {
        if (response.success) {
          game_user.network = response.game_user.network;
        }
      }, function(response) {
        $scope.failedUpdate(response);
      });
    }

    $scope.login = function(game_user) {
      if ($scope.auth_games.loggedIn($scope.game.id, game_user.user.id)) {
        notice('Already Logged In', user.name+' is already logged in.', 'info', 4);
        return;
      }
      var user = game_user.user;
      var modalInstance = $modal.open({
          templateUrl: 'loginUser.html',
          controller: 'LoginUserCtrl',
          resolve: {
            user: function () {
              return user;
            }
          }
      });

      modalInstance.result.then(function (user) {
        console.log(user);
        $scope.auth_games.logIn($scope.game.id, user);// = user.key; // set the auth memory
      }, function () {
        console.log('Modal dismissed at: ' + new Date());
      });
    }
    $scope.logout = function(game_user) {
      if ($scope.auth_games.loggedIn($scope.game.id, game_user.user.id)) {
        $scope.auth_games.logOut($scope.game.id, game_user.user.id);
        notice('Logged Out', game_user.user.name+' has been logged out.', 'info', 4);
      } else {
        notice('Not Logged In', game_user.user.name+' is not logged in.', 'warning', 4);
      }
    }

    $scope.createUser = function() {
      var modalInstance = $modal.open({
          templateUrl: 'register.html',
          controller: 'RegisterCtrl',
          resolve: {}
      });

      modalInstance.result.then(function (user) {
        console.log(user);
        $scope.selectedUser = user;
        $scope.inviteUser(user);
        $scope.auth_games.logIn($scope.game.id, user); // set the auth memory
      }, function () {
        console.log('Modal dismissed at: ' + new Date());
      });
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

    $scope.setup = function() {
      return ($scope.game && $scope.game.stage == 0 && $scope.user.isCreator($scope.game));
    }

    $scope.getGame = function() {
      Restangular.one('games', $scope.game.id).get().then(function(game) {
        $scope.game = game;
      }, function(response) {
        $scope.failedGet(response);
      });
    }
  }
]);
