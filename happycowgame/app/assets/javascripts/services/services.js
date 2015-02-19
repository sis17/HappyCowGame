var services = angular.module('happyCowServices', ['ngResource']);

services.factory('User', ['$resource',
  function($resource) {
    return $resource('/users/:id', {id: '@id'});
  }
]);

services.factory('Card', ['$resource',
  function($resource) {
    return $resource('/cards/:id', {id: '@id'});
  }
]);

services.factory('Round', ['$resource',
  function($resource) {
    return $resource('/rounds/:id', {id: '@id'});
  }
]);

services.factory('Ration', ['$resource',
  function($resource) {
    return $resource('/rounds/:id', {id: '@id'});
  }
]);
