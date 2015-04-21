var phaseCtrl = angular.module('happyCow').controller('MovementCtrl', [
  '$scope', '$location', 'Restangular', 'notice', '$timeout',
  function($scope, $location, Restangular, notice, $timeout) {

    var showMoves = function() {
      if ($scope.player.move && $scope.player.move.ration_id) {
        if ($scope.player.move.selected_die) {
          loadSelection();
        }
        buildDice();
      }
    }

    $scope.$watch('user.rations', function() { /* update the rations */ });
    $scope.$watch('game.allRations', function() { /* update the rations */ });

    $scope.$watch('player.move.ration_id', function(newValue, oldValue) {
      showMoves();
    });
    $scope.$watch('move.selected_die', function(newValue, oldValue) {
      showMoves();
    });

    // start up stuff
    $scope.game.getAllRations();
    $scope.player.getMoves();
    $scope.visitedPositions = {}; // positions that the ration can't revisit
    $scope.possiblePositions = [];
    $scope.confirmRation = function() {
      if (!$scope.player.move.ration) {
        // if no ration is selected, let the user know
        notice('First Choose a Ration', 'You need to select a ration from the list, then press `Confirm`.', 'info', 2)
      } else {
        // a ration has been selected, so confirm it as chosen
        $scope.player.move.patch({confirm_ration:true, ration_id:$scope.player.move.ration.id}).then(function (response) {
          if (response.move) {
            Restangular.one('moves', $scope.player.move.id).get().then(function(move) {
              $scope.player.move = move;
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
      console.log('it is '+$scope.player.getName()+'`s turn');
      $scope.game.getAllRations();
      $scope.top = 50 + 100 - (ration.position.centre_y/2);
      $scope.left = 20 + 100 - (ration.position.centre_x/2);

      // check the ration belongs to the current player
      if (ration.game_user_id != $scope.player.getGameUserId()) {
        notice('Not Yours', 'The ration you selected does not belong to you. Please select another.', 'warning', 8)

      } else if (!$scope.player.move.ration || !$scope.player.move.ration.id <= 0) {
        // alert user if it is stuck in the trough
        if (ration.position.area_id == 1 && ration.position.order > 2) {
          notice('Ration Cannot Move', 'The ration you selected is behind others on the trough. The rations in front must be eaten before you can move this ration.', 'warning', 8)
          // only allow the select if the ration is not set
        }
        // move to the ration
        $scope.player.move.ration = ration;
      }
    }

    var loadSelection = function() {
      if (!$scope.player.move.ration_id || !$scope.player.move.selected_die || $scope.player.move.selected_die < 1) {
        return;
      }
      var ration = $scope.getRation($scope.player.move.ration_id);
      if (!ration || !ration.position) {
        $scope.player.getRations();
        $scope.player.getMoves();
        return;
      }

      // do not update the selected die, it is not confirmed until movement
      Restangular.one('games', $scope.game.id).one('positions', ration.position.id)
                          .one('graph',$scope.player.move.movements_left).get().then(function(graph) {
        $scope.graph = graph;
        $scope.graph.traverse = function(posId) {
          var depth = 0;
          var positions = [];
          check = {};
          check[posId] = posId;
          var links = this[posId].links;
          while (depth < $scope.player.move.movements_left) { // only look for links if there's enough movements left
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
        $scope.possiblePositions = graph.traverse(ration.position.id);
      }, function() {
        console.log('error, positions not returned')
      });
    }

    $scope.getRation = function(ration_id) {
      // get the ration on the board
      var allRations = $scope.game.allRations;
      for (i in allRations) {
        if (allRations[i] && allRations[i].id && allRations[i].id == ration_id) {
          return allRations[i];
        }
      }
      return null;
    }

    $scope.moveRation = function(newPosId, allMoves) {
      $scope.moving = true;
      var newPos = $scope.graph[newPosId];
      var ration = $scope.getRation($scope.player.move.ration.id);
      if (ration) {
        // update the position
        $scope.player.move.patch({make_move: true, all_moves: (allMoves ? true : false), move: $scope.player.move, position_id: newPos.id}).then(function(response) {
            if (response.success) {
              if (response.move) {
                $scope.player.move.movements_left = response.move.movements_left;
                $scope.player.move.movements_made = response.move.movements_made;
                $scope.animateRation(ration, newPos); // when finished it will save the position
              } else {
                endMovementPhase(); // the ration has been deleted
              }
            } else {
              $scope.moving = false;
            }
            notice(response.messages);
        },function() {
            notice('Ration Not Moved', 'An error occured and the ration was not moved.', 'warning', 4);
        });
      } else {
        $scope.moving = false;
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
          $scope.moving = false;
          ration.position = newPos
          $scope.possiblePositions = $scope.graph.traverse(newPos.id);
          ration.position_id = newPos.id;
          $scope.game.getAllRations();
        }
      }, $scope.sectionsCount)
    }

    var endMovementPhase = function() {
      //$scope.game.getAllRations();
      $scope.player.move = null;
      $scope.game.doneTurn();
    }

    var addDice = function(number, value, combine, waterClass) {
      var die = {
        number: number,
        value: value,
        combine: combine,
        selected: false,
        class: function() {
          return (!$scope.player.move.selected_die || $scope.player.move.selected_die == this.number) && this.value > 0 ? '' : 'fade-out';
        },
        select: function() {
          if ($scope.player.move.selected_die && $scope.player.move.selected_die != this.number && $scope.player.move.movements_made > 0) {
            notice('Die Already Selected', 'You have already begun moving with another die, so cannot use that one.', 'warning', 6);
          } else if (this.value >= 1) {
            if ($scope.player.move.selected_die && $scope.player.move.selected_die == this.number) {
              notice('Die Already Selected', 'You have already begun moving that die. You have '+$scope.player.move.movements_left+' movements left.', 'info', 6);
            }
              $scope.game.getAllRations();
              $scope.player.move.selected_die = this.number;
              $scope.player.move.movements_left = this.value*this.combine;
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
      if ($scope.player.move.dice1 > 0 && $scope.player.move.dice1 == $scope.player.move.dice2 && $scope.player.move.dice1 == $scope.player.move.dice3) {// triple
        addDice(1, $scope.player.move.dice1, 3, 'water');
      } else if ($scope.player.move.dice1 > 0 && $scope.player.move.dice1 == $scope.player.move.dice2) { // first double
        addDice(1, $scope.player.move.dice1, 2, '');
        addDice(3, $scope.player.move.dice3, 1, 'water');
      } else if ($scope.player.move.dice1 > 0 && $scope.player.move.dice1 == $scope.player.move.dice3) { // second double
        addDice(1, $scope.player.move.dice1, 2, 'water');
        addDice(2, $scope.player.move.dice2, 1, '');
      } else if ($scope.player.move.dice2 > 0 && $scope.player.move.dice2 == $scope.player.move.dice3) { // third double
        addDice(1, $scope.player.move.dice1, 1, '');
        addDice(2, $scope.player.move.dice2, 2, 'water');
      } else {
        addDice(1, $scope.player.move.dice1, 1, '');
        addDice(2, $scope.player.move.dice2, 1, '');
        addDice(3, $scope.player.move.dice3, 1, 'water');
      }
    }

    $scope.getStage = function() {
      if ($scope.player.rations.length <= 0) {
        return 0;
      } else if ($scope.player.move && !$scope.player.move.ration_id) { // if no ration is selected
        if (!$scope.player.move.ration) {
          return 1;
        } else {
          return 2;
        }
      } else if ($scope.player.move && !$scope.player.move.selected_die) { // ration selected, dice shown
        return 3;
      } else if ($scope.possiblePositions.length > 0) { // dice selected
        return 4;
      } else if ($scope.player.move && $scope.player.move.movements_made > 0 && $scope.possiblePositions.length > 0) { // need to continue moving
        return 5;
      } else { // no more moves
        return 6;
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
