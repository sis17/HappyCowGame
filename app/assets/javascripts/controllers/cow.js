var cowCtrl = angular.module('happyCow').controller('CowCtrl', [
  '$scope',
  function($scope) {
    return $scope;
  }
]);

cowCtrl.controller('CowStatsCtrl', [
  '$scope',
  function($scope) {

    $scope.$watch('game.cow', function(newValue, oldValue) {
        //console.log('CowStatsCtrl: a cow change occured - '+newValue);
        if ($scope.game) {
    $scope.stats = [
      {
        name: 'Welfare', min: -7, minType: 'danger', max: 6, maxType: 'success', value: $scope.game.cow.welfare,
        type: function() {
          if (this.value <= -5) { return 'd9534f'} //danger
          if (this.value <= -2) {return 'f0ad43'} //warning
          if (this.value <= 2) {return '5bc0de'} //info
          else {return '5cb85c'} //success
        }
      },
      {
        name: 'Body Condition', min: -3, minType: 'danger', max: 3, maxType: 'success', value: $scope.game.cow.body_condition,
        type: function() {
          if (this.value <= -1) { return 'd9534f'}
          if (this.value <= 0) {return '5bc0de'}
          else {return '5cb85c'}
        }
      },
      {
        name: 'Rumen PH', min: 4.8, minType: 'warning', max: 7.6, maxType: 'success', value: $scope.game.cow.ph_marker,
        type: function() {
          if (this.value <= 5.6) { return 'f0ad43'}
          if (this.value <= 7.0) {return '5bc0de'}
          else {return '5cb85c'}
        }
      },
      {
        name: 'Muck', min: 0, minType: 'success', max: 6, maxType: 'danger', value: $scope.game.cow.muck_marker,
        type: function() {
          return 'f0ad43'; //warning
        }
      },
      {
        name: 'Oligos', min: 0, minType: 'success', max: 3, maxType: 'danger', value: $scope.game.cow.oligos_marker,
        type: function() {
          return 'danger'; //warning
        }
      }
    ];
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
       //console.log('cow weather has changed');
       if ($scope.game && $scope.game.cow.weather_id)
          $scope.weather = Restangular.one('events',$scope.game.cow.weather_id).get().$object;
    });
    $scope.$watch('game.cow.disease_id', function() {
       //console.log('cow disease has changed');
       if ($scope.game && $scope.game.cow.disease_id)
          $scope.disease = Restangular.one('events',$scope.game.cow.disease_id).get().$object;
    });
    $scope.$watch('game.cow.pregnancy_id', function() {
       //console.log('cow pregnancy has changed');
       if ($scope.game && $scope.game.cow.pregnancy_id)
          $scope.pregnancy = Restangular.one('events', $scope.game.cow.pregnancy_id).get().$object;
    });
  }
]);
