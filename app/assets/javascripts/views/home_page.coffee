{Question, User} = Models

class Views.HomePage extends View
  @content: ->
    @div id: 'home-page', class: 'container', =>

      @header =>
        @button "+ New Question", class: 'btn btn-large btn-primary pull-right', click: 'addQuestion'
        @h1 "", outlet: 'questionsHeader'

      @subview 'questionsList', new Views.RelationView(
        attributes: { id: 'questions' }
        buildItem: (question) ->
          $$ ->
            @li =>
              @a class: 'question', href: "/questions/#{question.id()}", =>
                @img src: question.creator().avatarUrl()
                @div question.body(), class: "body"
      )

  initialize: ->
    @questionsList.onInsert = => @updateQuestionsHeader()
    @questionsList.onRemove = => @updateQuestionsHeader()

  show: ->
    super
    @fetchPromise ?= Question.join(User, creatorId: 'User.id').fetch()
    @fetchPromise.onSuccess =>
      @questionsList.setRelation(Models.Question.table)

  updateQuestionsHeader: ->

    size = Question.size()

    if size == 1
      @questionsHeader.text("1 Question")
    else
      @questionsHeader.text("#{size} Questions")

  addQuestion: ->
    new Views.ModalForm(
      headingText: "Ask an open-ended question:"
      buttonText: "Ask Question"
      onSubmit: (body) =>
        Question.create({body})
          .onSuccess (question) =>
            Davis.location.assign("/questions/#{question.id()}")
    )
