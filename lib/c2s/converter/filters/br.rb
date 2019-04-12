module C2s
  module Converter
    module Filters
      class Br
        def self.call(text, options)
          text.gsub!("<br />", "") if text =~ /<br \/>/
        end
      end
    end
  end
end
