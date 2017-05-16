app.controller "AdCtrl", [
  "$scope"
  "$cookies"
  "$cookieStore"
  "toaster"
  "$routeParams"
  ($scope,$cookies,$cookieStore,toaster,$routeParams) ->
    $scope.active =
      company: {
        id: null
        name: 'Select Company:'
        address: ''
      }
      ad: null
      data: {
        question: {}
      }
      save: ->
        if $scope.active.data.resume
          type = (if $scope.active.data.id then "put" else "post")
          console.log 'act data: ', $scope.active.data
          io.socket[type] "/applicant/create", $scope.active.data, (data, jwres) ->
            if data
              toaster.pop 'success', 'Success', 'Your application has been sent'
              # $scope.active.data = null
              $scope.active.data =
                question: {}
                recruitmentAd: $scope.active.ad
                resume: null
              $scope.$apply()
            else
              toaster.pop 'error', 'Error', 'Your application was not sent'
        else
          console.log 'way resume'
          toaster.pop 'warning', 'Warning', 'Please attach your latest résumé.'


    # Set cookie values
    companyId = $cookies.companyId
    companyName = $cookies.companyName
    companyAddress = $cookies.companyAddress
    if companyId and companyName and companyAddress
      $scope.active.company.id = companyId
      $scope.active.company.name = companyName
      $scope.active.company.address = companyAddress
      io.socket.get "/recruitment/list/"+companyId, (data) ->
        $scope.ads = data
        $scope.$digest()

        i = null
        $scope.ads.forEach (item,index) ->
          if item.id is $routeParams.id
            console.log 'acitve ad: ', item
            i = index
        $scope.active.ad = $scope.ads[i]
        $scope.active.data.recruitmentAd = $scope.active.ad
        $scope.active.data.question.question = $scope.active.ad.question


    $scope.company =
      assign: (company) ->
        $cookies.companyId = company.id
        $cookies.companyName = company.name
        $cookies.companyAddress = company.address

        $scope.active.company.id = company.id
        $scope.active.company.name = company.name
        $scope.active.company.address = company.address
        $scope.company.select()
      select: ->
        $scope.active.ad = null
        io.socket.get "/recruitment/list/"+$scope.active.company.id, (data) ->
          $scope.ads = data
          $scope.$digest()

    io.socket.on "recruitment/#{$scope.active.company.id}/company", (msg) ->
      if msg.method is 'UPDATE'
        angular.forEach $scope.ads, (value, idx) ->
          if value.id is msg.id
            msg.applicants = value.applicants
            msg.position = value.position
            $scope.ads[idx] = msg
      else if $scope.ads
        $scope.ads.push msg
      $scope.ads.sort (a, b) ->
        return -1 if a.weight > b.weight
        return 1 if a.weight < b.weight
        return 0
      $scope.$digest()

    io.socket.get "/company/list", (data) ->
      $scope.companies = data
      $scope.$digest()

    io.socket.on "company/list", (msg) ->
      if msg isnt undefined or msg isnt null
        if msg.hasOwnProperty('method')
          switch msg.method.method
            when 'DELETE'
              $idx = null
              $scope.companies.forEach (company, index) ->
                if company.id is msg.id
                  $idx = index
                  return
              if $idx isnt null
                $scope.companies.splice msg.method.index, 1
        else
          $idx = null
          $scope.companies.forEach (company, index) ->
            if company.id is msg.id
              $idx = index
              return

          if $idx isnt null
            $scope.companies[$idx] = msg
          else
            $scope.companies.push msg

      $scope.$digest()
]