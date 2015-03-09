var phaseCtrl = angular.module('happyCow').controller('MovementCtrl', [
  '$scope', '$location', 'Restangular',
  function($scope, $location, Restangular) {

    $scope.getMoves = function() {
      var moves = Restangular.one('games', $scope.game.id)
                    .one('rounds', $scope.game.round.id).getList('moves').then(function(moves) {
        var currentUser = $scope.$storage.user.game_user;
        for (i in moves) {
          var move = moves[i];
          if (move && move.game_user_id == currentUser.id) {
            $scope.move = moves[i];
          }
        }
      });
    }

    // bar controls
    $scope.movePhase = 1;
    $scope.rations = Restangular.one('games', $scope.game.id)
                      .one('game_users', $scope.$storage.user.game_user.id).getList('rations').$object;
    $scope.selectedRation = null;
    $scope.getMoves();

    $scope.confirmRation = function(ration) {
      $scope.move.ration_id = ration.id;
      $scope.move.patch({confirm_ration:true, ration_id:ration.id}).then(function (response) {
        if (response.move) {
          $scope.move = Restangular.one('moves', $scope.move.id).get().$object;
        }
        $scope.alert(response.message.title, response.message.text, response.message.type, 2);
      }, function() {
        $scope.alert('Ration Not Confirmed', 'An error occured and the ration was not confirmed.', 'warning', 2);
      });
    }

    $scope.selectRation = function(ration) {
      // only allow the select if the ration is not set
      if ($scope.move.ration_id <= 0) {
        for (i in $scope.rations) {
          if ($scope.rations[i] && typeof $scope.rations[i] === 'object')
            $scope.rations[i].selected = false;
        }
        // move to the ration
        $scope.top = 50 + 100 - ration.position.centre_y;
        $scope.left = 20 + 100 - ration.position.centre_x;

        ration.selected = true;
        $scope.selectedRation = ration;
      }
    }

    $scope.selectDice = function(dieNum, dieValue) {
      if ($scope.move.ration_id > 0) {
        $scope.move.selected_die = dieNum;
        // do not update the selected die, it is not confirmed until movement
        Restangular.one('positions', $scope.move.ration.position.id)
                            .one('graph',dieValue).get().then(function(position) {
          $scope.position = position;
          console.log(position);
        });
      }
    };

    $scope.getRation = function(ration_id) {
      // get the ration on the board
      for (i in $scope.rations) {
        if ($scope.rations[i].id && $scope.rations[i].id == ration_id) {
          return $scope.rations[i];
        }
      }
      return null;
    }

    $scope.moveRation = function(newPos) {
      // update the selected die
      if (!$scope.move.dieSelected) {
        $scope.move.dieSelected = true;
        $scope.move.patch({selected_die:$scope.move.selected_die});
      }

      var ration = $scope.getRation($scope.move.ration.id);
      if (ration) {
        ration.position = newPos
      }

      // test for the end of the turn
      if (!newPos.positions) {
        // moving to last phase
        console.log('done turn');
        ration.position_id = newPos.id;
        ration.patch();
        $scope.game.doneTurn();
      }

      // update the possible positions
      $scope.position = newPos;
    }

    // movement controls
    $scope.width = 1000;
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
