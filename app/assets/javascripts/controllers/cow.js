var cowCtrl = angular.module('happyCow').controller('CowCtrl', [
  '$scope',
  function($scope) {
    $scope.cowStatsTemplate = 'templates/cow/stats.html';
    $scope.showWelfare = 'hidden';
    $scope.showBodyCondition = 'hidden';
    $scope.showRumen = 'hidden';
    $scope.showMuck = 'hidden';
    $scope.showOligos = 'hidden';

    $scope.$watch('game.cow', function(newValue, oldValue) {
      if ($scope.game) {
          $scope.rumenStat = {
            title: 'rumen_ph',
            info: {
              water: $scope.game.countIngredientsInArea('water',3),
              energy: $scope.game.countIngredientsInArea('energy',3)
            },
            name: 'Rumen PH', min: 4.8, minType: 'danger', max: 7.6, maxType: 'danger',
            value: $scope.game.cow.ph_marker,
            type: function() {
              var pad = "00";
              var red = Math.abs(6.5 - this.value)*231; // max is 1.1 * 231 will give 255
              var green = (this.value*39.23) / ((Math.abs(6.5 - this.value)+1)*1.5); // the lower red is, the higher green is
              red = (pad+(Math.round(red).toString(16))).slice(-pad.length);
              green = (pad+(Math.round(green).toString(16))).slice(-pad.length);
              var blue = '00';
              return red+green+blue;
            }
          };
         $scope.welfareStat = {
           title: 'welfare', info: {},
           name: 'Welfare', min: -7, minType: 'danger', max: 6, maxType: 'success',
           value: $scope.game.cow.welfare,
           type: function() {
             if (this.value <= -5) { return 'd9534f'} //danger
             if (this.value <= -2) {return 'f0ad43'} //warning
             if (this.value <= 2) {return '5bc0de'} //info
             else {return '5cb85c'} //success
           }
         };
        $scope.bodyConditionStat = {
          title: 'body_condition', info: {},
          name: 'Body Cond.', min: -3, minType: 'danger', max: 3, maxType: 'success',
          value: $scope.game.cow.body_condition,
          type: function() {
            if (this.value <= -1) { return 'd9534f'}
            if (this.value <= 0) {return '5bc0de'}
            else {return '5cb85c'}
          }
        };
        $scope.muckStat = {
          title: 'muck', info: {},
          name: 'Muck', min: 0, minType: 'success', max: 6, maxType: 'danger', value: $scope.game.cow.muck_marker,
          type: function() {
            return 'f0ad43'; //warning
          }
        };
        $scope.oligosStat = {
          title: 'oligos', info: {},
          name: 'Oligos', min: 0, minType: 'success', max: 3, maxType: 'danger', value: $scope.game.cow.oligos_marker,
          type: function() {
            return 'danger'; //warning
          }
        }
      }
    });

  }
]);

cowCtrl.controller('IngredientValueCtrl', [
  '$scope',
  function($scope) {

  }
]);

cowCtrl.controller('CowEventsCtrl', [
  '$scope', '$sce', 'Restangular',
  function($scope, $sce, Restangular) {
    $scope.$watch('game.cow.weather_id', function() {
       if ($scope.game && $scope.game.cow.weather_id)
          $scope.weather = Restangular.one('events',$scope.game.cow.weather_id).get().$object;
    });
    $scope.$watch('game.cow.disease_id', function() {
       if ($scope.game && $scope.game.cow.disease_id)
          $scope.disease = Restangular.one('events',$scope.game.cow.disease_id).get().$object;
    });
    $scope.$watch('game.cow.pregnancy_id', function() {
       if ($scope.game && $scope.game.cow.pregnancy_id)
          $scope.pregnancy = Restangular.one('events', $scope.game.cow.pregnancy_id).get().$object;
    });
  }
]);
