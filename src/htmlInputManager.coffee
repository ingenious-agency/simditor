
class HtmlInputManager extends SimpleModule
  @pluginName: 'HtmlInputManager'

  _inputs: []

  _init: ->
    @editor = @_module

    @editor.on 'initialized', =>
      # after render the content, generate initial version of the inputs.
      @_generateInputs()

    @editor.on 'blur', =>
      @_generateInputs()

  _generateInputs: ->
    @_inputs = []
    # Ensure that all html inputs has an ID to refer it.
    @_generateMissingIds()

    @editor.body.find('input, textarea, select').each (i, elem) =>
      id = $(elem).attr('id')
      type = @_getElementType(elem)
      @_addInput(id, type)

  _addInput: (id, type, value) ->
    @_inputs.push(
      id: id
      type: type
    )

  _getElementType: (elem) ->
    type = elem.tagName.toLowerCase()
    type = $(elem).attr('type') if $(elem).is('input')
    type

  # This method generates an id in every html input that has not an ID attribute.
  _generateMissingIds: ->
    @editor.body.find('input, textarea, select').each (i, elem) =>
      $(elem).attr('id', @editor.util.generateRandomId()) if $(elem).attr('id') == undefined