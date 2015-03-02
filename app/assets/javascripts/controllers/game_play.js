var gameCtrl = hcApp.controller('GameCtrl', [
  '$scope', '$sce', '$location', 'Restangular',
  function($scope, $sce, $location, Restangular) {

    $scope.game = $scope.$storage.game;
    $scope.phaseTemplate = 'templates/phase/'+$scope.game.round.current_phase+'.html';

    $scope.user.getCards = function() {
      return Restangular.one('games', $scope.game.id).one('game_users', $scope.$storage.user.game_user.id)
              .getList('cards');
    }

    $scope.user.getRations = function() {
      return Restangular.one('users', $scope.game.id).one('game_users', $scope.$storage.user.game_user.id)
              .getList('rations');
    }

    $scope.user.createRation = function(ingredients) {
      var ration = {game_user_id: $scope.$storage.user.id, ingredients: ingredients};
      Restangular.all('rations').post({ration: ration, game_id: $scope.game.id}).then(function(response) {
        $scope.alert(response.message.title, response.message.message, response.message.type, 2);
        $scope.cards = $scope.user.getCards();
        $scope.game.round.ration_created = true;
      }, function() {
        $scope.alert('Ration Not Created', 'An error occured and the ration was not created.', 'danger', 2);
      });
    }

    $scope.game.nextTurn = function() {
      this.round_id++;
      this.patch().then(function(game) {
        $scope.game.round = game.round;
        // eventually have to put a waiting bit in, depends on all users finishing
        $scope.changePhaseTemplate(game.round.current_phase);
      }, function() {
        console.log("There was an error moving to the next round");
      });
    }

    $scope.game.nextPhase = function(phaseNum) {
      if (phaseNum) {
        if (phaseNum == $scope.game.round.current_phase + 1) {
          console.log(this.round);
          $scope.game.round.current_phase++;
          console.log($scope.game.round)
          $scope.game.round.patch().then(function(round) {
            $scope.game.round = game.round;
            $scope.changePhaseTemplate($scope.game.round.current_phase);
          }, function() {
            console.log("There was an error updating the round phase.");
          });
        }
      }
    }

    $scope.game.checkPhase = function(phaseNum) {
      return $scope.game.round.current_phase == phaseNum;
    }

    $scope.changePhaseTemplate = function(num) {
      if (!isNaN(num)) {
        console.log('loaded template: templates/phase/'+num+'.html');
        $scope.phaseTemplate = 'templates/phase/'+num+'.html';
      }
    }

    return $scope;
  }
]);

var phaseCtrl = angular.module('happyCow').controller('PhaseCtrl', [
  '$scope',
  function($scope) {
    return $scope;
  }
]);
