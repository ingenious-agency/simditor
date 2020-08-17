
$ ->
  Simditor.locale = 'en-US'

  toolbar= [
    'fontScale', 'color', '|',
    'bold', 'italic', 'underline', 'strikethrough', 'color', '|',
    'ol', 'ul', 'blockquote', 'indent', 'outdent', 'alignment', '|',
    'code', 'table', 'link', '|',
    'input', 'select', 'checkbox', 'radio', 'textarea'
  ]

  allowedTags= [
    'br', 'span', 'a', 'img', 'b', 'strong', 'i', 'strike', 'u',
    'font', 'p', 'ul', 'ol', 'li', 'blockquote', 'pre', 'code',
    'h1', 'h2', 'h3', 'h4', 'hr', 'select', 'option', 'input',
    'table', 'thead', 'tbody', 'tr', 'th', 'td'
  ]

  mobileToolbar=["bold","underline","strikethrough","color","ul","ol"]
  toolbar = mobileToolbar if mobilecheck()
  editor = new Simditor
    textarea: $('#txt-content')
    placeholder: '这里输入文字...'
    toolbar: toolbar
    allowedTags: allowedTags
    pasteImage: true
    defaultImage: 'assets/images/image.png'
    upload: if location.search == '?upload' then {url: '/upload'} else false

  $preview = $('#preview')
  if $preview.length > 0
    editor.on 'valuechanged', (e) ->
      $preview.html editor.getValue()
