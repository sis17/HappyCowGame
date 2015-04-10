var phaseCtrl = angular.module('happyCow').controller('MovementCtrl', [
  '$scope', '$location', 'Restangular', 'notice', '$timeout',
  function($scope, $location, Restangular, notice, $timeout) {

    var showMoves = function() {
      if ($scope.user.move && $scope.user.move.ration_id) {
        if ($scope.user.move.selected_die) {
          loadSelection();
        }
        buildDice();
      }
    }

    $scope.$watch('user.rations', function() { /* update the rations */ });
    $scope.$watch('game.allRations', function() { /* update the rations */ });

    $scope.$watch('user.move.ration_id', function(newValue, oldValue) {
      showMoves();
    });
    $scope.$watch('move.selected_die', function(newValue, oldValue) {
      showMoves();
    });

    // start up stuff
    $scope.game.getAllRations();
    $scope.visitedPositions = {}; // positions that the ration can't revisit

    $scope.confirmRation = function() {
      if (!$scope.user.move.ration) {
        // if no ration is selected, let the user know
        notice('First Choose a Ration', 'You need to select a ration from the list, then press `Confirm`.', 'info', 2)
      } else {
        // a ration has been selected, so confirm it as chosen
        $scope.user.move.patch({confirm_ration:true, ration_id:$scope.user.move.ration.id}).then(function (response) {
          if (response.move) {
            Restangular.one('moves', $scope.user.move.id).get().then(function(move) {
              $scope.user.move = move;
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
      $scope.top = 50 + 100 - (ration.position.centre_y/2);
      $scope.left = 20 + 100 - (ration.position.centre_x/2);

      // check it is not stuck in the trough
      if (ration.position.area_id == 1 && ration.position.order > 2) {
        notice('Ration Cannot Move', 'The ration you selected is behind others on the trough. The rations in front must be eaten before you can move this ration.', 'warning', 8)
        // only allow the select if the ration is not set
      } else if (!$scope.user.move.ration || !$scope.user.move.ration.id <= 0) {
        // move to the ration
        $scope.user.move.ration = ration;
      }
    }

    var loadSelection = function() {
      if (!$scope.user.move.ration_id || !$scope.user.move.selected_die || $scope.user.move.selected_die < 1) {
        return;
      }
      // do not update the selected die, it is not confirmed until movement
      Restangular.one('games', $scope.game.id).one('positions', $scope.user.move.ration.position.id)
                          .one('graph',$scope.user.move.movements_left).get().then(function(graph) {
        $scope.graph = graph;
        $scope.graph.traverse = function(posId) {
          var depth = 0;
          var positions = [];
          check = {};
          check[posId] = posId;
          var links = this[posId].links;
          while (depth < $scope.user.move.movements_left) { // only look for links if there's enough movements left
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
        var ration = $scope.getRation($scope.user.move.ration.id);
        $scope.possiblePositions = graph.traverse(ration.position.id);
      }, function() {
        console.log('error, positions not returned')
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
      var ration = $scope.getRation($scope.user.move.ration.id);
      if (ration) {
        // update the position
        $scope.user.move.patch({make_move: true, move: $scope.user.move, position_id: newPos.id}).then(function(response) {
            if (response.success) {
              if (response.move) {
                $scope.user.move.movements_left = response.move.movements_left;
                $scope.user.move.movements_made = response.move.movements_made;
                $scope.animateRation(ration, newPos); // when finished it will save the position
              } else {
                endMovementPhase(); // the ration has been deleted
              }
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
          // finish the animation and move on
          ration.position = newPos
          $scope.possiblePositions = $scope.graph.traverse(newPos.id);
          ration.position_id = newPos.id;
        }
      }, $scope.sectionsCount)
    }

    var endMovementPhase = function() {
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
          return (!$scope.user.move.selected_die || $scope.user.move.selected_die == this.number) && this.value > 0 ? '' : 'fade-out';
        },
        select: function() {
          if ($scope.user.move.selected_die && $scope.user.move.selected_die != this.number && $scope.user.move.movements_made > 0) {
            notice('Die Already Selected', 'You have already begun moving with another die, so cannot use that one.', 'warning', 6);
          } else if (this.value >= 1) {
            if ($scope.user.move.selected_die && $scope.user.move.selected_die == this.number) {
              notice('Die Already Selected', 'You have already begun moving that die. You have '+$scope.user.move.movements_left+' movements left.', 'info', 6);
            }
              $scope.game.getAllRations();
              $scope.user.move.selected_die = this.number;
              $scope.user.move.movements_left = this.value*this.combine;
              loadSelection();

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
      if ($scope.user.move.dice1 > 0 && $scope.user.move.dice1 == $scope.user.move.dice2 && $scope.user.move.dice1 == $scope.user.move.dice3) {// triple
        addDice(1, $scope.user.move.dice1, 3, 'water');
      } else if ($scope.user.move.dice1 > 0 && $scope.user.move.dice1 == $scope.user.move.dice2) { // first double
        addDice(1, $scope.user.move.dice1, 2, '');
        addDice(3, $scope.user.move.dice3, 1, 'water');
      } else if ($scope.user.move.dice1 > 0 && $scope.user.move.dice1 == $scope.user.move.dice3) { // second double
        addDice(1, $scope.user.move.dice1, 2, 'water');
        addDice(2, $scope.user.move.dice2, 1, '');
      } else if ($scope.user.move.dice2 > 0 && $scope.user.move.dice2 == $scope.user.move.dice3) { // third double
        addDice(1, $scope.user.move.dice1, 1, '');
        addDice(2, $scope.user.move.dice2, 2, 'water');
      } else {
        addDice(1, $scope.user.move.dice1, 1, '');
        addDice(2, $scope.user.move.dice2, 1, '');
        addDice(3, $scope.user.move.dice3, 1, 'water');
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
