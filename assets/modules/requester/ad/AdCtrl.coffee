app.controller "AdCtrl", [
  "$scope"
  "$http"
  "$location"
  "USER"
  "toaster"
  ($scope, $http, $location, USER, toaster) ->
    $scope.positions = []
    $scope.companies = []
    $scope.companyId = undefined
    $scope.ads = []

    $scope.active    =
      ad: null
      applications: null
      adApplicants: []
      modal: 'request'
      user: null
      toggleModal: (what) ->
        @modal = what

    $scope.request =
      data: {
        quota: 1
      }
      positionFilter: (position) ->
        if $scope.request.data and $scope.request.data.hasOwnProperty("position")
          return position
      save: () ->
        requestData = angular.fromJson(angular.toJson($scope.request.data))
        type = (if requestData.id then "put" else "post")
        io.socket[type] "/recruitment/create", requestData, (data, jwres) ->
          if data
            toaster.pop 'success', 'Success', 'Request has been saved'
            $scope.hideModal()
          else
            toaster.pop 'error', 'Error', 'Request was not saved'

    $scope.select = (a) ->
      i = null
      $scope.ads.forEach (item,index) ->
        if item.id is a.id
          i = index
      value = i
      $scope.request.index = value
      $scope.modalShown = !$scope.modalShown
      $scope.request.data = $scope.ads[value]

    $scope.selected = (index) ->
      return index is $scope.request.index

    # modal for positions, create and update
    $scope.modalShown  = false

    $scope.toggleModal = () ->
      $scope.request.data = {
        quota: 1
        api_user: $scope.userId
      }
      $scope.modalShown = !$scope.modalShown

    $scope.hideModal = () ->
      $scope.modalShown = false
      $scope.active.modal = 'request'


    $scope.user =
      search_man: ''
      search_exa: ''
      search_int: ''
      find: (what) ->
        switch what
          when 'man'
            if @search_man.length >= 3
              $http.get '/user/search?search='+@search_man
              .success (data) ->
                $scope.users_man = data
          when 'exa'
            if @search_exa.length >= 3
              $http.get '/user/search?search='+@search_exa
              .success (data) ->
                $scope.users_exa = data
          when 'int'
            if @search_int.length >= 3
              $http.get '/user/search?search='+@search_int
              .success (data) ->
                $scope.users_int = data

      select: (what,data,assign,filter) ->
        obj = {
          id: data.id
          email: data.email
        }
        switch what
          when 'man'
            # $scope.positions.forEach (position, index) ->
            #   position.process_filter.forEach (filter, index) ->
            #     filter.assigned = obj
            filter.assigned = obj
            @search_man = ''
          when 'exa'
            filter.assigned = obj
            @search_exa = ''
          when 'int'
            filter.assigned = obj
            @search_int = ''

      remove: (what) ->
        switch what
          when 'man'
            $scope.position.man.assigned = null
          when 'exa'
            $scope.position.exa.assigned = null
          when 'int'
            $scope.position.int.assigned = null

    $scope.showApplicants       = (ad) ->
      if ad
        $scope.active.ad           = ad
      #   $scope.active.applications = $scope.active.adApplicants[ad.id].newApplicants.concat($scope.active.adApplicants[ad.id].processing)

    $scope.counter =
      add: ->
        $scope.request.data.quota++
      subtract: ->
        if @quota is 1
          @quota = @quota
        else
          if $scope.request.data.quota isnt 1
            $scope.request.data.quota--


    $http.get "/user/session"
    .success (session) ->
      $scope.userId    = session.appuser
      $scope.companyId = session.company

      io.socket.get "/user/show/self", (data) ->
        $scope.active.user = data
        $scope.request.data.api_user = $scope.active.user.id
        $scope.$digest()

      io.socket.get "/recruitment/list/?appuser=#{$scope.userId}", (data) ->
        $scope.ads = data
        console.log 'ads: ', $scope.ads
        $scope.ads.forEach (each) ->
          $scope.active.adApplicants[each.id] =
            newApplicants: []
            processing: []
          io.socket.on "applicant/#{each.id}/ad", (msg) ->
            console.log 'msg: ', msg
            rid = if typeof msg.recruitmentAd is 'object' then msg.recruitmentAd.id else msg.recruitmentAd
            if msg.processes?
              if msg.processes.length > 0 and msg.processes.length is 1
                if msg.status isnt 3 and msg.status isnt 4
                  $scope.active.adApplicants[rid].processing.push msg
                  appIdx = $scope.active.adApplicants[rid].newApplicants.map( (row) -> row.id).indexOf(msg.id)

                  if appIdx > -1
                    $scope.active.adApplicants[rid].newApplicants.splice(appIdx, 1)
              else if msg.processes.length is 0
                $scope.active.adApplicants[rid].newApplicants.push msg
                console.log 'inner else'
            else
              # Push new applicant(s) to specific recruitmentAd
              if !msg.newApplication
                if msg.status is 4
                  match = null
                  # Set match true if duplicate is detected
                  $scope.active.adApplicants[rid].newApplicants.forEach (data) ->
                    if data.id is msg.id
                      match = true

                  if match isnt true
                    $scope.active.adApplicants[rid].newApplicants.push msg
                else
                  $scope.active.adApplicants[rid].newApplicants.push msg


            $scope.$digest()

            if $scope.active.ad and $scope.active.ad.applicants? and $scope.active.ad.id is msg.recruitmentAd.id
              if msg.hasOwnProperty('method')
                switch msg.method.method
                  when 'DELETE'
                    $idx = null
                    $scope.active.ad.applicants.forEach (pos, index) ->
                      if pos.id is msg.id
                        $idx = index
                        return
                    if $idx isnt null
                      $scope.active.ad.applicants.splice $idx, 1
              else
                $idx = null
                $scope.active.ad.applicants.forEach (pos, index) ->
                  if pos.id is msg.id
                    $idx = index
                    return

                if $idx isnt null
                  $scope.active.ad.applicants[$idx] = msg
                else
                  $scope.active.ad.applicants.push msg

              $scope.$digest()
            $scope.$digest()
            # $scope.active.adApplicants[msg.recruitmentAd].push msg
            # $scope.$digest()

        io.socket.get '/applicant/list', (data) ->
          $scope.applicants = data
          $scope.applicants.forEach (each) ->
            if each.recruitmentAd
              if typeof $scope.active.adApplicants[each.recruitmentAd.id] isnt 'undefined'
                if each.processes.length > 0
                    $scope.active.adApplicants[each.recruitmentAd.id].processing.push each
                else
                  $scope.active.adApplicants[each.recruitmentAd.id].newApplicants.push each

        $scope.$digest()

      io.socket.on "recruitment/#{$scope.userId}/user", (msg) ->
        $scope.ads.push msg
        $scope.$digest()

      io.socket.get '/position/list/self', (data) ->
        $scope.positions = data
        $scope.$digest()
      io.socket.on "position/#{$scope.companyId.company_id}/company", (msg) ->
        if msg?
          if msg.hasOwnProperty('method')
            switch msg.method.method
              when 'DELETE'
                $idx = null
                $scope.positions.forEach (pos, index) ->
                  if pos.id is msg.id
                    $idx = index
                    return
                if $idx isnt null
                  $scope.positions.splice $idx, 1
          else
            $idx = null
            $scope.positions.forEach (pos, index) ->
              if pos.id is msg.id
                $idx = index
                return

            if $idx isnt null
              $scope.positions[$idx] = msg
            else
              $scope.positions.push msg
          $scope.$digest()

    $scope.applicant =
      data: {}
      save: () ->
        $scope.applicant.data.recruitmentAd = $scope.request.data
        $scope.applicant.data.question.question = $scope.request.data.question
        applicantData = angular.fromJson(angular.toJson($scope.applicant.data))
        type = (if applicantData.id then "put" else "post")
        io.socket[type] "/applicant/create", applicantData, (data, jwres) ->
          if data
            toaster.pop 'success', 'Success', 'Applicant has been saved'
            $scope.hideModal()
          else
            toaster.pop 'error', 'Error', 'Applicant was not saved'

    $scope.getHired = (ad) ->
      hired = 0
      ad.applicants.forEach (item,index) ->
        if item.status is 2
          hired++
      return hired

]