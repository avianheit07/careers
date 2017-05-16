app.controller "RequesterCtrl", [
  "$scope"
  "$http"
  "USER"
  ($scope,$http,USER) ->
    $scope.companies = [
      {name:'meditab'},
      {name:'coke'},
      {name:'toyota'}
    ]

    $scope.role = "requester"
    $http.get "/company/show/self"
    .success (data) ->
      $scope.companyId = data

      io.socket.get "/user/requester", (data) ->
        $scope.requesters = data
        $scope.$digest()

      io.socket.on "user/#{$scope.companyId.company_id}/requester", (msg) ->
        console.log "listener", msg
        if msg isnt undefined or msg isnt null
          if msg.hasOwnProperty('method')
            switch msg.method.method
              when 'DELETE'
                console.log "listener method:delete"
                $idx = null
                $scope.requesters.forEach (user, index) ->
                  if user.id is msg.appuser_id
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
              console.log "put", msg
              $scope.requesters[$idx] = msg
            else
              console.log "push", msg
              $scope.requesters.push msg

          $scope.$digest()


    $scope.remove = (data) ->
      console.log "remove"
      io.socket.delete '/user/role', {id:data.id, role: "requester"}

    $scope.toggleSearch = (data) ->
      $scope.searchShown = !$scope.searchShown
]