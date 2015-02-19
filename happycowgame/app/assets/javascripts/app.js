var hcApp = angular.module('happyCow', [
  'ui.bootstrap', 'ngSanitize', 'ngRoute',
  'happyCowServices'
]);

hcApp.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/phase/event', {
        templateUrl: 'templates/phase/event.html',
        controller: 'EventCtrl'
      }).
      when('/phase/cards', {
        templateUrl: 'templates/phase/cards.html',
        controller: 'CardsCtrl'
      }).
      when('/phase/movement', {
        templateUrl: 'templates/phase/movement.html',
        controller: 'MovementCtrl'
      }).
      when('/phase/review', {
        templateUrl: 'templates/phase/review.html',
        controller: 'ReviewCtrl'
      }).
      otherwise({
        redirectTo: '/'
      });
  }]);
