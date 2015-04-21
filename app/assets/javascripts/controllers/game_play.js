angular.module('happyCow').controller('GameCtrl', [
  '$scope', '$sce', '$location', 'Restangular', '$routeParams', '$timeout', 'notice', '$modal',
  function($scope, $sce, $location, Restangular, $routeParams, $timeout, notice, $modal) {

    if (!$scope.groupPlayers) {
      $scope.groupPlayers = $scope.$storage.groupUsers; // for now
    }
    var getGroupPlayer = function(user_id) {
      var groupPlayer = null;
      for (i in $scope.groupPlayers) {
        if ($scope.groupPlayers[i].id && $scope.groupPlayers[i].key && $scope.groupPlayers[i].id == user_id) {
          return $scope.groupPlayers[i];
        }
      }
      if (!groupPlayer) {
        // the player does not exist, to add them, they must authenticate themselves
        notice('No Authentication', 'You are not logged into this game, please try logging in again.', 'warning', 6);
      }
    }

    $scope.player = {};
    $scope.$storage.player = $scope.user.data;
    $scope.player.change = function(user, game_user) {
      user.game_user = game_user;
      $scope.$storage.player = user;
      // set the headers for authentication
      $scope.setAuthHeaders(user.id, user.key);
      // load the correct data for the user
      console.log('changing user to '+user.name);
      this.getCards();
      this.getRations();
      this.getMoves();
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
          if (move && move.game_user_id == $scope.$storage.player.game_user.id && move.round_id == $scope.game.round.id) {
            $scope.player.move = move;
          }
        }
      });
    }

    $scope.player.getCards = function() {
      // update the user's cards
      this.cards = Restangular.one('games', $routeParams.gameId).one('game_users', $scope.$storage.player.game_user.id)
              .getList('cards').$object;
    }

    $scope.player.countCards = function() {
      if (!this.cards) {
        return '';
      }
      return this.cards.length;
    }

    $scope.player.getRations = function() {
      // update the user's rations
      this.rations = Restangular.one('users', $routeParams.gameId).one('game_users', $scope.$storage.player.game_user.id)
              .getList('rations').$object;
    }

    $scope.player.createRation = function(ingredients) {
      var ration = {game_user_id: $scope.$storage.player.game_user.id, ingredients: ingredients};
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
    $scope.phaseTemplate = 'templates/phase/'+game.round.current_phase+'.html';
    $scope.nextPlayer = $scope.game.game_users[1];

    $scope.game.isGroupGame = function() {
      return !this.creater_id;
    }

    // load user details
    if ($scope.game.isGroupGame()) {
      // fetch first crowd user, already authenticated
      var user = getGroupPlayer($scope.game.round.game_user.user_id);
      $scope.player.change(user, $scope.game.round.game_user);
    } else {
      $scope.player.change($scope.$storage.user, $scope.$storage.user.game_user);
    }

    $scope.game.update = function() {
      if ($scope.game.round) {
        var current_game_user = $scope.game.round.game_user;
        var current_game_stage = $scope.game.stage;
        Restangular.one('game_users', $scope.$storage.player.game_user.id).get().then(function(game_user) {
          $scope.$storage.player.game_user = game_user;
        });
        Restangular.one('games', $routeParams.gameId).get().then(function(game) {
          $scope.game.cow = game.cow;
          $scope.game.round = game.round;
          $scope.game.rounds = game.rounds;
          $scope.game.motiles = game.motiles;
          $scope.game.stage = game.stage;
          $scope.game.ingredient_cats = game.ingredient_cats;

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
        game_user_id: $scope.$storage.player.game_user.id,
        done_turn: true
      }).then(function(response) {
        notice(response.messages);
        if (response.success) {
          $scope.finishingTurn = false;
              Restangular.one('rounds', response.game.round.id).get().then(function(round) {
                $scope.game.round = round;
                // if a group game, change the active user
                if ($scope.game.isGroupGame()) {
                  var user = getGroupPlayer($scope.game.round.game_user.user_id)
                  $scope.player.change(user, $scope.game.round.game_user);
                  //$scope.player.change($scope.game.round.game_user);
                  //$scope.turnChangeNotice();
                }

                if (roundId != round.id) {
                  // at the start of the phase we want to look at the event
                  if (!$scope.game.isGroupGame()) {
                    $scope.player.getCards();
                    $scope.player.getRations();
                  }
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
      return this.isGroupGame() || this.round.game_user_id == $scope.player.getGameUserId();
    }

    $scope.rounds = $scope.game.getCurrentRounds();

    // Function to replicate setInterval using $timeout service.
    $scope.intervalFunction = function(){
      $timeout(function() {
        $scope.game.update();
        $scope.intervalFunction();
      }, 5000)
    };

    // Kick off the interval
    $scope.intervalFunction();
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
