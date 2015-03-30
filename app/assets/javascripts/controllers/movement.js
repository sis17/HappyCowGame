var phaseCtrl = angular.module('happyCow').controller('MovementCtrl', [
  '$scope', '$location', 'Restangular', 'notice', '$timeout',
  function($scope, $location, Restangular, notice, $timeout) {

    $scope.getMoves = function() {
      var moves = Restangular.one('games', $scope.game.id)
                    .one('rounds', $scope.game.round.id).getList('moves').then(function(moves) {
        var currentUser = $scope.$storage.user.game_user;
        for (i in moves) {
          var move = moves[i];
          if (move && move.game_user_id == currentUser.id) {
            $scope.move = moves[i];
            if ($scope.move.ration_id) {
              if ($scope.move.selected_die) {
                loadSelection();
              }
              buildDice();
            }
          }
        }
      });
    }

    // bar controls
    $scope.movePhase = 1;
    $scope.rations = Restangular.one('games', $scope.game.id)
                      .one('game_users', $scope.$storage.user.game_user.id).getList('rations').$object;
    $scope.selectedRation = null;
    $scope.game.getAllRations();
    $scope.getMoves();

    $scope.visitedPositions = {}; // positions that the ration can't revisit

    $scope.confirmRation = function() {
      if (!$scope.move.ration.id) {
        // if no ration is selected, let the user know
        notice('First Choose a Ration', 'You need to select a ration from the list, then press `Confirm`.', 'info', 2)
      } else {
        // a ration has been selected, so confirm it as chosen
        $scope.move.patch({confirm_ration:true, ration_id:$scope.move.ration.id}).then(function (response) {
          if (response.move) {
            Restangular.one('moves', $scope.move.id).get().then(function(move) {
              $scope.move = move;
              buildDice();
            });
          }
          notice(response.messages);
        }, function() {
          notice('Ration Not Confirmed', 'An error occured and the ration was not confirmed.', 'warning', 2);
        });
      }
    }

    $scope.selectRation = function(ration) {
      $scope.game.getAllRations();
      console.log($scope.move.ration)
      // only allow the select if the ration is not set
      if (!$scope.move.ration || !$scope.move.ration.id <= 0) {
        // move to the ration
        $scope.top = 50 + 100 - (ration.position.centre_y/2);
        $scope.left = 20 + 100 - (ration.position.centre_x/2);
        $scope.move.ration = ration;
        //ration.selected = true;
        //$scope.selectedRation = ration;
      }
    }

    var loadSelection = function() {
      if (!$scope.move.ration_id || !$scope.move.selected_die || $scope.move.selected_die < 1) {
        return;
      }
      // do not update the selected die, it is not confirmed until movement
      Restangular.one('games', $scope.game.id).one('positions', $scope.move.ration.position.id)
                          .one('graph',$scope.move.movements_left).get().then(function(graph) {

        $scope.graph = graph;
        $scope.graph.traverse = function(posId) {
          var depth = 0;
          var positions = [];
          check = {};
          check[posId] = posId;
          var links = this[posId].links;
          while (depth <= $scope.move.movements_left) { // only look for links if there's enough movements left
            ++depth;
            var nextLinks = {};
            for (i in links) {
              if (this[i] && !check[i]) {
                var pos = this[i];
                // prepare links for next depth
                for (i in pos.links) {
                  nextLinks[i] = i;
                }
                check[pos.id] = pos.id;
                pos.depth = depth;
                positions.push(pos);
              }
            }
            links = nextLinks;
          }
          return positions;
        }
        // load the first possible positions
        var ration = $scope.getRation($scope.move.ration.id);
        $scope.possiblePositions = graph.traverse(ration.position.id);
        if ($scope.possiblePositions.length == 0) { // check if the ration is stuck
          notice('You were Stuck', 'Your ration could not finish it`s moves.', 'info', 6);
          endMovementPhase($scope.getRation($scope.move.ration_id));
        }
      });
    }

    $scope.getRation = function(ration_id) {
      // get the ration on the board
      var allRations = $scope.game.allRations;
      for (i in allRations) {
        if (allRations[i].id && allRations[i].id == ration_id) {
          return allRations[i];
        }
      }
      return null;
    }

    $scope.moveRation = function(newPosId) {
      var newPos = $scope.graph[newPosId];
      var ration = $scope.getRation($scope.move.ration.id);
      if (ration) {
        // update the position
        $scope.move.patch({make_move: true, move: $scope.move, position_id: newPos.id}).then(function(response) {
            if (response.success) {
              $scope.move.movements_left = response.move.movements_left;
              $scope.move.movements_made = response.move.movements_made;
              $scope.animateRation(ration, newPos); // when finished it will save the position
            }
            notice(response.messages);
        },function() {
            notice('Ration Not Moved', 'An error occured and the ration was not moved.', 'warning', 4);
        });
      }
    }

    $scope.animateRation = function(ration, newPos){
      $scope.sectionsCount = 300/20;
      var distanceX = newPos.centre_x - ration.position.centre_x;
      var distanceY = newPos.centre_y - ration.position.centre_y;
      $scope.animateX = distanceX/$scope.sectionsCount // the X distance to travel each interval
      $scope.animateY = distanceY/$scope.sectionsCount // the Y distance to travel each interval
      $scope.currentSection = 1;
      animateLoop(ration, newPos)
    };

    var animateLoop = function(ration, newPos) {
      $timeout(function() {
        ration.position.centre_x += $scope.animateX;
        ration.position.centre_y += $scope.animateY;
        $scope.currentSection++;
        if ($scope.currentSection <= $scope.sectionsCount) {
          animateLoop(ration, newPos); // go through the loop again
        } else {
          $scope.updateRation(ration, newPos); // finish the animation and move on
        }
      }, $scope.sectionsCount)
    }

    $scope.updateRation = function(ration, newPos) {
      ration.position = newPos
      $scope.possiblePositions = $scope.graph.traverse(newPos.id);
      ration.position_id = newPos.id;

      // test for the end of the turn
      if ($scope.move.movements_left <= 0) { // check if there's allowed movements left
        endMovementPhase(ration);
      } else if ($scope.possiblePositions.length == 0) { // check if the ration is stuck
        notice('You were Stuck', 'Your ration could not finish it`s moves.', 'info', 6);
        endMovementPhase(ration);
      }
    }

    var endMovementPhase = function(ration) {
      $scope.game.getAllRations();
      $scope.game.doneTurn();
    }

    var addDice = function(number, value, combine, waterClass) {
      var die = {
        number: number,
        value: value,
        combine: combine,
        selected: false,
        class: function() {
          return (!$scope.move.selected_die || $scope.move.selected_die == this.number) && this.value > 0 ? '' : 'fade-out';
        },
        select: function() {
          if ($scope.move.selected_die && $scope.move.selected_die != this.number && $scope.move.movements_made > 0) {
            notice('Die Already Selected', 'You have already begun moving with another die, so cannot use that one.', 'warning', 6);
          } else if (this.value >= 1) {
            if ($scope.move.selected_die && $scope.move.selected_die == this.number) {
              notice('Die Already Selected', 'You have already begun moving that die. You have '+$scope.move.movements_left+' movements left.', 'info', 6);
            } else {
              $scope.game.getAllRations();
              $scope.move.selected_die = this.number;
              $scope.move.movements_left = this.value*this.combine;
              loadSelection();
            }
          } else {
            notice('Die Cannot Be Used', 'The die you selected is out of play.', 'warning', 6);
          }
        },
        doubleClass: (combine > 1 ? (combine > 2 ? 'die-triple' : 'die-double') : ''),
        waterClass: waterClass
      };
      $scope.dice.push(die);
    }
    // put dice into structure to show doubles or tripples
    var buildDice = function() {
      $scope.dice = [];
      if ($scope.move.dice1 > 0 && $scope.move.dice1 == $scope.move.dice2 && $scope.move.dice1 == $scope.move.dice3) {// triple
        addDice(1, $scope.move.dice1, 3, 'water');
      } else if ($scope.move.dice1 > 0 && $scope.move.dice1 == $scope.move.dice2) { // first double
        addDice(1, $scope.move.dice1, 2, '');
        addDice(3, $scope.move.dice3, 1, 'water');
      } else if ($scope.move.dice1 > 0 && $scope.move.dice1 == $scope.move.dice3) { // second double
        addDice(1, $scope.move.dice1, 2, 'water');
        addDice(2, $scope.move.dice2, 1, '');
      } else if ($scope.move.dice2 > 0 && $scope.move.dice2 == $scope.move.dice3) { // third double
        addDice(1, $scope.move.dice1, 1, '');
        addDice(2, $scope.move.dice2, 2, 'water');
      } else {
        addDice(1, $scope.move.dice1, 1, '');
        addDice(2, $scope.move.dice2, 1, '');
        addDice(3, $scope.move.dice3, 1, 'water');
      }
    }

    $scope.$watch('game.cow.ph_marker', function(newValue, oldValue) {
      $scope.ph_colour = 128 - Math.round((Math.abs($scope.game.cow.ph_marker-6.5)*100));
    });

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
    $scope.moveRight = function() {
      $scope.left -= 25;
    }
    $scope.moveLeft = function() {
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
