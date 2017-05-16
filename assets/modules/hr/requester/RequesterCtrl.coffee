app.controller "RequesterCtrl", [
  "$scope"
  "$http"
  "USER"
  ($scope,$http,USER) ->
    $scope.loaded = false
    $scope.role = "requester"
    $http.get "/company/show/self"
    .success (data) ->
      $scope.companyId = data

      io.socket.get "/user/requester", (data, res) ->
        if res.statusCode is 200
          $scope.loaded = true
        $scope.requesters = data
        $scope.$digest()

      io.socket.on "user/#{$scope.companyId.company_id}/requester", (msg) ->
        if msg isnt undefined or msg isnt null
          if msg.hasOwnProperty('method')
            switch msg.method.method
              when 'DELETE'
                $idx = null
                $scope.requesters.forEach (user, index) ->
                  if user.id is msg.appuserId
                    $idx = index
                    return
                if $idx isnt null
                  $scope.requesters.splice $idx, 1
          else
            $idx = null
            $scope.requesters.forEach (requester, index) ->
              if requester.id is msg.id
                $idx = index
                return

            if $idx isnt null
              $scope.requesters[$idx] = msg
            else
              $scope.requesters.push msg

          $scope.$digest()


    $scope.remove = (data) ->
      io.socket.delete '/user/role', {id:data.id, role: "requester"}

    $scope.toggleSearch = (data) ->
      $scope.searchShown = !$scope.searchShown
]