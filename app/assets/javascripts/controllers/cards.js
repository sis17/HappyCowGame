angular.module('happyCow').controller('CardsCtrl', [
  '$scope', '$location', 'Restangular', '$modal', 'notice', '$timeout',
  function($scope, $location, Restangular, $modal, notice, $timeout) {

    $scope.$watch('user.cards', function() { /* update the cards */});
    $scope.$watch('user.rations', function() { /* update the rations */ });

    $scope.newRation = {
      ingredients: [{},{},{},{}],
      willCreate: null,
      setIngredients: function() {
        this.ingredients = [];
        var cards = $scope.user.cards;
        for (i in cards) {
          if (cards[i] && cards[i].used) {
            this.ingredients.push(cards[i]);
          }
        }

        while (this.ingredients.length < 4) {
          this.ingredients.push({});
        }
      },
      spaces: function() {
        var count = 0;
        for (i in this.ingredients) {
          if (!this.ingredients[i].game_card) {
            count++;
          }
        }
        return count;
      },
      replace: function(ingredient) {
        for (i in $scope.user.cards) {
          if ($scope.user.cards[i] == ingredient) {
            $scope.user.cards[i].used = false;
            this.setIngredients();
            break;
          }
        }
      },
      create: function() {
        var ration = {game_user_id: $scope.$storage.user.game_user.id, ingredients: this.ingredients};
        console.log(ration.ingredients);
        Restangular.all('rations').post({ration: ration, game_id: $scope.game.id}).then(function(response) {
          notice(response.messages);
          $scope.user.getCards();
          $scope.user.getRations();
          $scope.newRation.ingredients = [{},{},{},{}];
          //$scope.game.round.ration_created = true;

        }, function() {
          notice('Ration Not Created', 'An error occured and the ration was not created.', 'danger', 2);
        });
      },
      show: function() {
        if (($scope.user.rations && $scope.user.rations.length >= 4) || this.willCreate === false) {
          return false;
        }
        for (i in $scope.user.rations) {
          var r = $scope.user.rations[i];
          if (r && r.round_created_id && r.round_created_id == $scope.game.round.id) {
            return false;
          }
        }
        return true;
      }
    };

    $scope.getStage = function() {
      if ($scope.newRation.willCreate == null && $scope.newRation.show()) {
        return 0;
      } else if ($scope.newRation.show()) {
        return 1;
      } else if ($scope.user.cards.length > 9) {
        return 2;
      } else {
        return 3;
      }
    }

    $scope.endCardsTurn = function() {
      $scope.game.doneTurn();
      $timeout(function() {
        $scope.newRation.willCreate = null;
      }, 1200)
      //$scope.newRation.willCreate = null;
    }

    $scope.countUnusedIngredients = function() {
      var count = 0;
      var cards = $scope.user.cards;
      for (i in cards) {
        var guc = cards[i];
        if (guc && guc.game_card && typeof guc === 'object' &&
            guc.game_card.card.category != 'action' && !guc.used) {
            count++;
        }
      }
      return count;
    }

    $scope.countIngredients = function() {
      var count = 0;
      var cards = $scope.user.cards;
      for (i in cards) {
        var guc = cards[i];
        if (guc && guc.game_card && typeof guc === 'object' && guc.game_card.card.category != 'action') {
            count++;
        }
      }
      return count;
    }

    $scope.countActions = function() {
      var count = 0;
      var cards = $scope.user.cards;
      for (i in cards) {
        var guc = cards[i];
        if (guc && guc.game_card && typeof guc === 'object' &&
            guc.game_card.card.category && guc.game_card.card.category == 'action') {
            count++;
        }
      }
      return count;
    }

    $scope.useCard = function(card) {
      if (card.game_card.card.category == 'action') {
        // the card is an action, so update the server and remove
        card.used = true;
        card.patch({use:true}).then(function(response) {
          notice(response.message.title, response.message.text, response.message.type, 6);
          $scope.game.update();
          $scope.user.getCards();
        }, function() {
          card.used = false;
          notice('Card Not Used', 'An error occured and the card was not used.', 'danger', 3);
        });
      } else {
        // the card is an ingredient, so mark as used
        card.used = true;
        $scope.newRation.setIngredients();
      }
    };

    $scope.confirmCreation = function () {
      var modalInstance = $modal.open({
        templateUrl: 'createRation.html',
        controller: 'CreateRationCtrl',
        resolve: {
          ingredients: function () {
            return $scope.newRation.ingredients;
          },
          unUsed: function() {
            return $scope.countUnusedIngredients();
          },
          spaces: function() {
            return $scope.newRation.spaces();
          }
        }
      });

      modalInstance.result.then(function () {
        $scope.newRation.create();
      }, function () {
        console.log('Modal dismissed at: ' + new Date());
      });
    };

    $scope.view = function (game_user_card) {
      var modalInstance = $modal.open({
        templateUrl: 'cardDetails.html',
        controller: 'ViewCardCtrl',
        resolve: {
          game_user_card: function () {
            return game_user_card;
          },
          game: function() {
            return $scope.game;
          },
          user: function() {
            return $scope.user;
          }
        }
      });

      modalInstance.result.then(function (card) {
        $scope.useCard(card);
      }, function () {
        console.log('Modal dismissed at: ' + new Date());
      });
    };

    $scope.discardCard = function (game_user_card) {
      console.log('performing discard card id:'+game_user_card.id);
      // delete card
      game_user_card.remove().then(function(response) {
          notice(response.message.title, response.message.text, response.message.type, 2);
          $scope.user.getCards();
      }, function() {
          notice('Card Not Discarded', 'An error occured and the card was not discarded.', 'warning', 2);
      });
    };

    $scope.discard = function (game_user_card) {
      var modalInstance = $modal.open({
        templateUrl: 'cardDiscard.html',
        controller: 'DiscardCardCtrl',
        resolve: {
          game_user_card: function () {
            return game_user_card;
          }
        }
      });

      modalInstance.result.then(function (card) {
        $scope.discardCard(card);
      }, function () {
        console.log('Modal dismissed at: ' + new Date());
      });
    };

  }
]);

angular.module('happyCow').controller('ViewCardCtrl',
  function (notice, $scope, $modalInstance, game_user_card, game, user) {
    $scope.game_user_card = game_user_card;
    $scope.card = game_user_card.game_card.card;
    $scope.game = game;
    $scope.user = user;

    $scope.use = function () {
      $modalInstance.close($scope.game_user_card, true);
    };

    $scope.cancel = function () {
      $modalInstance.dismiss('cancel');
    };
});

angular.module('happyCow').controller('DiscardCardCtrl',
  function (notice, $scope, $modalInstance, game_user_card) {
    $scope.game_user_card = game_user_card;

    $scope.discard = function () {
      $modalInstance.close($scope.game_user_card, true);
    };

    $scope.cancel = function () {
      $modalInstance.dismiss('cancel');
    };
});

angular.module('happyCow').controller('CreateRationCtrl',
  function (notice, $scope, $modalInstance, ingredients, unUsed, spaces) {
    console.log(spaces);
    $scope.ingredients = ingredients;
    $scope.unUsed = unUsed;
    $scope.spaces = spaces;
    $scope.canCreate = spaces < 4;

    $scope.create = function () {
      $modalInstance.close();
    };

    $scope.cancel = function () {
      $modalInstance.dismiss('cancel');
    };
});
