angular.module('happyCow').controller('CardsCtrl', [
  '$scope', '$location', 'Restangular',
  function($scope, $location, Restangular) {
    // get rations and cards
    $scope.getCards = function() {
      $scope.cards = Restangular.one('games', 1).one('game_users', 1).getList('cards').$object;
    }
    $scope.getRations = function() {
      $scope.rations = Restangular.one('users', 1).one('game_users', 1).getList('rations').$object;
    }

    $scope.getCards();
    $scope.getRations();

    $scope.test = 'test true';

    $scope.newRation = {
      ingredients: [{card:{category: 'empty'}},{card:{category: 'empty'}},{card:{category: 'empty'}},{card:{category: 'empty'}}],
      setIngredients: function() {
        this.ingredients = [];
        console.log('setting ingredients');
        for (i in $scope.cards) {
          if ($scope.cards[i].used) {
            this.ingredients.push($scope.cards[i]);
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
        var guc = $scope.cards[i];
        if (guc && guc.card && typeof guc === 'object' && guc.card.category != 'action' && !$scope.cards[i].used) {
            console.log(guc);
            count++;
        }
      }
      return count;
    }

    $scope.countIngredients = function() {
      var count = 0;
      for (i in $scope.cards) {
        var guc = $scope.cards[i];
        if (guc && guc.card && typeof guc === 'object' && guc.card.category != 'action') {
            console.log(game_user_card);
            count++;
        }
      }
      return count;
    }

    $scope.countActions = function() {
      var count = 0;
      for (i in $scope.cards) {
        var game_user_card = $scope.cards[i];
        if (game_user_card && typeof game_user_card === 'object'
            && game_user_card.card.category && game_user_card.card.category == 'action') {
            console.log(game_user_card);
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
        card.remove();
        $scope.getCards();
      } else {
        // the card is an ingredient, so mark as used
        card.used = true;
        $scope.newRation.setIngredients();
      }
    };

  }
]);
