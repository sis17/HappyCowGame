angular.module('happyCow').controller('CardsCtrl', [
  '$scope', '$location', 'Restangular',
  function($scope, $location, Restangular) {

    $scope.cards = $scope.user.getCards();
    $scope.rations = $scope.user.getRations();

    $scope.test = 'test true';

    $scope.newRation = {
      ingredients: [{card:{category: 'empty'}},{card:{category: 'empty'}},{card:{category: 'empty'}},{card:{category: 'empty'}}],
      setIngredients: function() {
        this.ingredients = [];
        console.log('setting ingredients');
        var cards = $scope.cards.$object;
        for (i in cards) {
          if (cards[i] && cards[i].used) {
            this.ingredients.push(cards[i]);
          }
        }

        while (this.ingredients.length < 4) {
          this.ingredients.push({card:{category: 'empty'}});
        }
      },
      spaces: function() {
        var count = 0;
        for (i in this.ingredients) {
          if (this.ingredients[i].card.category == 'empty') {
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
        $scope.user.createRation(this.ingredients);
      }
    };

    $scope.countUnusedIngredients = function() {
      var count = 0;
      var cards = $scope.cards.$object;
      for (i in cards) {
        var guc = cards[i];
        if (guc && guc.card && typeof guc === 'object' && guc.card.category != 'action' && !guc.used) {
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
        if (guc && guc.card && typeof guc === 'object' && guc.card.category != 'action') {
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
        if (guc && guc.card && typeof guc === 'object' && guc.card.category && guc.card.category == 'action') {
            count++;
        }
      }
      return count;
    }

    $scope.discardCard = function(card) {
      console.log('performing discard card id:'+card);
      // delete card
      card.remove();
      $scope.getCards();
    };

    $scope.useCard = function(card) {
      if (card.card.category == 'action') {
        // the card is an action, so update the server and remove
        //card.remove();
        card.use = true;
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

  }
]);
