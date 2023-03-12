module Room208
  module Summarize
    def summarize(item)
      item[:title] || excerptize(
        strip_html(item.compiled_content), length: 64, omission: '…')
    end
  end
end

include Room208::Summarize
