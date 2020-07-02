class TextareaButton extends Button
  @connect Util
  name: 'textarea'
  icon: 'textarea'
  htmlTag: 'textarea'
  disableTag: 'pre'
  needFocus: false
  selector: 'textarea'

  _init: () ->
    @menu = false

    @editor.body.on 'click', @selector, (e) =>
      $textarea = $(e.currentTarget)

      range = document.createRange()
      range.selectNode $textarea[0]
      @editor.selection.range range
      false

    @editor.body.on 'mouseup', @selector, (e) ->
      return false

    @editor.on 'selectionchanged.textarea', =>
      range = @editor.selection.range()
      return unless range?

      $contents = $(range.cloneContents()).contents()
      if $contents.length == 1 and $contents.is('textarea')
        $textarea= $(range.startContainer).contents().eq(range.startOffset)
        @popover.show $textarea
      else
        @popover.hide()

    super()

  render: (args...) ->
    super args...
    @popover = new TextareaPopover
      button: @

  renderMenu: ->
    super()

  _status: ->
    @_disableStatus()

  createTextarea: () ->
    @editor.focus() unless @editor.inputManager.focused
    range = @editor.selection.range()
    range.deleteContents()
    @editor.selection.range range

    $textarea = $("<textarea id='#{@util.generateRandomId()}'></textarea>")
    range.insertNode $textarea[0]
    @editor.selection.setRangeAfter $textarea, range
    @editor.trigger 'valuechanged'

    $textarea

  command: ->
    $textarea = @createTextarea()
    @editor.util.reflow $textarea
    $textarea.click()

    @popover.one 'popovershow', =>
      @popover.target.focus()
      @popover.target[0].select()
  # @popover.show $textarea

class TextareaPopover extends Popover
  maxLengthField = null
  rowsField = 4
  colsField = 30

  render: ->
    tpl = """
    <div class="popover-title">
      <span>Configure the textarea</span>
    </div>
    <div class="popover-content">
      <table class="popover-fields">
        <tr>
          <td class="field-name">Rows:</td>
          <td>
            <input class="simditor-textarea-rows" type="number" />
          </td>
        </tr>
        <tr>
          <td class="field-name">Columns:</td>
          <td>
            <input class="simditor-textarea-cols" type="number" />
          </td>
        </tr>
        <tr>
          <td class="field-name">Max length:</td>
          <td>
            <input class="simditor-textarea-maxlength" type="number" />
          </td>
        </tr>
      </table>
    </div>
    """
    @el.addClass('input-popover')
      .append(tpl)
    @rowsField = @el.find '.simditor-textarea-rows'
    @colsField = @el.find '.simditor-textarea-cols'
    @maxLengthField = @el.find '.simditor-textarea-maxlength'
    @_attachEvents()

  # read properties from the textarea to pre-load the popover data.
  _loadCofig: () ->
    textarea = @target

    # Load values from the rendered input
    @rowsField.val(textarea.attr('rows') || '4')
    @colsField.val(textarea.attr('cols') || '30')
    @maxLengthField.val(textarea.attr('maxlength') || '')

  _attachEvents: () ->
    @rowsField.on 'blur', () =>
      @target.val('')
      if @rowsField.val() == ''
        @target.removeAttr('rows')
      else
        @target.attr('rows', @rowsField.val())

    @colsField.on 'blur', () =>
      @target.val('')
      if @colsField.val() == ''
        @target.removeAttr('cols')
      else
        @target.attr('cols', @colsField.val())

    @maxLengthField.on 'blur', () =>
      @target.val('')
      if @maxLengthField.val() == ''
        @target.removeAttr('maxlength')
      else
        @target.attr('maxlength', @maxLengthField.val())

  show: (args...) ->
    super args...
    @_loadCofig()

Simditor.Toolbar.addButton TextareaButton
