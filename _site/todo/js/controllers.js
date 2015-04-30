'use strict';

/* Controllers */

var todo = angular.module('todo', []);

todo.service('storage', function() {
  return {
    add: function(todo) {
      var todos = this.get();
      todo.id = todos.length+1;
      todos.push(todo);
      return localStorage.setItem('todos', JSON.stringify(todos));
    },
    set: function(todos) {
      return localStorage.setItem('todos', JSON.stringify(todos));
    },
    get: function() {
      return localStorage.getItem('todos') ?
                JSON.parse(localStorage.getItem('todos')) :
                [];
    }
  };
});

todo.controller('TodoListCtl', ['$scope', 'storage',
function($scope, storage) {

  $scope.add = function(todo) {
    storage.add({title: todo.title, complete: false});
    $scope.todos = storage.get();
    todo.title = '';
  };

  $scope.complete = function(todo) {
    var todos = storage.get();
    // find the todo with the set id, and mark it complete
    for (var t = 0; t < todos.length; t++) {
      if (todos[t].id === todo.id) {
        todos[t].complete = true;
      }
    }
    // update the storage and page
    storage.set(todos);
    $scope.todos = todos;
  };

  $scope.showEdit = function(todo) {
    todo.showEdit = true;
  };

  $scope.edit = function(todo) {
    todo.showEdit = false;
    var todos = storage.get();
    // find the todo with the set id, and mark it complete
    for (var t = 0; t < todos.length; t++) {
      if (todos[t].id === todo.id) {
        console.log('setting title: '+ todo.title);
        todos[t].title = todo.title;
      }
    }
    // update the storage and page
    storage.set(todos);
    $scope.todos = todos;
  }

  $scope.clearAll = function() {
    storage.set([]);
    $scope.todos = storage.get();
  };

  $scope.clear = function() {
    var todos = storage.get();
    var newTodos = [];
    for (var t = 0; t < todos.length; t++) {
      if (!todos[t].complete) {
        newTodos.push(todos[t]);
      }
    }
    // update the storage and page
    storage.set(newTodos);
    $scope.todos = newTodos;
  };

  $scope.countTodo = function() {
    var todo = 0;
    var todos = storage.get();
    for (var t = 0; t < todos.length; t++) {
      if (!todos[t].complete) {
        todo++;
      }
    }
    return todo;
  };

  $scope.countComplete = function() {
    var complete = 0;
    var todos = storage.get();
    for (var t = 0; t < todos.length; t++) {
      if (todos[t].complete) {
        complete++;
      }
    }
    return complete;
  };

  $scope.todos = storage.get();
}]);
