
class InputButton extends Button
  @connect Util
  name: 'input'
  icon: 'textbox'
  htmlTag: 'input'
  disableTag: 'pre'
  needFocus: false
  selector: 'input[type="text"],input[type="number"],input[type="email"]'

  _init: () ->
    @menu = false

    @editor.body.on 'click', @selector, (e) =>
      $input = $(e.currentTarget)

      range = document.createRange()
      range.selectNode $input[0]
      @editor.selection.range range
      false

    @editor.body.on 'mouseup', @selector, (e) ->
      return false

    @editor.on 'selectionchanged.input', =>
      range = @editor.selection.range()
      return unless range?

      $contents = $(range.cloneContents()).contents()
      if $contents.length == 1 and $contents.is('input')
        $input= $(range.startContainer).contents().eq(range.startOffset)
        @popover.show $input
      else
        @popover.hide()

    super()

  render: (args...) ->
    super args...
    @popover = new InputPopover
      button: @

  renderMenu: ->
    super()

  _status: ->
    @_disableStatus()

  createInput: () ->
    @editor.focus() unless @editor.inputManager.focused
    range = @editor.selection.range()
    range.deleteContents()
    @editor.selection.range range

    $input = $("<input id='#{@util.generateRandomId()}' style='width: 40px' data-columns='5'></input>").attr(
      type: 'text'
    )
    range.insertNode $input[0]
    @editor.selection.setRangeAfter $input, range
    @editor.trigger 'valuechanged'

    $input

  command: ->
    $input = @createInput()
    @editor.util.reflow $input
    $input.click()

    @popover.one 'popovershow', =>
      @popover.target.focus()
      @popover.target[0].select()


class InputPopover extends Popover
  typeField = null
  maxLengthField = null

  render: ->
    tpl = """
    <div class="popover-title">
      <span>Configure the input</span>
    </div>
    <div class="popover-content">
      <table class="popover-fields">
        <tr>
          <td class="field-name">
            Type:
          </td>
          <td>
            <select class="simditor-input-type">
              <option value="text">Text</option>
              <option value="number">Number</option>
              <option value="email">Email</option>
            </select>
          </td>
        </tr>
        <tr>
          <td class="field-name">
            <label>Columns:</label>
          </td>
          <td>
            <input class="simditor-input-width" type="number" min="0" />
          </td>
        </tr>
        <tr>
          <td class="field-name">
            <label>Max length:</label>
          </td>
          <td>
            <input class="simditor-input-maxlength" type="number" min="0" />
          </td>
        </tr>
      </table>
    </div>
    """
    @el.addClass('input-popover')
      .append(tpl)
    @typeField = @.el.find '.simditor-input-type'
    @maxLengthField = @.el.find '.simditor-input-maxlength'
    @widthField = @.el.find '.simditor-input-width'
    @_attachEvents()

  # read properties from the input to pre-load the popover data.
  _loadCofig: () ->
    input = @.target

    # Load values from the rendered input
    @typeField.find('option[value="' + input.attr('type') + '"]').prop('selected', true)
    @maxLengthField.val(input.attr('maxlength') || '')
    @widthField.val(input.attr('data-columns') || '5')

  _attachEvents: () ->
    @typeField.on 'change', () =>
      @target.val('')
      @target.attr('type', @typeField.val())

    @maxLengthField.on 'blur', () =>
      @target.val('')
      if @maxLengthField.val() == ''
        @target.removeAttr('maxlength')
      else
        @target.attr('maxlength', @.maxLengthField.val())
    
    @widthField.on 'blur', () =>
      @target.val('')
      if @widthField.val() == ''
        # @target.style Agarrar lo que hay en style y pelarle el width que es el mio
        @target.attr('style')
      else
        value = parseInt(@.widthField.val(), 10)
        width = value * 8
        @target.attr('data-columns', value)
        @target.attr('style', "width: #{width}px")

  show: (args...) ->
    super args...
    @_loadCofig()

Simditor.Toolbar.addButton InputButton
