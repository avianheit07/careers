app.controller "ApplicantCtrl", [
  "$scope"
  "$http"
  ($scope,$http) ->
    $scope.ads = []
    $scope.options = [
      {value:'0', name:'All Applicants'}
      {value:'1', name:'General Applicants'}
    ]

    $scope.active =
      ad: null
      applicant: null

    $scope.search = (data) ->
      if $scope.filter is '0'
        return data
      else if $scope.filter is '1'
        if !data.recruitmentAd
          return data

    $scope.recruitmentAdModal = false

    $scope.applicant =
      select: (a) ->
        $scope.active.ad = a
      assign: ->
        $scope.active.applicant.recruitmentAd = $scope.active.ad
        $scope.applicants.forEach (item,index) ->
          if item.id is $scope.active.applicant.id
            io.socket.put "/applicant/create", item, (data, jwres) ->
              if data
                $scope.applicant.hideModal()

      toggleModal: (applicant) ->
        $scope.recruitmentAdModal = !$scope.recruitmentAdModal
        $scope.active.applicant = applicant
      hideModal: ->
        $scope.recruitmentAdModal = false

    $http.get "/company/show/self"
    .success (data) ->
      $scope.companyId = data
      $scope.active =
        view: 'ads'

      io.socket.get "/applicant/list", (data) ->
        $scope.applicants = data
        console.log 'applicants: ',  $scope.applicants
        $scope.$digest()

      io.socket.on "applicant/list", (msg) ->
        $scope.applicants.push msg
        $scope.$digest()

      io.socket.get "/recruitment/list", (data) ->
        $scope.ads = data
        $scope.$digest()

      # io.socket.on "recruitment/#{$scope.companyId.company_id}/company", (msg) ->
      #   $scope.ads.push msg
      #   $scope.$digest()

      # io.socket.get '/position/list', (data) ->
      #   $scope.positions = data
      #   $scope.$digest()
      # io.socket.on "position/#{$scope.companyId.company_id}/company", (msg) ->
      #   if msg?
      #     if msg.hasOwnProperty('method')
      #       switch msg.method.method
      #         when 'DELETE'
      #           $idx = null
      #           $scope.positions.forEach (pos, index) ->
      #             if pos.id is msg.id
      #               $idx = index
      #               return
      #           if $idx isnt null
      #             $scope.positions.splice $idx, 1
      #     else
      #       $idx = null
      #       $scope.positions.forEach (pos, index) ->
      #         if pos.id is msg.id
      #           $idx = index
      #           return

      #       if $idx isnt null
      #         $scope.positions[$idx] = msg
      #       else
      #         $scope.positions.push msg
      #     $scope.$digest()

      # $scope.ad =
      #   select: (id, index) ->
      #     $scope.activeIndex = index
      #     $scope.active.view = 'applicants'
      #     io.socket.get "/applicant/show/#{id}", (data) ->
      #       $scope.applicants = data
      #       $scope.$digest()

      #     io.socket.on "applicants/#{id}/ad", (msg) ->
      #       if $scope.applicants
      #         $scope.applicants.push msg
      #         $scope.$digest()
]