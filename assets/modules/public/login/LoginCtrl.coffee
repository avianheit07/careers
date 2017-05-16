app.controller "LoginCtrl", [
  "$scope"
  ($scope) ->
    $scope.google = ->
      document.location = "/auth/google"
    return
]