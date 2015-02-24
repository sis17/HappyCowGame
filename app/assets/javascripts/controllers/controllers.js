var gameCtrl = hcApp.controller('GameCtrl', [
  '$scope', '$sce', 'Round', 'User',
  function($scope, $sce, Round, User) {
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

    $scope.users = User.query();

    $scope.round = Round.get({id: 4});
    $scope.phase = 1;

    $scope.nextPhase = function() {
      if ($scope.phase <= 3) {
        $scope.phase++;
      } else {
        $scope.round = Round.get({id: $scope.round.id+1});
        $scope.phase = 1;
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
