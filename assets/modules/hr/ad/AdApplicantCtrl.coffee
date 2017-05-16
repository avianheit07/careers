app.controller "AdApplicantCtrl", [
  "$scope"
  "$http"
  "$location"
  "USER"
  "$rootScope"
  "$routeParams"
  "toaster"
  ($scope, $http, $location, USER, $root, $routeParams, toaster) ->
    $scope.active =
      ad: null
      applications: null
      adApplicants: []

    $scope.recruitmentAdModal = false

    io.socket.get "/recruitment/list", (data) ->
      $scope.ads = data
      $scope.$digest()

    io.socket.get "/recruitment/show/#{$routeParams.id}", (data) ->
      $scope.active.ad = data
      console.log 'active.ad: ', $scope.active.ad
      $scope.ads.forEach (ad) ->
        $scope.active.ad.applicants.forEach (applicant) ->
          if ad.id is applicant.recruitmentAd
            applicant.recruitmentAd = ad

      $scope.active.adApplicants[$scope.active.ad.id] =
        newApplicants: []
        processing: []

      $scope.$digest()

      io.socket.on "applicant/#{$routeParams.id}/ad", (msg) ->
        if msg.processes?
          if msg.processes.length > 0 and msg.processes.length is 1
            $scope.active.adApplicants[$routeParams.id].processing.push msg
            appIdx = $scope.active.adApplicants[$routeParams.id].newApplicants.map((row) -> row.id).indexOf(msg.id)

            if appIdx > -1
              $scope.active.adApplicants[$routeParams.id].newApplicants.splice(appIdx, 1)
          else if msg.processes.length is 0
            $scope.active.adApplicants[$routeParams.id].newApplicants.push msg
          $scope.$digest()
        else
          # Push new applicant(s) to specific recruitmentAd
          $scope.active.adApplicants[$routeParams.id].newApplicants.push msg
          $scope.$digest()

        # Checks first if the active application is equal to the received socket response
        if $scope.active.ad.applicants? and $scope.active.ad.id is $routeParams.id
          if msg.hasOwnProperty('method')
            switch msg.method.method
              when 'DELETE'
                idx = null
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


    $scope.options =
      questions: []
      activeId: null
      verification: [
        {name:'NEW', value:0}
        {name:'VERIFIED', value:1}
        {name:'UNVERIFIED', value:2}
      ]
      recommendation: [
        {name:'UNPROCESSED', value:0}
        {name:'RECOMMEND', value:1}
        {name:'NOT RECOMMEND', value:2}
      ]
      examination: [
        {name:'UNPROCESSED', value:0}
        {name:'PASSED', value:1}
        {name:'FAILED', value:2}
      ]
      interview: [
        {name:'UNPROCESSED', value:0}
        {name:'NOT RECOMMEND', value:2}
        {name:'RECOMMEND', value:1}
      ]
      toggleModal: (what,a,questions) ->
        switch what
          when 'interview'
            $scope.interviewModal = !$scope.interviewModal
            @questions = questions
            @activeId = a.id
          when 'recruitmentAd'
            $scope.recruitmentAdModal = !$scope.recruitmentAdModal
            $scope.reprocess.active.application = a

      hideModal: (what) ->
        switch what
          when 'interview'
            $scope.interviewModal = false
          when 'recruitmentAd'
            $scope.recruitmentAdModal = false

      select: (what,id,data) ->
        $scope.active.ad.applicants.forEach (item,index) ->
          if item.id is id
            switch what
              when 'reprocess'
                io.socket.put "/applicant/update", item, (data, jwres) ->
                  if data
                    console.log 'new: ', data
              when 'new'
                item.applicant.status = data.value
                io.socket.put "/applicant/update", item, (data, jwres) ->
                  if data
                    console.log 'new: ', data

              when 'manual'
                item.processes[item.processes.length-1].status = data.value
                # if data.value is 1
                io.socket.put "/process/update", item, (data, jwres) ->

              when 'exam'
                if item.processes[item.processes.length-1].processData.inputScore >= item.processes[item.processes.length-1].processData.score
                  item.processes[item.processes.length-1].status = 1
                else
                  item.processes[item.processes.length-1].status = 2

                if data is 'recommend'
                  item.processes[item.processes.length-1].recommend = true
                else if data is 'unrecommmend'
                  item.processes[item.processes.length-1].recommend = false

                io.socket.put "/process/update", item, (data, jwres) ->
                  if data
                    console.log 'exam: ', data

              when 'interview'
                item.processes[item.processes.length-1].status = data.value
                item.processes[item.processes.length-1].processData.questions = angular.fromJson(angular.toJson($scope.options.questions))
                io.socket.put "/process/update", item, (data, jwres) ->
                  if data
                    console.log 'interview: ', data

      trash: (id) ->
        $scope.active.ad.applicants.forEach (item,index) ->
          if item.id is id
            item.status = 3
            io.socket.put "/applicant/update", item, (data, jwres) ->
              if data
                console.log 'trash if: ', data
              else
                console.log 'trash else: ', data


    $scope.filters =
      status:null
      arr:[]
      count:0
      new: (data) ->
        # FILTER TO COUNT NUMBER OF NEW APPLICATIONS
        if data.status is 0 or data.status is 1 or data.status is 2 or data.status is 4
          if data.applicant.status is $scope.filters.status
            return data
      done: (data) ->
        # FILTER APPLICATIONS THAT ARE FINISHED WITH ALL THE PROCESS FILTERS
        if data.processes and data.processes.length isnt 0
          if data.processes.length is data.recruitmentAd.process_filter.length and data.processes[data.processes.length-1].status is 1 and data.status is 2
            return data
      trash: (data) ->
        # FILTER APPLICATIONS THAT ARE TRASHED
        if data.processes and data.processes.length isnt 0
          if data.status is 3
            return data
      processFilter: (filterIndex) ->
        (data) ->
          # FILTER APPLICATIONS ACCORDING TO ACCORDING TO THEIR CURRENT PROCESS FILTER
          if data.processes and data.processes.length isnt 0 and data.status isnt 3
            if filterIndex <= data.processes[data.processes.length-1].index
              if data.processes[filterIndex].status is $scope.filters.arr[filterIndex]
                return data
      listFilter: ->
        # CREATED DYNAMIC VARIABLE NAMES FOR LIST FILTER STATUS HOLDER
        @arr.push 'filter_'+@count
        @count++


    $scope.reprocess =
      active: {
        ad:null
        application:null
      }
      select: (a) ->
        @active.ad = a
      assign: () ->
        @active.application.reprocess = @active.ad
        @active.application.status = 4
        io.socket.put "/applicant/reprocess", @active.application, (data, jwres) ->
          if data
            toaster.pop 'success', 'Success', 'Application has been reprocessed'
          else
            toaster.pop 'error', 'Error', 'Application was not reprocessed'

        $scope.active.ad.applicants.forEach (item,index) ->
          if item.id is $scope.reprocess.active.application.id
            item.reprocess = $scope.reprocess.active.ad
            item.status = 3
            io.socket.put "/applicant/update", item, (data, jwres) ->

        $scope.recruitmentAdModal = false
]