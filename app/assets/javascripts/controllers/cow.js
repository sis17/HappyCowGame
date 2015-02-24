var cowCtrl = angular.module('happyCow').controller('CowCtrl', [
  '$scope',
  function($scope) {
    return $scope;
  }
]);

cowCtrl.controller('CowStatsCtrl', [
  '$scope',
  function($scope) {
    $scope.stats = [
      {
        name: 'Welfare', min: -7, minType: 'danger', max: 6, maxType: 'success', value: -2,
        type: function() {
          if (this.value <= -5) { return 'd9534f'} //danger
          if (this.value <= -2) {return 'f0ad43'} //warning
          if (this.value <= 2) {return '5bc0de'} //info
          else {return '5cb85c'} //success
        }
      },
      {
        name: 'Body Condition', min: -3, minType: 'danger', max: 3, maxType: 'success', value: 2,
        type: function() {
          if (this.value <= -1) { return 'd9534f'}
          if (this.value <= 0) {return '5bc0de'}
          else {return '5cb85c'}
        }
      },
      {
        name: 'Rumen PH', min: 4.8, minType: 'warning', max: 7.6, maxType: 'success', value: 5.4,
        type: function() {
          if (this.value <= 5.6) { return 'f0ad43'}
          if (this.value <= 7.0) {return '5bc0de'}
          else {return '5cb85c'}
        }
      },
      {
        name: 'Muck', min: 0, minType: 'success', max: 6, maxType: 'danger', value: 3,
        type: function() {
          return 'f0ad43'; //warning
        }
      },
      {
        name: 'Oligos', min: 0, minType: 'success', max: 3, maxType: 'danger', value: 1,
        type: function() {
          return 'danger'; //warning
        }
      }
    ];
  }
]);

cowCtrl.controller('IngredientValueCtrl', [
  '$scope',
  function($scope) {
    $scope.ingredients = [
      {name: 'Energy', milk: 6, meat: 2, muck: 1},
      {name: 'Protein', milk: 3, meat: 4, muck: 1},
      {name: 'Fiber', milk: 2, meat: 2, muck: 1},
      {name: 'Water', milk: 1, meat: 1, muck: 1},
      {name: 'Oligos', milk: 10, meat: 10, muck: 1}
    ];
  }
]);

cowCtrl.controller('CowEventsCtrl', [
  '$scope', '$sce',
  function($scope, $sce) {

    $scope.weather = {
      title: 'It\'s Cold',
      img: 'events/weather/cold-1.png',
      content: $sce.trustAsHtml('<p>The cow eats one extra ration per turn.</p>'+
      '<p>-1 to all rations when absorbed.</p>'+
      '<p>This stays until replaced by another weather event.</p>')
    };

    $scope.disease = {
      title: 'Constipation',
      img: 'events/disease/constipation-1.png',
      content: $sce.trustAsHtml('<p>Play only the lowest dice to move in the intestines.</p>'+
      '<p>-1 to Welfare.</p>'+
      '<p>This stays until replaced by another disease, or is cured.</p>')
    };

    $scope.pregnancy = {
      title: 'The Cow is Pregnant',
      img: 'events/pregnancy/yes-1.png',
      content: $sce.trustAsHtml('<p>The milk position becomes another meat position, all the milk goes to the calf, so cannot earn points during pregnancy.</p>'+
      '<p>This stays until the calf is born.</p>')
    };
  }
]);
