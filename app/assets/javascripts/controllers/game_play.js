var gameCtrl = hcApp.controller('GameCtrl', [
  '$scope', '$sce', '$location', 'Restangular',
  function($scope, $sce, $location, Restangular) {

    $scope.game = $scope.$storage.game;
    $scope.phaseTemplate = 'templates/phase/'+$scope.game.round.current_phase+'.html';

    $scope.user.getCards = function() {
      this.cards = Restangular.one('games', $scope.game.id).one('game_users', $scope.$storage.user.game_user.id)
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
      return Restangular.one('users', $scope.game.id).one('game_users', $scope.$storage.user.game_user.id)
              .getList('rations');
    }

    $scope.user.createRation = function(ingredients) {
      var ration = {game_user_id: $scope.$storage.user.game_user.id, ingredients: ingredients};
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

      Restangular.all('rounds').post({round_id: $scope.game.round.id, game_user_id: $scope.$storage.user.id, complete: true})
       .then(function(response) {
        $scope.alert(response.message.title, response.message.message, response.message.type, 2);
        if (response.success) {
          $scope.game.round = response.round;
          $scope.changePhaseTemplate(game.round.current_phase);
        }
      }, function() {
        $scope.alert('Action Not Saved', 'An error occured and the turn could not be finished.', 'danger', 2);
      });
    }

    $scope.game.nextPhase = function(phaseNum) {
      if (phaseNum) {
        if (phaseNum == $scope.game.round.current_phase + 1) {
          Restangular.all('rounds').post({round_id: $scope.game.round.id, game_user_id: $scope.$storage.user.id, phase_complete: true})
           .then(function(response) {
            $scope.alert(response.message.title, response.message.message, response.message.type, 2);
              if (response.success) {
                $scope.game.round = response.round;
                $scope.changePhaseTemplate(game.round.current_phase);
              }
          }, function() {
            $scope.alert('Action Not Saved', 'An error occured and the turn could not be finished.', 'danger', 2);
          });
        }
      }
    }

    $scope.game.checkPhase = function(phaseNum) {
      return $scope.game.round.current_phase == phaseNum;
    }

    $scope.game.checkTurn = function() {
      return $scope.game.round.game_user_id == $scope.$storage.user.game_user.id;
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
