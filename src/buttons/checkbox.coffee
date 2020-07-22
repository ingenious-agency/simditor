class CheckboxButton extends Button
  @connect Util
  name: 'checkbox'
  icon: 'checkbox'
  htmlTag: 'input'
  disableTag: 'pre'
  needFocus: false
  selector: 'input[type="checkbox"]'

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
      if $contents.length == 1 and $contents.is('input[type=checkbox]')
        $input= $(range.startContainer).contents().eq(range.startOffset)
        @popover.show $input
      else
        @popover.hide()

    super()

  render: (args...) ->
    super args...
    @popover = new CheckboxPopover
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

    $input = $("<input id='#{id}' name='#{id}' />").attr(
      type: 'checkbox'
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


class CheckboxPopover extends Popover
  valueField = null
  checkedField = false

  render: ->
    tpl = """
    <div class="popover-title">
      <span>Configure the checkbox</span>
    </div>
    <div class="popover-content">
      <table class="popover-fields">
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
    @valueField = @el.find '.simditor-input-value'
    @checkedField = @el.find '.simditor-input-checked'
    @_attachEvents()

  # read properties from the input to pre-load the popover data.
  _loadCofig: () ->
    input = @.target

    # Load values from the rendered input
    @checkedField.prop('checked', input.prop('checked'))
    @valueField.val(input.attr('value') || '')

  _attachEvents: () ->
    @checkedField.on 'change', =>
      @target.prop('checked', @checkedField.prop('checked'))
      @target.attr('checked', @checkedField.prop('checked'))

    @valueField.on 'blur', =>
      @target.val('')
      if @valueField.val() == ''
        @target.removeAttr('value')
      else
        @target.attr('value', @valueField.val())

  show: (args...) ->
    super args...
    @_loadCofig()

Simditor.Toolbar.addButton CheckboxButton
