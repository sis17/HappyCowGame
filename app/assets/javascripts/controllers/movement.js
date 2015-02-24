var phaseCtrl = angular.module('happyCow').controller('MovementCtrl', [
  '$scope', '$location', 'Ration',
  function($scope, $location, Ration) {
    // bar controls
    $scope.movePhase = 1;
    $scope.rations = Ration.query();
    $scope.selectedRation = null;

    $scope.getDice = function(ration) {
      $scope.movePhase = 2;
      $scope.dices = [
        {type: 'default', value: '2', selected: true},
        {type: 'default', value: '6', selected: true}
      ];

      if (ration.hasWater()) {
        $scope.dices.push({type: 'water', value: '3', selected: true});
      }
    }

    $scope.selectRation = function(ration) {
      for (i in $scope.rations) {
        $scope.rations[i].selected = false;
      }
      // move to the ration
      $scope.top = 50 + 100 - ration.position.centre_y;
      $scope.left = 20 + 100 - ration.position.centre_x;

      ration.selected = true;
      $scope.selectedRation = ration;
    }

    $scope.selectDice = function(dice) {
      for (i in $scope.dices) {
        $scope.dices[i].selected = false;
      }
      dice.selected = true;
      $scope.selectedDice = dice;

      $scope.positions = [
        {
          id: 24, order:24, centre_x: 350, centre_y: 325, area_id: 2,
          positions: [
            {id: 25, order:25, centre_x: 350, centre_y: 300, area_id: 2, positions: []}
          ]
        }
      ];
    };

    $scope.moveRation = function(ration, newPos) {
      ration.position.centre_x = newPos.centre_x;
      ration.position.centre_y = newPos.centre_y;

      // test for the end of the phase
      console.log(newPos);
      if (newPos.positions.length <= 0) {
        // moving to last phase
        console.log('changing to phase 4');
        $location.path('/phase/review');
        $scope.nextPhase();
      }

      // update the possible positions
      $scope.positions = newPos.positions;
    }

    // movement controls
    $scope.width = 800;
    $scope.left = 20;
    $scope.top = 50;

    $scope.zoomIn = function() {
      $scope.width += 50;
      $scope.left -= 25;
    }
    $scope.zoomOut = function() {
      $scope.width -= 50;
      $scope.left += 25;
    }
    $scope.moveLeft = function() {
      $scope.left -= 25;
    }
    $scope.moveRight = function() {
      $scope.left += 25;
    }
    $scope.moveUp = function() {
      $scope.top += 25;
    }
    $scope.moveDown = function() {
      $scope.top -= 25;
    }
  }
]);
