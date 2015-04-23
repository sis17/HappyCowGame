angular.module('happyCow').controller('GameCtrl', [
  '$scope', '$sce', '$location', 'Restangular', '$routeParams', '$timeout', 'notice', '$modal',
  function($scope, $sce, $location, Restangular, $routeParams, $timeout, notice, $modal) {

    var loadUser = function(user, game_user) {
      if (!user.key || !user.id) { // check for authentication
        notice('No Authentication', 'You are not logged into this game, please try returning to the game menu and logging in again.', 'warning', 6);
        return;
      }

      console.log('changing user to '+user.name);
      // set the headers for authentication
      $scope.setAuthHeaders(user.id, user.key);

      // set the player data
      user.game_user = game_user;
      $scope.$storage.player = user;

      // load the correct data for the user
      $scope.player.getCards();
      $scope.player.getRations();
      $scope.player.getMoves();
    }

    $scope.player = {};
    $scope.player.rations = [];
    $scope.player.cards = [];
    $scope.$storage.player = {};
    $scope.player.change = function(game_user) {
      if ($scope.$storage.user.game_user.network == 1) { // if the current user is distant
        console.log('the current user is present');
        if (game_user.id == $scope.$storage.user.game_user.id) { // and if it's the current user's turn
          loadUser($scope.$storage.user, game_user);
        } else {
          console.log('the player is distant (but present to the creator), so cannot be authenticated');
        }
      } else { // if the current user is present
        console.log('the current user is present');
        if (game_user.network) { // and the current player is distant
          console.log('the player is distant, so cannot be authenticated');

        } else { // and the current player is present, fetch their details
          var user = $scope.$storage.auth_games[$scope.game.id][game_user.user_id];
          loadUser(user, game_user);
        }
      }

      // if possible, this should be avoided
      if (!$scope.$storage.player.name) { // if no player has been loaded, load the user
        console.log('The current player is distant, load the current user instead.')
        loadUser($scope.$storage.user, $scope.$storage.user.game_user);
      }
    }

    $scope.player.getName = function() {
      if ($scope.$storage.player)
        return $scope.$storage.player.name;
    }
    $scope.player.getId = function() {
      if ($scope.$storage.player)
        return $scope.$storage.player.id;
    }
    $scope.player.getGameUser = function() {
      if ($scope.$storage.player)
        return $scope.$storage.player.game_user;
    }
    $scope.player.getGameUserId = function() {
      if ($scope.$storage.player)
        return $scope.$storage.player.game_user.id;
    }

    /*$scope.turnChangeNotice = function() {
      var modalInstance = $modal.open({
        templateUrl: 'turnChangeNotice.html',
        controller: 'TurnChangeNoticeCtrl',
        size: 'lg',
        resolve: {
          user: function () {
            return $scope.$storage.player;
          }
        }
      });

      modalInstance.result.then(function () {
        // do nothing
      }, function () {
      });
    }*/

    $scope.player.getMoves = function() {
      // update the user's possible moves, picking the one for this round
      Restangular.one('games', $scope.game.id).one('rounds', $scope.game.round.id).getList('moves').then(function(moves) {
        for (i in moves) {
          var move = moves[i];
          if (move && move.game_user_id == $scope.player.getGameUserId() && move.round_id == $scope.game.round.id) {
            $scope.player.move = move;
          }
        }
      });
    }

    $scope.player.getCards = function() {
      // update the user's cards
      Restangular.one('games', $routeParams.gameId).one('game_users', $scope.player.getGameUserId())
              .getList('cards').then(function(cards) {
        $scope.player.cards = cards;
      });
    }

    $scope.player.countCards = function() {
      if (!this.cards) {
        return '';
      }
      return this.cards.length;
    }

    $scope.player.getRations = function() {
      // update the user's rations
      Restangular.one('users', $routeParams.gameId).one('game_users', $scope.player.getGameUserId())
          .getList('rations').then(function(rations) {
        $scope.player.rations = rations;
      });
    }

    $scope.player.createRation = function(ingredients) {
      var ration = {game_user_id: $scope.player.getGameUserId(), ingredients: ingredients};
      Restangular.all('rations').post({ration: ration, game_id: $routeParams.gameId}).then(function(response) {
        notice(response.message.title, response.message.message, response.message.type, 4);
        $scope.cards = $scope.player.getCards();
        if ($scope.game.round)
          $scope.game.round.ration_created = true;
      }, function() {
        notice('Ration Not Created', 'An error occured and the ration was not created.', 'danger', 2);
      });
    }

// initialise game
Restangular.one('games', $routeParams.gameId).get().then(function(game) {
    $scope.game = game;
    $scope.nextPlayer = $scope.game.game_users[1];

    $scope.game.update = function() {
      if ($scope.game.round) {
        var current_game_user = $scope.game.round.game_user;
        var current_game_phase = $scope.game.round.current_phase;
        var current_game_stage = $scope.game.stage;
        //Restangular.one('game_users', $scope.player.getGameUserId()).get().then(function(game_user) {
          //$scope.$storage.player.game_user = game_user;

        //});
        Restangular.one('games', $routeParams.gameId).get().then(function(game) {
          $scope.game.cow = game.cow;
          $scope.game.round = game.round;
          $scope.game.rounds = game.rounds;
          $scope.game.motiles = game.motiles;
          $scope.game.stage = game.stage;
          $scope.game.ingredient_cats = game.ingredient_cats;

          // automatically update the game user if they have changed
          if (current_game_user.id != game.round.game_user_id) {
            $scope.player.change(game.round.game_user);
          }

          // automatically update the phase if it has changed
          if (current_game_phase != game.round.current_phase) {
            $scope.changePhaseTemplate(game.round.current_phase);
          }

          if ($scope.game.stage != game.stage) {
            if ($scope.game.stage == 4) {
              notice('The Cow Died!', 'That`s the end of the game, next time take better care of the cow.', 'danger', 10)
            } else if ($scope.game.stage == 2) {
              notice('The Game is Finished', 'That`s the end of the game.', 'info', 10)
            }
          }
        });
      }
    }

    $scope.game.updateOnDoneTurn = function() {
      // update rations for movement screen
      $scope.game.getAllRations();
    }

    $scope.game.getAllRations = function() {
      Restangular.one('games',$scope.game.id).getList('rations').then(function(rations) {
        $scope.game.allRations = rations;
      });
    }
    $scope.game.getAllRations();

    $scope.game.countIngredientsInArea = function(type, areaId) {
      count = 0;
      for (i in $scope.game.allRations) {
        var ration = $scope.game.allRations[i]
        if (ration && ration.position && ration.position.area_id == areaId) {
          for (j in ration.ingredients) {
            if (ration.ingredients[j].ingredient_cat.name == type) {
              count++;
            }
          }
        }
      }
      return count;
    }

    $scope.game.doneTurn = function() {
      var roundId = $scope.game.round.id;
      $scope.finishingTurn = true;
      return Restangular.one('games', $scope.game.id).patch({
        round_id: $scope.game.round.id,
        game_user_id: $scope.player.getGameUserId(),
        done_turn: true
      }).then(function(response) {
        notice(response.messages);
        if (response.success) {
          $scope.finishingTurn = false;
              Restangular.one('rounds', response.game.round.id).get().then(function(round) {
                $scope.game.round = round;

                // will only change if user is not networked
                $scope.player.change($scope.game.round.game_user);

                if (roundId != round.id) {
                  // at the start of the phase we want to look at the event
                  //$scope.player.getCards();
                  //$scope.player.getRations();

                  $scope.changePhaseTemplate(1);
                } else {
                  $scope.changePhaseTemplate($scope.game.round.current_phase);
                }
              });
        }
        // updates to be done when turns finish
        $scope.game.updateOnDoneTurn();
      }, function() {
        notice('Action Not Saved', 'An error occured and the turn could not be finished.', 'danger', 2);
      });
    }

    $scope.game.getCurrentRounds = function() {
      var rounds = [];
      for(i in $scope.game.rounds) {
        round = $scope.game.rounds[i];
        rounds.push(round);
        if (round.id == $scope.game.round.id) {
          rounds[i].current = true;
          return rounds;
        }
      }
    }

    $scope.game.canAct = function(phaseNum) {
      return this.stage == 1 && this.checkPhase(phaseNum) && this.checkTurn();
    }
    $scope.game.checkPhase = function(phaseNum) {
      return this.round.current_phase == phaseNum;
    }
    $scope.game.checkTurn = function() {
      return this.round.game_user_id == $scope.player.getGameUserId();
    }

    $scope.rounds = $scope.game.getCurrentRounds();

    // Function to replicate setInterval using $timeout service.
    $scope.intervalFunction = function(){
      $timeout(function() {
        $scope.game.update();
        $scope.intervalFunction();
      }, 5000)
    };

    // load user details
    if ($scope.$storage.auth_games[game.id]) {
      var user = $scope.$storage.auth_games[game.id][game.round.game_user.user_id]
      $scope.player.change(game.round.game_user);//$scope.$storage.user, $scope.$storage.user.game_user);

      // Kick off the interval
      $scope.phaseTemplate = 'templates/phase/'+game.round.current_phase+'.html';
      $scope.intervalFunction();
    } else {
      // the game has no authentication, return to game list
      notice('No Authentication', 'Oops, you were not authenticated properly in the game, sorry.', 'warning', 6);
      $location.path('games');
    }
}, function(response) {
  $scope.failedGet(response);
});

    $scope.changePhaseTemplate = function(num) {
      if (!isNaN(num)) {
        console.log('loaded template: templates/phase/'+num+'.html');
        $scope.phaseTemplate = 'templates/phase/'+num+'.html';
      }
    }
  }
]);

var phaseCtrl = angular.module('happyCow').controller('PhaseCtrl', [
  '$scope',
  function($scope) {
    return $scope;
  }
]);
