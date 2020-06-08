class SelectButton extends Button
  name: 'select'
  icon: 'minus'
  htmlTag: 'select'
  disableTag: 'pre'
  needFocus: false

  _init: () ->
    @menu = false

    @editor.body.on 'click', 'select', (e) =>
      $select = $(e.currentTarget)

      range = document.createRange()
      range.selectNode $select[0]
      @editor.selection.range range
      false

    @editor.body.on 'mouseup', 'select', (e) ->
      return false

    @editor.on 'selectionchanged.select', =>
      range = @editor.selection.range()
      return unless range?

      $contents = $(range.cloneContents()).contents()
      if $contents.length == 1 and $contents.is('select')
        $select= $(range.startContainer).contents().eq(range.startOffset)
        @popover.show $select
      else
        @popover.hide()

    super()

  render: (args...) ->
    super args...
    @popover = new SelectPopover
      button: @

  renderMenu: ->
    super()

  _status: ->
    @_disableStatus()

  createSelect: () ->
    @editor.focus() unless @editor.inputManager.focused
    range = @editor.selection.range()
    range.deleteContents()
    @editor.selection.range range

    $select = $('<select></select>')
    range.insertNode $select[0]
    @editor.selection.setRangeAfter $select, range
    @editor.trigger 'valuechanged'

    $select

  command: ->
    $select = @createSelect()
    @editor.util.reflow $select
    $select.click()

    @popover.one 'popovershow', =>
      @popover.target.focus()
      # @popover.target[0].select()


class SelectPopover extends Popover
  options = []

  render: ->
    tpl = """
    <div class="popover-title">
      <span>Configure the select</span>
    </div>
    <div class="popover-content">
      <table class="popover-fields">
        <tr>
          <td class="field-name">Add new option</td>
        </tr>
        <tr>
          <td>
            <input class="simditor-select-text" placeholder="Display text" />
            <input class="simditor-select-value" placeholder="Value" />
            <button class="simditor-select-add">ADD</button>
          </td>
        </tr>
        <tr>
          <td>
            <span class="simditor-select-error">
              Display text and value are required.
            </span>
          </td>
        </tr>
      </table>
      <table class="popover-fields">
        <tr>
          <td class="field-name">Options:</td>
        </tr>
        <tr>
          <td>
            <div class="simditor-select-options"></div>
          </td>
        </tr>
      </table>
    </div>
    """
    @el.addClass('select-popover')
      .append(tpl)
    @el.find('.simditor-select-error').hide()
    @_attachAddEvents()

  # read properties from the input to pre-load the popover data.
  _loadCofig: ->
    select = @target

    select.find('option').each (i, element) =>
      options.push
        text: $(element).text()
        value: $(element).val()

  _renderOptions: ->
    popover = @el
    popover.find('.simditor-select-options').html(
      """
      <table class="option-table">
        <thead>
          <tr>
            <th>Display text</th>
            <th>Value</th>
            <th></th>
          </tr>
        </thead>
        <tbody></tbody>
      </table>
      """
    )

    if options.length == 0
      popover.find('.simditor-select-options table tbody')
        .append("""
          <tr>
            <td class="empty-rows" colspan="3">
              There are no options yet
            </td>
          </tr>
        """)
      @_renderSelectOptions()
      return

    options.forEach (item, index) =>
      popover.find('.simditor-select-options table tbody')
        .append("""
          <tr data-index="#{index}">
            <td>
              #{item.text}
            </td>
            <td>
              #{item.value}
            </td>
            <td class="row-actions">
              <button class="simditor-option-up" data-index="#{index}" title="Move option up">
                <i class="simditor-icon simditor-icon-caret-down" data-index="#{index}"></i>
              </button>
              <button class="simditor-option-down" data-index="#{index}" title="Move option down">
                <i class="simditor-icon simditor-icon-caret-down" data-index="#{index}"></i>
              </button>
              <button class="simditor-option-remove" data-index="#{index}" title="Remove option">
                <i class="simditor-icon simditor-icon-minus" data-index="#{index}"></i>
              </button>
            </td>
          </tr>
          """)
    @_attachOptionEvents()
    @_renderSelectOptions()

  _renderSelectOptions: ->
    select = @target
    # clean current options to render the new ones.
    select.find('option').remove()
    options.forEach (option) ->
      select.append("<option value='#{option.value}'>#{option.text}</option>")

  _moveOption: (index, direction) ->
    index = parseInt(index)

    return if index == 0 && direction == 'up'
    return if index == options.length - 1 && direction == 'down'

    if direction == 'up'
      [options[index], options[index-1]] = [options[index-1], options[index]]
    else
      [options[index], options[index+1]] = [options[index+1], options[index]]

    @_renderOptions()

  _removeOption: (index) ->
    options.splice(parseInt(index), 1)
    @_renderOptions()

  _addOption: ->
    popover = @el
    textField = popover.find('.simditor-select-text')
    valueField = popover.find('.simditor-select-value')

    if textField.val() == '' || valueField.val() == ''
      popover.find('.simditor-select-error').show()
    else
      options.push
        text: textField.val()
        value: valueField.val()

      @_renderOptions()
      @_resetAddOption()
      popover.find('.simditor-select-text').focus()

  _resetAddOption: () ->
    popover = @el
    popover.find('.simditor-select-text').val('')
    popover.find('.simditor-select-value').val('')
    popover.find('.simditor-select-error').hide()

  _attachOptionEvents: ->
    popover = @el
    popover.find('.simditor-option-up').on 'click', (e) =>
      @_moveOption(e.target.dataset.index, 'up')

    popover.find('.simditor-option-down').on 'click', (e) =>
      @_moveOption(e.target.dataset.index, 'down')

    popover.find('.simditor-option-remove').on 'click', (e) =>
      @_removeOption(e.target.dataset.index)

  _attachAddEvents: ->
    popover = @el
    popover.find('.simditor-select-add').on 'click', =>
      @_addOption()

    popover.find('.simditor-select-text').on 'keyup', (e) =>
      return unless e.which == 13
      @_addOption()

    popover.find('.simditor-select-value').on 'keyup', (e) =>
      return unless e.which == 13
      @_addOption()

  show: (args...) ->
    super args...
    options = []
    @_resetAddOption()
    @_loadCofig()
    @_renderOptions()
    @el.find('.simditor-select-text').focus()

Simditor.Toolbar.addButton SelectButton
