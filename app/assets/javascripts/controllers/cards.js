angular.module('happyCow').controller('CardsCtrl', [
  '$scope', 'Card', 'Ration',
  function($scope, Card, Ration) {
    $scope.cards = Card.query();
    $scope.rations = Ration.query();
    $scope.card = Card.get({id: 1});
    var cardModal;
    var rationModal;

    $scope.newRation = {
      ingredients: [{type: 'empty'},{type: 'empty'},{type: 'empty'},{type: 'empty'}],
      setIngredients: function() {
        this.ingredients = [];
        for (i in $scope.cards) {
          if ($scope.cards[i].used) {
            this.ingredients.push($scope.cards[i]);
          }
        }

        while (this.ingredients.length < 4) {
          this.ingredients.push({type: 'empty'});
        }
      },
      spaces: function() {
        var count = 0;
        for (i in this.ingredients) {
          if (this.ingredients[i].type == 'empty') {
            count++;
          }
        }
        return count;
      },
      replace: function(ingredient) {
        for (i in $scope.cards) {
          if ($scope.cards[i] == ingredient) {
            $scope.cards[i].used = false;
            this.setIngredients();
            break;
          }
        }
      }
    };

    $scope.countUnusedIngredients = function() {
      var count = 0;
      for (i in $scope.cards) {
        var card = $scope.cards[i];
        if (card.type && card.type != 'action' && !$scope.cards[i].used) {
            count++;
        }
      }
      return count;
    }

    $scope.countIngredients = function() {
      var count = 0;
      for (i in $scope.cards) {
        var card = $scope.cards[i];
        if (card.type && card.type != 'action') {
            count++;
        }
      }
      return count;
    }

    $scope.countActions = function() {
      var count = 0;
      for (i in $scope.cards) {
        var card = $scope.cards[i];
        if (card.type && card.type == 'action') {
            count++;
        }
      }
      return count;
    }

    $scope.discardCard = function(cardId) {
      console.log('performing discard card id:'+cardId);
      Card.delete({id: cardId});
      for (i in $scope.cards) {
        if ($scope.cards[i].id == cardId) {
          $scope.cards.splice(i,1);
        }
      }
      $scope.cards = Card.query();
    };

    $scope.useCard = function(card) {
      if (card.type == 'action') {
        // the card is an action, so update the server and remove
        Card.delete({id: card.id});
        $scope.cards = Card.query();
      } else {
        // the card is an ingredient, so mark as used
        card.used = true;
        $scope.newRation.setIngredients();
      }
    };
  }
]);
