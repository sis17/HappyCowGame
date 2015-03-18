var gameCtrl = hcApp.controller('GameCtrl', [
  '$scope', '$sce', '$location', 'Restangular', '$routeParams', '$timeout', 'notice',
  function($scope, $sce, $location, Restangular, $routeParams, $timeout, notice) {

    $scope.user.getCards = function() {
      this.cards = Restangular.one('games', $routeParams.gameId).one('game_users', $scope.$storage.user.game_user.id)
              .getList('cards');
      return this.cards;
    }

    $scope.user.countCards = function() {
      if (!this.cards) {
        return '';
      }
      return this.cards.$object.length;
    }

    $scope.user.getRations = function() {
      return Restangular.one('users', $routeParams.gameId).one('game_users', $scope.$storage.user.game_user.id)
              .getList('rations');
    }

    $scope.user.createRation = function(ingredients) {
      var ration = {game_user_id: $scope.$storage.user.game_user.id, ingredients: ingredients};
      Restangular.all('rations').post({ration: ration, game_id: $routeParams.gameId}).then(function(response) {
        notice(response.message.title, response.message.message, response.message.type, 4);
        $scope.cards = $scope.user.getCards();
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

    $scope.game.update = function() {
      var current_game_user = $scope.game.round.game_user;
      Restangular.one('game_users', $scope.$storage.user.game_user.id).get().then(function(game_user) {
        $scope.$storage.user.game_user = game_user;
      });
      Restangular.one('games', $routeParams.gameId).get().then(function(game) {
        $scope.game.cow = game.cow;
        $scope.game.round = game.round;
      });
    }

    $scope.game.updateOnDoneTurn = function() {
      // update rations for movement screen
      Restangular.one('games', $scope.game.id).getList('rations').then(function(rations) {
        $scope.allRations = rations;
      });
    }

    $scope.game.doneTurn = function() {
      var roundId = $scope.game.round.id;
      Restangular.one('games', $scope.game.id).patch({
        round_id: $scope.game.round.id,
        game_user_id: $scope.$storage.user.id,
        done_turn: true
      }).then(function(response) {
        notice(response.message.title, response.message.text, response.message.type, 4);
          if (response.success) {
              Restangular.one('rounds', response.round.id).get().then(function(round) {
                $scope.game.round = round;
                if (roundId != round.id) {
                  // at the start of the phase we want to look at the event
                  // update motile peices
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
      return $scope.game.checkPhase(phaseNum) && $scope.game.checkTurn();
    }
    $scope.game.checkPhase = function(phaseNum) {
      return $scope.game.round.current_phase == phaseNum;
    }
    $scope.game.checkTurn = function() {
      return $scope.game.round.game_user_id == $scope.$storage.user.game_user.id;
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
