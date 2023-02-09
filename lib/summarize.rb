module Room208
  module Summarize
    def summarize(item)
      item[:title] || excerptize(
        strip_html(item.compiled_content), length: 64, omission: '…')
    end

    class SummaryTitlingItemProxy
      instance_methods.each do |m|
        undef_method(m) unless m =~ /(^__|^nil\?|^send$|^object_id$)/
      end

      def initialize(item)
        @target = item
      end

      def respond_to?(symbol, include_priv=false)
        @target.respond_to?(symbol, include_priv)
      end

      def [](object)
        if object == :title
          summarize(@target)
        else
          @target[object]
        end
      end

      private

      def method_missing(method, ...)
        @target.send(method, ...)
      end
    end
  end
end

include Room208::Summarize
