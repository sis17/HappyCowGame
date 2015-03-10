angular.module('happyCow').controller('CardsCtrl', [
  '$scope', '$location', 'Restangular', '$modal',
  function($scope, $location, Restangular, $modal) {

    $scope.cards = $scope.user.getCards();
    $scope.rations = $scope.user.getRations();

    $scope.newRation = {
      ingredients: [{},{},{},{}],
      setIngredients: function() {
        this.ingredients = [];
        var cards = $scope.cards.$object;
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
          if (this.ingredients[i].game_card && this.ingredients[i].game_card.card.category == 'empty') {
            count++;
          }
        }
        return count;
      },
      replace: function(ingredient) {
        for (i in $scope.cards.$object) {
          if ($scope.cards.$object[i] == ingredient) {
            $scope.cards.$object[i].used = false;
            this.setIngredients();
            break;
          }
        }
      },
      create: function() {
        var ration = {game_user_id: $scope.$storage.user.game_user.id, ingredients: this.ingredients};
        Restangular.all('rations').post({ration: ration, game_id: $scope.game.id}).then(function(response) {
          $scope.alert(response.message.title, response.message.message, response.message.type, 2);
          $scope.cards = $scope.user.getCards();
          $scope.rations = $scope.user.getRations();
          $scope.game.round.ration_created = true;

        }, function() {
          $scope.alert('Ration Not Created', 'An error occured and the ration was not created.', 'danger', 2);
        });
      }
    };

    $scope.countUnusedIngredients = function() {
      var count = 0;
      var cards = $scope.cards.$object;
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
      var cards = $scope.cards.$object;
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
      var cards = $scope.cards.$object;
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
      console.log(card);
      if (card.game_card.card.category == 'action') {
        // the card is an action, so update the server and remove
        card.used = true;
        card.patch().then(function(response) {
          $scope.alert(response.message.title, response.message.message, response.message.type, 2);
          $scope.cards = $scope.user.getCards();
        }, function() {
          $scope.alert('Card Not Used', 'An error occured and the card was not used.', 'danger', 2);
        });
      } else {
        // the card is an ingredient, so mark as used
        card.used = true;
        $scope.newRation.setIngredients();
      }
    };

    $scope.view = function (game_user_card) {
      var modalInstance = $modal.open({
        templateUrl: 'myModalContent.html',
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

      modalInstance.result.then(function (card, use) {
        $scope.useCard(card);
      }, function () {
        console.log('Modal dismissed at: ' + new Date());
      });
    };

  }
]);

angular.module('happyCow').controller('ViewCardCtrl', function ($scope, $modalInstance, game_user_card, game, user) {
  $scope.game_user_card = game_user_card;
  $scope.card = game_user_card.game_card.card;
  $scope.game = game;
  $scope.user = user;

  $scope.discard = function () {
    var r = confirm("Are you sure you want to delete the card: "+$scope.card.title);
    if (r == true) {
      console.log('performing discard card id:'+card.id);
      // delete card
      $scope.game_user_card.remove();
      $scope.user.getCards();
      $modalInstance.dismiss('Card discarded.');
    }
  };

  $scope.use = function () {
    $modalInstance.close($scope.game_user_card, true);
  };

  $scope.cancel = function () {
    $modalInstance.dismiss('cancel');
  };
});
