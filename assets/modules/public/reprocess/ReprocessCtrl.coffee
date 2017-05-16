app.controller "ReprocessCtrl", [
  "$scope", "$routeParams", "$http"
  ($scope, $rp, $http) ->
    # Get id from url
    url = window.location.pathname
    url = url.substring 13
    # Get quesy string answer value
    answer = window.location.search
    answer = answer.substring 8

    $http.get "/applicant/reply/#{url}?answer=#{answer}"
    .success (data) ->
      $scope.newApplication = data
      console.log 'newApplication: ', $scope.newApplication
]