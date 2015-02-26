var gameCtrl = hcApp.controller('GameCtrl', [
  '$scope', '$sce', 'Game', 'Round', 'User', 'Restangular',
  function($scope, $sce, Game, Round, User, Restangular) {
    $scope.ingredientDescription = function(type) {
      switch (type) {
        case 'water':
          return '+1 movement dice. Lowers PH in the Rumen if it exceeds energy.';
        case 'energy':
          return 'Raises PH in the Rumen if it exceeds water. Scores high as milk.';
        case 'fiber':
          return 'Allows pushing of rations with less fiber.';
        case 'protein':
          return 'Scores adequately as milk, and best as meat.';
        case 'oligos':
          return 'A special health booster. Scores very well the first time absorbed.';
        default:
          return '';
      }
    };

    $scope.phaseTemplate = 'templates/phase/3.html';
    $scope.game = Restangular.one('games', 1).get().$object;
    //$scope.users = User.query();

    $scope.getCurrentUser = function() {
      if ($scope.game.round.game_user) {
        return $scope.game.round.game_user
      }
      return null;
    }

    $scope.nextPhase = function(phaseNum) {
      if (phaseNum) {
        if (phaseNum == $scope.game.round.current_phase + 1) {
          $scope.game.round.current_phase++;
        } else if (phaseNum == 1 && $scope.game.round.current_phase == 4) {
          // increase the round
          // do a post and get
          //$scope.round = Round.get({id: $scope.round.id+1});
        }

        $scope.changePhaseTemplate($scope.game.round.current_phase);
      }
    }

    $scope.nextTurn = function() {
      $scope.game.round_id++;
      $scope.game.patch().then(function (move) {
        $scope.game = game;
      }, function() {
        console.log("There was an error saving");
      });
      $scope.changePhaseTemplate($scope.game.round.current_phase);
    }

    $scope.checkPhase = function(phaseNum) {
      return $scope.game.round.current_phase == phaseNum;
    }

    $scope.changePhaseTemplate = function(num) {
      console.log('loaded template: templates/phase/'+num+'.html');
      $scope.phaseTemplate = 'templates/phase/'+num+'.html';
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
