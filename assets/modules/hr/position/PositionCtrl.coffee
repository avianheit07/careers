app.controller "PositionCtrl", [
  "$scope"
  "$http"
  "toaster"
  ($scope, $http, toaster) ->
    $scope.positions = []
    $scope.companies = []
    $scope.companyId = undefined
    $scope.hideModal = () ->
      $scope.modalShown = false

    $http.get "/company/show/self"
    .success (data) ->
      $scope.companyId = data
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
            if msg.length > 0 # update here
              msg = msg[0]

            $idx = null
            $scope.positions.forEach (pos, index) ->
              if pos.id is msg.id
                console.log 'found'
                $idx = index
                return

            if $idx isnt null
              console.log 'update'
              $scope.positions[$idx] = msg
            else
              if msg?
                console.log 'msg?', msg
                $scope.positions.push msg
              else
                console.log 'msg', msg
          $scope.$digest()


    $scope.position =
      index: null
      data: {
        responsibility: []
        education: []
        skill: []
        other: []
        process_filter: []
      }
      res: ''
      edu: ''
      ski: ''
      oth: ''
      man: {}
      exa: {}
      int: {
        questions: []
      }
      que: ''
      questions: []
      add: (what,data,index) ->
        switch what
          when 'res'
            obj = {}
            obj['responsibility'] = data
            @data.responsibility.push obj
            @res = ''
          when 'edu'
            obj = {}
            obj['education'] = data
            @data.education.push obj
            @edu = ''
          when 'ski'
            obj = {}
            obj['skill'] = data
            @data.skill.push obj
            @ski = ''
          when 'oth'
            obj = {}
            obj['other'] = data
            @data.other.push obj
            @oth = ''
          when 'man'
            data.type = 0
            @data.process_filter.push @man
            @man = {}
          when 'exa'
            data.type = 1
            @data.process_filter.push @exa
            @exa = {}
          when 'int'
            data.type = 2
            @data.process_filter.push @int
            @int = {
              questions: []
            }
          when 'que'
            obj = {}
            obj['question'] = data
            @data.process_filter[index].questions.push obj
            @que = ''
      remove: (what,index,filterIndex) ->
        switch what
          when 'res'
            @data.responsibility.splice index, 1
          when 'edu'
            @data.education.splice index, 1
          when 'ski'
            @data.skill.splice index, 1
          when 'oth'
            @data.other.splice index, 1
          when 'filter'
            @data.process_filter.splice index, 1
          when 'que'
            @data.process_filter[filterIndex].questions.splice index, 1
      save: () ->
        positionData = angular.fromJson(angular.toJson($scope.position.data))
        type = (if positionData.id then "put" else "post")
        io.socket[type] "/position/create", positionData, (data, jwres) ->
          if data
            toaster.pop 'success', 'Success', 'Position has been saved'
            $scope.hideModal()


    $scope.select = (index) ->
      value = index
      $scope.position.index = value
      $scope.modalShown = !$scope.modalShown
      $scope.position.data = $scope.positions[value]

    $scope.selected = (index) ->
      return index is $scope.position.index

    # modal for positions, create and update
    $scope.modalShown  = false

    $scope.toggleModal = (data) ->
      $scope.position.data = {
        responsibility: []
        education: []
        skill: []
        other: []
        process_filter: []
      }
      $scope.modalShown = !$scope.modalShown

    $scope.hideModal = () ->
      $scope.modalShown = false

    $scope.user =
      search: ''
      activeFilter: null
      set: (index) ->
        @activeFilter = $scope.position.data.process_filter[index]
      find: ->
        if @search.length >= 3
          $http.get '/user/search?search='+@search
          .success (data) ->
            $scope.users = data
            console.log 'users: ', $scope.users
      select: (what,data,index) ->
        obj = {
          id: data.id
          email: data.email
        }
        active = $scope.position.data.process_filter[index]
        switch what
          when 'man'
            active.assigned = obj
            @search = ''
          when 'exa'
            active.assigned = obj
            @search = ''
          when 'int'
            active.assigned = obj
            @search = ''
      remove: (what,index) ->
        active = $scope.position.data.process_filter[index]
        switch what
          when 'man'
            active.assigned = null
          when 'exa'
            active.assigned = null
          when 'int'
            active.assigned = null

    $scope.remove = (index) ->
      $scope.hideModal()
      if $scope.positions[index]?
        id = $scope.positions[index].id
        io.socket.delete "/position/remove/#{id}", (data, jwres) ->
          if data
            toaster.pop 'success', 'Success', 'Position has been removed'
        # add is selected
        # if data isnt undefined
        #   $scope.active.modal = null
        #   $scope.$apply()
]