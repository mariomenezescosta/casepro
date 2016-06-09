# Unit tests for our Angular services (services listed A-Z)

describe('services:', () ->
  $httpBackend = null
  $window = null
  test = null

  beforeEach(() ->
    module('cases')

    inject((_$httpBackend_, _$window_) ->
      $httpBackend = _$httpBackend_
      $window = _$window_
    )

    test = {
      # users
      user1: {id: 101, name: "Tom McTest"},

      # labels
      tea: {id: 201, name: "Tea"},
      coffee: {id: 202, name: "Coffee"},

      # partners
      moh: {id: 301, name: "MOH"},
      who: {id: 302, name: "WHO"}
    }
  )

  #=======================================================================
  # Tests for CaseService
  #=======================================================================
  describe('CaseService', () ->
    CaseService = null

    beforeEach(inject((_CaseService_) ->
      CaseService = _CaseService_

      test.case1 = {
        id: 501,
        summary: "Got tea?",
        labels: [test.tea],
        assignee: test.moh,
        opened_on: utcdate(2016, 5, 27, 11, 0, 0, 0),
        is_closed: false
      }
    ))
    
    describe('addNote', () ->
      it('posts to note endpoint', () ->
        $httpBackend.expectPOST('/case/note/501/', {note: "Hello there"}).respond('')
        CaseService.addNote(test.case1, "Hello there")
        $httpBackend.flush()
      )
    )

    describe('fetchOld', () ->
      it('gets cases from search endpoint', () ->
        $httpBackend.expectGET('/case/search/?folder=open').respond('{"results":[{"id":501,"opened_on":"2016-05-17T08:49:13.698864"}],"has_more":true}')
        CaseService.fetchOld({folder: "open"}).then((data) ->
          expect(data.results).toEqual([{id: 501, opened_on: utcdate(2016, 5, 17, 8, 49, 13, 698)}])
          expect(data.hasMore).toEqual(true)
        )
        $httpBackend.flush()
      )
    )

    describe('fetchTimeline', () ->
      it('gets cases from timeline endpoint', () ->
        $httpBackend.expectGET('/case/timeline/501/?after=2016-05-28T09:00:00.000Z').respond('{"results":[{"id":501,"time":"2016-05-17T08:49:13.698864","type":"A"}]}')
        CaseService.fetchTimeline(test.case1, utcdate(2016, 5, 28, 9, 0, 0, 0)).then((data) ->
          expect(data.results).toEqual([{
            id: 501,
            time: utcdate(2016, 5, 17, 8, 49, 13, 698),
            type: 'A',
            is_action: true,
            is_message_in: false,
            is_message_out: false
          }])
        )
        $httpBackend.flush()
      )
    )

    describe('fetchSingle', () ->
      it('gets case from fetch endpoint', () ->
        $httpBackend.expectGET('/case/fetch/501/').respond('{"id":501,"opened_on":"2016-05-17T08:49:13.698864"}')
        CaseService.fetchSingle(501).then((caseObj) ->
          expect(caseObj).toEqual({id: 501, opened_on: utcdate(2016, 5, 17, 8, 49, 13, 698)})
        )
        $httpBackend.flush()
      )
    )

    describe('reassign', () ->
      it('posts to reassign endpoint', () ->
        $httpBackend.expectPOST('/case/reassign/501/', {assignee: 302}).respond('')
        CaseService.reassign(test.case1, test.who).then(() ->
          expect(test.case1.assignee).toEqual(test.who)
        )
        $httpBackend.flush()
      )
    )

    describe('close', () ->
      it('posts to close endpoint and closes case', () ->
        $httpBackend.expectPOST('/case/close/501/', {note: "Hello there"}).respond('')
        CaseService.close(test.case1, "Hello there").then(() ->
          expect(test.case1.is_closed).toEqual(true)
        )
        $httpBackend.flush()
      )
    )

    describe('open', () ->
      it('posts to open endpoint', () ->
        $httpBackend.expectPOST('/case/open/', {message: 401, summary: "Hi", assignee: 301}).respond('{"case": {"id": 501}, "is_new": true}')
        CaseService.open({id: 401, text: "Hi"}, "Hi", test.moh).then((caseObj) ->
          expect(caseObj.id).toEqual(501)
          expect(caseObj.isNew).toEqual(true)
        )
        $httpBackend.flush()
      )
    )

    describe('relabel', () ->
      it('posts to label endpoint', () ->
        $httpBackend.expectPOST('/case/label/501/', {labels: [202]}).respond('')
        CaseService.relabel(test.case1, [test.coffee]).then(() ->
          expect(test.case1.labels).toEqual([test.coffee])
        )
        $httpBackend.flush()
      )
    )

    describe('reopen', () ->
      it('posts to reopen endpoint and reopens case', () ->
        test.case1.is_closed = true

        $httpBackend.expectPOST('/case/reopen/501/', {note: "Hello there"}).respond('')
        CaseService.reopen(test.case1, "Hello there").then(() ->
          expect(test.case1.is_closed).toEqual(false)
        )
        $httpBackend.flush()
      )
    )
    
    describe('replyTo', () ->
      it('posts to reply endpoint', () ->
        $httpBackend.expectPOST('/case/reply/501/', {text: "Hello there"}).respond('')
        CaseService.replyTo(test.case1, "Hello there")
        $httpBackend.flush()
      )
    )

    describe('startExport', () ->
      it('posts to export endpoint', () ->
        $httpBackend.expectPOST('/caseexport/create/?folder=open', null).respond('')
        CaseService.startExport({folder: "open"})
        $httpBackend.flush()
      )
    )

    describe('updateSummary', () ->
      it('posts to update summary endpoint', () ->
        $httpBackend.expectPOST('/case/update_summary/501/', {summary: "Got coffee?"}).respond('')
        CaseService.updateSummary(test.case1, "Got coffee?").then(() ->
          expect(test.case1.summary).toEqual("Got coffee?")
        )
        $httpBackend.flush()
      )
    )
  )

  #=======================================================================
  # Tests for LabelService
  #=======================================================================
  describe('LabelService', () ->
    LabelService = null

    beforeEach(inject((_LabelService_) ->
      LabelService = _LabelService_
    ))

    describe('delete', () ->
      it('posts to delete endpoint', () ->
        $httpBackend.expectPOST('/label/delete/201/', null).respond("")
        LabelService.delete(test.tea)
        $httpBackend.flush()
      )
    )
  )

  #=======================================================================
  # Tests for MessageService
  #=======================================================================
  describe('MessageService', () ->
    MessageService = null

    beforeEach(inject((_MessageService_) ->
      MessageService = _MessageService_

      test.msg1 = {id: 101, text: "Hello 1", labels: [test.tea], flagged: true, archived: false}
      test.msg2 = {id: 102, text: "Hello 2", labels: [test.coffee], flagged: false, archived: false}
    ))

    describe('fetchHistory', () ->
      it('gets actions from history endpoint', () ->
        $httpBackend.expectGET('/message/history/101/').respond('{"actions":[{"action":"archive","created_on":"2016-05-17T08:49:13.698864"}]}')
        MessageService.fetchHistory(test.msg1).then((actions) ->
          expect(actions).toEqual([{action: "archive", "created_on": utcdate(2016, 5, 17, 8, 49, 13, 698)}])
        )
        $httpBackend.flush()
      )
    )

    describe('fetchOld', () ->
      it('gets messages from search endpoint', () ->
        $httpBackend.expectGET('/message/search/?archived=0&folder=inbox').respond('{"results":[{"id":501,"time":"2016-05-17T08:49:13.698864"}],"has_more":true}')
        MessageService.fetchOld({folder: "inbox"}).then((data) ->
          expect(data.results).toEqual([{id: 501, time: utcdate(2016, 5, 17, 8, 49, 13, 698)}])
          expect(data.hasMore).toEqual(true)
        )
        $httpBackend.flush()
      )
    )

    describe('bulkArchive', () ->
      it('posts to bulk action endpoint', () ->
        $httpBackend.expectPOST('/message/action/archive/', {messages: [101, 102]}).respond('')
        MessageService.bulkArchive([test.msg1, test.msg2]).then(() ->
          expect(test.msg1.archived).toEqual(true)
          expect(test.msg2.archived).toEqual(true)
        )
        $httpBackend.flush()
      )
    )

    describe('bulkFlag', () ->
      it('posts to bulk action endpoint', () ->
        $httpBackend.expectPOST('/message/action/flag/', {messages: [101, 102]}).respond('')
        MessageService.bulkFlag([test.msg1, test.msg2], true).then(() ->
          expect(test.msg1.flagged).toEqual(true)
          expect(test.msg2.flagged).toEqual(true)
        )
        $httpBackend.flush()

        $httpBackend.expectPOST('/message/action/unflag/', {messages: [101, 102]}).respond('')
        MessageService.bulkFlag([test.msg1, test.msg2], false).then(() ->
          expect(test.msg1.flagged).toEqual(false)
          expect(test.msg2.flagged).toEqual(false)
        )
        $httpBackend.flush()
      )
    )

    describe('bulkLabel', () ->
      it('posts to bulk action endpoint', () ->
        $httpBackend.expectPOST('/message/action/label/', {messages: [101, 102], label: 201}).respond('')
        MessageService.bulkLabel([test.msg1, test.msg2], test.tea).then(() ->
          expect(test.msg1.labels).toEqual([test.tea])
          expect(test.msg2.labels).toEqual([test.coffee, test.tea])
        )
        $httpBackend.flush()
      )
    )

    describe('bulkReply', () ->
      it('posts to bulk reply endpoint', () ->
        $httpBackend.expectPOST('/message/bulk_reply/', {messages: [101, 102], text: "Welcome"}).respond('')
        MessageService.bulkReply([test.msg1, test.msg2], "Welcome")
        $httpBackend.flush()
      )
    )

    describe('bulkRestore', () ->
      it('posts to bulk action endpoint', () ->
        $httpBackend.expectPOST('/message/action/restore/', {messages: [101, 102]}).respond('')
        MessageService.bulkRestore([test.msg1, test.msg2]).then(() ->
          expect(test.msg1.archived).toEqual(false)
          expect(test.msg2.archived).toEqual(false)
        )
        $httpBackend.flush()
      )
    )

    describe('forward', () ->
      it('posts to forward endpoint', () ->
        $httpBackend.expectPOST('/message/forward/101/', {text: "Welcome", urns: ["tel:+260964153686"]}).respond('')
        MessageService.forward(test.msg1, "Welcome", {urn: "tel:+260964153686"})
        $httpBackend.flush()
      )
    )

    describe('relabel', () ->
      it('posts to label endpoint', () ->
        $httpBackend.expectPOST('/message/label/101/', {labels: [202]}).respond('')
        MessageService.relabel(test.msg1, [test.coffee]).then(() ->
          expect(test.msg1.labels).toEqual([test.coffee])
        )
        $httpBackend.flush()
      )
    )

    describe('startExport', () ->
      it('posts to export endpoint', () ->
        $httpBackend.expectPOST('/messageexport/create/?archived=0&folder=inbox', null).respond('')
        MessageService.startExport({folder: "inbox"})
        $httpBackend.flush()
      )
    )
  )

  #=======================================================================
  # Tests for OutgoingService
  #=======================================================================
  describe('OutgoingService', () ->
    OutgoingService = null

    beforeEach(inject((_OutgoingService_) ->
      OutgoingService = _OutgoingService_
    ))

    describe('fetchOld', () ->
      it('gets messages from search endpoint', () ->
        $httpBackend.expectGET('/outgoing/search/?folder=sent').respond('{"results":[{"id":501,"time":"2016-05-17T08:49:13.698864"}],"has_more":true}')
        OutgoingService.fetchOld({folder: "sent"}).then((data) ->
          expect(data.results).toEqual([{id: 501, time: utcdate(2016, 5, 17, 8, 49, 13, 698)}])
          expect(data.hasMore).toEqual(true)
        )
        $httpBackend.flush()
      )
    )

    describe('fetchReplies', () ->
      it('gets messages from replies endpoint', () ->
        $httpBackend.expectGET('/outgoing/search_replies/?partner=301').respond('{"results":[{"id":501,"time":"2016-05-17T08:49:13.698864"}],"has_more":true}')
        OutgoingService.fetchReplies({partner: test.moh}).then((data) ->
          expect(data.results).toEqual([{id: 501, time: utcdate(2016, 5, 17, 8, 49, 13, 698)}])
          expect(data.hasMore).toEqual(true)
        )
        $httpBackend.flush()
      )
    )

    describe('startReplyExport', () ->
      it('posts to export endpoint', () ->
        $httpBackend.expectPOST('/replyexport/create/?partner=301', null).respond('')
        OutgoingService.startReplyExport({partner: test.moh})
        $httpBackend.flush()
      )
    )
  )

  #=======================================================================
  # Tests for PartnerService
  #=======================================================================
  describe('PartnerService', () ->
    PartnerService = null

    beforeEach(inject((_PartnerService_) ->
      PartnerService = _PartnerService_
    ))

    describe('fetchUsers', () ->
      it('fetches from users endpoint', () ->
        $httpBackend.expectGET('/partner/users/301/').respond('{"results":[{"id": 101, "name": "Tom McTest", "replies": {}}]}')
        PartnerService.fetchUsers(test.moh).then((users) ->
          expect(users).toEqual([{id: 101, name: "Tom McTest", replies: {}}])
        )
        $httpBackend.flush()
      )
    )

    describe('delete', () ->
      it('posts to delete endpoint', () ->
        $httpBackend.expectPOST('/partner/delete/301/', null).respond('')
        PartnerService.delete(test.moh)
        $httpBackend.flush()
      )
    )
  )

  #=======================================================================
  # Tests for UserService
  #=======================================================================
  describe('UserService', () ->
    UserService = null

    beforeEach(inject((_UserService_) ->
      UserService = _UserService_
    ))

    describe('delete', () ->
      it('posts to delete endpoint', () ->
        $httpBackend.expectPOST('/user/delete/101/', null).respond('')
        UserService.delete(test.user1)
        $httpBackend.flush()
      )
    )
  )

  #=======================================================================
  # Tests for UtilsService
  #=======================================================================
  describe('UtilsService', () ->
    UtilsService = null
    $uibModal = null

    beforeEach(() ->
      inject((_UtilsService_, _$uibModal_) ->
        UtilsService = _UtilsService_
        $uibModal = _$uibModal_
      )

      spyOn($uibModal, 'open').and.callThrough()
    )

    describe('displayAlert', () ->
      it('called external displayAlert', () ->
        $window.displayAlert = jasmine.createSpy('$window.displayAlert')

        UtilsService.displayAlert('error', "Uh Oh!")

        expect($window.displayAlert).toHaveBeenCalledWith('error', "Uh Oh!")
      )
    )

    describe('navigate', () ->
      it('changes location of $window', () ->
        spyOn($window.location, 'replace')

        UtilsService.navigate("http://example.com")

        expect($window.location.replace).toHaveBeenCalledWith("http://example.com")
      )
    )
    
    describe('navigateBack', () ->
      it('calls history.back', () ->
        spyOn($window.history, 'back')

        UtilsService.navigateBack()

        expect($window.history.back).toHaveBeenCalled()
      )
    )

    describe('confirmModal', () ->
      it('opens confirm modal', () ->
        UtilsService.confirmModal("OK?")

        modalOptions = $uibModal.open.calls.mostRecent().args[0]
        expect(modalOptions.templateUrl).toEqual('/partials/modal_confirm.html')
        expect(modalOptions.resolve.prompt()).toEqual("OK?")
      )
    )

    describe('editModal', () ->
      it('opens edit modal', () ->
        UtilsService.editModal("Edit", "this...", 100)

        modalOptions = $uibModal.open.calls.mostRecent().args[0]
        expect(modalOptions.templateUrl).toEqual('/partials/modal_edit.html')
        expect(modalOptions.resolve.title()).toEqual("Edit")
        expect(modalOptions.resolve.initial()).toEqual("this...")
        expect(modalOptions.resolve.maxLength()).toEqual(100)
      )
    )

    describe('composeModal', () ->
      it('opens compose modal', () ->
        UtilsService.composeModal("Compose", "this...", 100)

        modalOptions = $uibModal.open.calls.mostRecent().args[0]
        expect(modalOptions.templateUrl).toEqual('/partials/modal_compose.html')
        expect(modalOptions.resolve.title()).toEqual("Compose")
        expect(modalOptions.resolve.initial()).toEqual("this...")
        expect(modalOptions.resolve.maxLength()).toEqual(100)
      )
    )

    describe('assignModal', () ->
      it('opens assign modal', () ->
        UtilsService.assignModal("Assign", "this...", [test.moh, test.who])

        modalOptions = $uibModal.open.calls.mostRecent().args[0]
        expect(modalOptions.templateUrl).toEqual('/partials/modal_assign.html')
        expect(modalOptions.resolve.title()).toEqual("Assign")
        expect(modalOptions.resolve.prompt()).toEqual("this...")
        expect(modalOptions.resolve.partners()).toEqual([test.moh, test.who])
      )
    )

    describe('noteModal', () ->
      it('opens note modal', () ->
        UtilsService.noteModal("Note", "this...", 'danger', 100)

        modalOptions = $uibModal.open.calls.mostRecent().args[0]
        expect(modalOptions.templateUrl).toEqual('/partials/modal_note.html')
        expect(modalOptions.resolve.title()).toEqual("Note")
        expect(modalOptions.resolve.prompt()).toEqual("this...")
        expect(modalOptions.resolve.style()).toEqual('danger')
        expect(modalOptions.resolve.maxLength()).toEqual(100)
      )
    )

    describe('labelModal', () ->
      it('opens label modal', () ->
        UtilsService.labelModal("Label", "this...", [test.tea, test.coffee], [test.tea])

        modalOptions = $uibModal.open.calls.mostRecent().args[0]
        expect(modalOptions.templateUrl).toEqual('/partials/modal_label.html')
        expect(modalOptions.resolve.title()).toEqual("Label")
        expect(modalOptions.resolve.prompt()).toEqual("this...")
        expect(modalOptions.resolve.labels()).toEqual([test.tea, test.coffee])
        expect(modalOptions.resolve.initial()).toEqual([test.tea])
      )
    )

    describe('newCaseModal', () ->
      it('opens new case modal', () ->
        UtilsService.newCaseModal("this...", 100, [test.moh, test.who])

        modalOptions = $uibModal.open.calls.mostRecent().args[0]
        expect(modalOptions.templateUrl).toEqual('/partials/modal_newcase.html')
        expect(modalOptions.resolve.summaryInitial()).toEqual("this...")
        expect(modalOptions.resolve.summaryMaxLength()).toEqual(100)
        expect(modalOptions.resolve.partners()).toEqual([test.moh, test.who])
      )
    )
  )
)