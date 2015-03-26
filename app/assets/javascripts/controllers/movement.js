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

    $scope.confirmRation = function(ration) {
      if (!ration) {
        // if no ration is selected, let the user know
        notice('First Choose a Ration', 'You need to select a ration from the list, then press `Confirm`.', 'info', 2)
      } else {
        // a ration has been selected, so confirm it as chosen
        $scope.move.ration_id = ration.id;
        $scope.move.patch({confirm_ration:true, ration_id:ration.id}).then(function (response) {
          if (response.move) {
            $scope.move = Restangular.one('moves', $scope.move.id).get().$object;
          }
          notice(response.message.title, response.message.text, response.message.type, 2);
        }, function() {
          notice('Ration Not Confirmed', 'An error occured and the ration was not confirmed.', 'warning', 2);
        });
      }
    }

    $scope.selectRation = function(ration) {
      $scope.game.getAllRations();
      // only allow the select if the ration is not set
      if ($scope.move.ration_id <= 0) {
        for (i in $scope.rations) {
          if ($scope.rations[i] && typeof $scope.rations[i] === 'object')
            $scope.rations[i].selected = false;
        }
        // move to the ration
        $scope.top = 50 + 100 - (ration.position.centre_y/2);
        $scope.left = 20 + 100 - (ration.position.centre_x/2);

        ration.selected = true;
        $scope.selectedRation = ration;
      }
    }

    $scope.selectDice = function(dieNum, dieValue) {
      $scope.game.getAllRations();
      if (dieValue <= 0) {
        Restangular.one('events',$scope.game.cow.disease_id).get().then(function(event) {
          notice('Die Cannot Be Used', 'Due to the event: '+event.title+', the die you selected is out of play.', 'danger', 6);
        });
      } else {
        if ((dieNum == 1 || dieNum == 2 ) && $scope.move.dice1 == $scope.move.dice2) {
          dieValue *= 2;
        }

        if ($scope.move.ration_id > 0) {
          $scope.move.selected_die = dieNum;
          // do not update the selected die, it is not confirmed until movement
          Restangular.one('games', $scope.game.id).one('positions', $scope.move.ration.position.id)
                              .one('graph',dieValue).get().then(function(graph) {
            $scope.position = graph[$scope.move.ration.position.id]; // position of the ration
            $scope.movementsLeft = dieValue;
            $scope.graph = graph;
            $scope.graph.traverse = function(posId) {
              var depth = 0;
              var positions = [];
              check = {};
              check[posId] = posId;
              var links = this[posId].links;
              while (depth <= $scope.movementsLeft) { // only look for links if there's enough movements left
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
          });
        }
      }
    };

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
      $scope.movementsLeft--;
      console.log('movements left: '+$scope.movementsLeft);

      // update the selected die
      if (!$scope.move.dieSelected) {
        $scope.move.dieSelected = true;
        $scope.move.patch({select_dice: true, selected_die:$scope.move.selected_die});
      }

      var newPos = $scope.graph[newPosId];
      var ration = $scope.getRation($scope.move.ration.id);

      if (ration) {
        $scope.animateRation(ration, newPos); // when finished it will save the position
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

      // test for the end of the turn
      if (newPos.links.length == 0 || $scope.movementsLeft <= 0) { // improve this to check if there's allowed movements left
        ration.position_id = newPos.id;
        Restangular.one("rations", ration.id).patch({ration: ration}).then(function(response) {
          $scope.game.update();
          $scope.game.getAllRations();
          if (response.message) {
            notice(response.message.title, response.message.text, response.message.type, 0);
          }
        });
        $scope.endMovementPhase();
      }

      // update the possible positions
      $scope.position = newPos;
    }

    $scope.endMovementPhase = function() {
      // moving to last phase
      $scope.game.doneTurn();
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
