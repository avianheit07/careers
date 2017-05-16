app.controller "TrackerCtrl", [
  "$scope", "$routeParams", "$http"
  ($scope, $rp, $http) ->
    $http.get "/applicant/tracker/#{$rp.code}"
    .success (data) ->
      $scope.application = data
      console.log 'application: ', $scope.application

    # $http.get '/user/search?search='+@search_man
    # .success (data) ->
    #   $scope.users_man = data

    # $scope.company =
    #   select: (id,index) ->
    #     $scope.activeIndex = index
    #
    # io.socket.get "/company/list", (data) ->
    #   $scope.companies = data
    #   $scope.$digest()

]