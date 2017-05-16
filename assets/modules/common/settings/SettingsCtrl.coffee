app.controller "SettingsCtrl", [
  "$scope"
  "$http"
  "$timeout"
  ($scope,$http,$timeout) ->
    $scope.pass =
      data: {}
      message: ""
      submit: ->
        if @data.password and @data.newPassword and @data.newPassword is @data.newPasswordCopy
          $http.post("/user/password", @data).success (data) ->
            if data
              $scope.pass.message = data.message
              $scope.pass.data = {}
              $timeout (->
                $scope.pass.message = ""
                return
              ), 2000

        else unless @data.password
          @message = "please provide existing password"
          $timeout (->
            $scope.pass.message = ""
            return
          ), 2000
        else
          @message = "please provide new password or password copy does not match"
          $timeout (->
            $scope.pass.message = ""
            return
          ), 2000
        return
]