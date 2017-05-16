app.controller "AdCtrl", [
  "$scope"
  "$http"
  "$location"
  "USER"
  "$rootScope"
  "toaster"
  ($scope, $http, $location, USER, $root, toaster) ->
    $scope.positions = []
    $scope.companies = []
    $scope.companyId = undefined
    $scope.ads = []

    $scope.active    =
      ad: null
      applications: null
      adApplicants: []
      modal: 'request'
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
        if type is 'post'
          io.socket[type] "/recruitment/create", requestData, (data, jwres) ->
            if data
              toaster.pop 'success', 'Success', 'Request has been saved'
              $scope.hideModal()
            else
              toaster.pop 'error', 'Error', 'Request was not saved'

        else if type is 'put'
          io.socket[type] "/recruitment/update", requestData, (data, jwres) ->
            if data
              toaster.pop 'success', 'Success', 'Request has been saved'
              $scope.hideModal()
            else
              toaster.pop 'error', 'Error', 'Request was not saved'
      # Sorting of recruitment ads
      sort: (what,id,idx) ->
        $scope.ads.forEach (item) ->
          if item.id is id
            length  = $scope.ads.length
            # Checks if update is up or down and check if it is top of the list
            if what is 'up' and idx isnt 0
              weight  = $scope.ads[idx-1].weight
              item.weight = weight + 1
              io.socket.put "/recruitment/update", item, (data, jwres) ->
            # Checks if update is up or down and check if it is at the bottom of the list
            else if what is 'down' and idx + 1 isnt length
              weight = $scope.ads[idx+1].weight
              item.weight = weight - 1
              io.socket.put "/recruitment/update", item, (data, jwres) ->

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
      }
      $scope.modalShown = !$scope.modalShown

    $scope.hideModal = () ->
      $scope.modalShown = false
      $scope.active.modal = 'request'


    $scope.showApplicants       = (ad) ->
      if ad
        $scope.active.ad = ad
        # $scope.active.applications = $scope.active.adApplicants[ad.id].newApplicants.concat($scope.active.adApplicants[ad.id].processing)
        # console.log 'active applicationssss: ', $scope.active.applications
        # Service for passing active ad and its corresponding applications to AdApplicantCtrl
        # share.set $scope.active.ad, $scope.ads, $scope.active.applications


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

      select: (what,data,idx,filter) ->
        obj = {
          id: data.id
          email: data.email
        }
        switch what
          when 'man'
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


    $scope.counter =
      add: ->
        $scope.request.data.quota++
      subtract: ->
        # if @quota is 1
        #   @quota = @quota
        # else
        #   @quota--
        #   $scope.request.data.quota = @quota
        if $scope.request.data.quota isnt 1
          $scope.request.data.quota--


    io.socket.get "/user/requester", (data) ->
      $scope.requesters = data
      $scope.$digest()

    io.socket.on "user/requester", (msg) ->

      if msg isnt undefined or msg isnt null
        if msg.hasOwnProperty('method')
          switch msg.method.method
            when 'DELETE'
              $scope.requesters.splice msg.method.index, 1
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

    $http.get "/company/show/self"
    .success (data) ->
      $scope.companyId = data

      io.socket.get "/recruitment/list", (data) ->
        $scope.ads = data
        console.log 'ads: ', $scope.ads
        $scope.ads.forEach (each) ->
          $scope.active.adApplicants[each.id] =
            newApplicants: []
            processing: []
          io.socket.on "applicant/#{each.id}/ad", (msg) ->
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

            # Checks first if the active application is equal to the received socket response
            if $scope.active.ad.applicants? and $scope.active.ad.id is msg.recruitmentAd.id
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
              # Changing of process or verification of applicants
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

        io.socket.get '/applicant/list', (data) ->
          $scope.applicants = data
          $scope.applicants.forEach (each) ->
            if each.recruitmentAd
              if each.processes.length > 0
                $scope.active.adApplicants[each.recruitmentAd.id].processing.push each
              else
                $scope.active.adApplicants[each.recruitmentAd.id].newApplicants.push each

        $scope.$digest()

      io.socket.on "recruitment/#{$scope.companyId.company_id}/company", (msg) ->
        if msg.method is 'UPDATE'
          $scope.ads.forEach (ad)->
            if ad.id is msg.id
              msg.applicants = ad.applicants
              msg.position = ad.position
              for key of msg
                ad[key] = msg[key]
              $scope.$digest()
        else
          $scope.ads.push msg
        $scope.ads.sort (a, b) ->
          return -1 if a.weight > b.weight
          return 1 if a.weight < b.weight
          return 0
        $scope.$digest()

      io.socket.get '/position/list', (data) ->
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