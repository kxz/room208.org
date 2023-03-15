def summarize(item)
  item[:title] || excerptize(
    strip_html(item.compiled_content), length: 64, omission: '…')
end
