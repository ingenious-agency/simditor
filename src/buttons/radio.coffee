class RadioButton extends Button
  @connect Util
  name: 'radio'
  icon: 'radio'
  htmlTag: 'input'
  disableTag: 'pre'
  needFocus: false
  selector: 'input[type="radio"]'

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

    @editor.on 'selectionchanged.checkbox', =>
      range = @editor.selection.range()
      return unless range?

      $contents = $(range.cloneContents()).contents()
      if $contents.length == 1 and $contents.is('input[type=radio]')
        $input= $(range.startContainer).contents().eq(range.startOffset)
        @popover.show $input
      else
        @popover.hide()

    super()

  render: (args...) ->
    super args...
    @popover = new RadioPopover
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
    id = @util.generateRandomId()
    $input = $("<input id='#{id}' name='#{id}' value='#{id}'/>").attr(
      type: 'radio'
    )
    range.insertNode $input[0]
    @editor.selection.setRangeAfter $input, range
    $input

  command: ->
    $input = @createInput()
    @editor.util.reflow $input
    $input.focus()

    @popover.one 'popovershow', =>
      @popover.target.focus()
      @popover.target[0].select()
    @popover.show $input


class RadioPopover extends Popover
  valueField = null
  checkedField = false
  groupField = null

  render: ->
    tpl = """
    <div class="popover-title">
      <span>Configure the radio</span>
    </div>
    <div class="popover-content">
      <table class="popover-fields">
        <tr>
          <td class="field-name">Group:</td>
          <td>
            <input class="simditor-input-group" type="text" />
          </td>
        </tr>
        <tr>
          <td class="field-name">Value:</td>
          <td>
            <input class="simditor-input-value" type="text" />
          </td>
        </tr>
        <tr>
          <td class="field-name">Checked:</td>
          <td>
            <input class="simditor-input-checked" type="checkbox" />
          </td>
        </tr>
      </table>
    </div>
    """
    @el.addClass('input-popover')
      .append(tpl)
    @groupField = @el.find '.simditor-input-group'
    @checkedField = @el.find '.simditor-input-checked'
    @valueField = @el.find '.simditor-input-value'
    @_attachEvents()

  # read properties from the input to pre-load the popover data.
  _loadCofig: () ->
    input = @.target

    # Load values from the rendered input
    @groupField.val(input.attr('name') || null)
    @checkedField.prop('checked', input.prop('checked'))
    @valueField.val(input.attr('value') || '')

  _attachEvents: () ->
    @groupField.on 'blur', =>
      if @groupField.val() == ''
        @target.removeAttr('name')
      else
        @target.attr('name', @groupField.val())

    @checkedField.on 'change', =>
      @target.prop('checked', @checkedField.prop('checked'))
      @target.attr('checked', @checkedField.prop('checked'))

    @valueField.on 'blur', =>
      if @valueField.val() == ''
        @target.removeAttr('value')
      else
        @target.attr('value', @valueField.val())

  show: (args...) ->
    super args...
    @_loadCofig()

Simditor.Toolbar.addButton RadioButton
