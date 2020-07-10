(function() {
  $(function() {
    var $preview, allowedTags, editor, mobileToolbar, toolbar;
    Simditor.locale = 'en-US';
    toolbar = ['fontScale', 'color', '|', 'bold', 'italic', 'underline', 'strikethrough', 'color', '|', 'ol', 'ul', 'blockquote', 'indent', 'outdent', 'alignment', '|', 'code', 'table', 'link', '|', 'input', 'select', 'checkbox', 'radio', 'textarea', '|', 'html'];
    allowedTags = ['br', 'span', 'a', 'img', 'b', 'strong', 'i', 'strike', 'u', 'font', 'p', 'ul', 'ol', 'li', 'blockquote', 'pre', 'code', 'h1', 'h2', 'h3', 'h4', 'hr', 'select', 'option', 'input', 'table', 'thead', 'tbody', 'tr', 'th', 'td'];
    mobileToolbar = ["bold", "underline", "strikethrough", "color", "ul", "ol"];
    if (mobilecheck()) {
      toolbar = mobileToolbar;
    }
    editor = new Simditor({
      textarea: $('#txt-content'),
      placeholder: '这里输入文字...',
      toolbar: toolbar,
      allowedTags: allowedTags,
      pasteImage: true,
      defaultImage: 'assets/images/image.png',
      upload: location.search === '?upload' ? {
        url: '/upload'
      } : false
    });
    $preview = $('#preview');
    if ($preview.length > 0) {
      return editor.on('valuechanged', function(e) {
        return $preview.html(editor.getValue());
      });
    }
  });

}).call(this);
