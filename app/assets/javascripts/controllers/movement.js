var phaseCtrl = angular.module('happyCow').controller('MovementCtrl', [
  '$scope', '$location', 'Restangular', 'notice',
  function($scope, $location, Restangular, notice) {

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
    Restangular.one('games', $scope.game.id).getList('rations').then(function(rations) {
      $scope.allRations = rations;
    });
    $scope.selectedRation = null;
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
        Restangular.one('games', $scope.game.id).one('positions', $scope.move.ration.position.id)
                            .one('graph',dieValue).get().then(function(position) {
          $scope.position = position; // position of the ration
          $scope.movementsLeft = dieValue;
          // assemble the positions
          $scope.graph = {};
          buildGraph($scope.graph, position);
          $scope.graph.traverse = function(posId) {
            var depth = 0;
            var positions = [];
            check = {};
            check[posId] = posId;
            var links = this[posId].links;
            while (depth < $scope.movementsLeft) { // only look for links if there's enough movements left
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
    };

    var buildGraph = function(graph, position) {
      // create the position, if not already there
      if (!graph[position.id]) {
        graph[position.id] = position;
        graph[position.id].links = {};
      }
      // add any links
      if (position.positions) {
        for (i in position.positions) {
          if (position.positions[i] && position.positions[i].id) {
            // add the links to the current position
            var linkId = position.positions[i].id;
            graph[position.id].links[linkId] = linkId;
            // add the next position, if it doesn't already exist
            buildGraph(graph, position.positions[i]);
          }
        }
      }
    }

    $scope.getRation = function(ration_id) {
      // get the ration on the board
      for (i in $scope.allRations) {
        if ($scope.allRations[i].id && $scope.allRations[i].id == ration_id) {
          return $scope.allRations[i];
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
        ration.position = newPos
      }

      // test for the end of the turn
      if (newPos.links.length == 0 || $scope.movementsLeft <= 0) { // improve this to check if there's allowed movements left
        ration.position_id = newPos.id;
        ration.patch().then(function(response) {
          $scope.game.update();
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
      console.log('done turn');
      $scope.game.doneTurn();
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
