app.controller "HomeCtrl", [
  "$scope"
  "$cookies"
  "$cookieStore"
  "toaster"
  ($scope,$cookies,$cookieStore,toaster) ->
    $scope.test = () ->
      console.log 'yo mama'
    $scope.vacancies = null
    $scope.active =
      company: {
        id: null
        name: 'Select Company'
        address: ''
      }

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
        $scope.applicant.data = {}
        $scope.applicant.data.companyId = $scope.active.company.id
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
      console.log(data)
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


    $scope.applicant =
      data: {}
      clicked: false
      save: ->
        if $scope.applicant.data.resume
          type = (if $scope.applicant.data.id then "put" else "post")
          $scope.applicant.data.companyId = if $scope.applicant.data.companyId then $scope.applicant.data.companyId else companyId
          console.log 'app data: ', $scope.applicant.data
          io.socket[type] "/applicant/create", $scope.applicant.data, (data, jwres) ->
            if data
              toaster.pop 'success', 'Success', 'Your application has been sent'
              # $scope.applicant.data = null
              $scope.applicant.data =
                question: {}
                resume: null
              $scope.$apply()
            else
              toaster.pop 'error', 'Error', 'There was some problem with you application'
        else
          toaster.pop 'warning', 'Warning', 'Please attach your latest résumé.'


    io.socket.get "/recruitment/counter", (data) ->
      $scope.vacancies = data.count
      $scope.$digest()

      io.socket.on "recruitment/list", (data) ->
        if data and data.method isnt 'UPDATE'
          $scope.vacancies += data.quota
        $scope.$digest()
]