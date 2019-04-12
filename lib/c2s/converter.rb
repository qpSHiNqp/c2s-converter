require "c2s/converter/version"
require 'chatwork_to_slack/filters/dtext'
require 'chatwork_to_slack/filters/emoji'
require 'chatwork_to_slack/filters/picon'
require 'chatwork_to_slack/filters/pre'
require 'chatwork_to_slack/filters/reply'
require 'c2s/converter/filters/quote'
require 'c2s/converter/filters/br'
require 'csv'
require "fileutils"

module C2s
  module Converter
    class Error < StandardError; end
    # Your code goes here...
    class Client
      attr_reader :users
      def initialize(user_csv)
        f = File.open(user_csv, encoding: "CP932:UTF-8")
        loop { break if f.readchar == "\n" }
        @users = CSV.new(f, headers: true).map do |data|
          {
            chatwork_account_id: data['account_id'].to_i,
            chatwork_name:       data['name'],
            slack_name:          data['account_email'].split('@').first
          }
        end
      end

      def filters
        [
          ChatWorkToSlack::Filters::Dtext,
          ChatWorkToSlack::Filters::Emoji,
          ChatWorkToSlack::Filters::Picon,
          ChatWorkToSlack::Filters::Pre,
          ChatWorkToSlack::Filters::Reply,
          C2s::Converter::Filters::Quote,
          C2s::Converter::Filters::Br,
        ]
      end

      def convert(input_dir, output_dir)
        base = Pathname.new(input_dir)
        options = { users: users }

        Dir[File.join(input_dir, "**", "*")].each do |absolute_path|
          next unless FileTest.file? absolute_path
          file = Pathname.new(absolute_path).relative_path_from(base)
          out =
            if file.to_s =~ /message\d+\.html/
              filters.inject(File.read(absolute_path)) {|text, filter| filter.call(text, options)}
            else
              File.read(absolute_path)
            end
          outfile = file
          if output_dir
            outfile = File.join(output_dir, file)
            FileUtils.mkdir_p(File.dirname(outfile))
            File.write(outfile, out)
          end
          puts "Wrote #{outfile.to_s} (#{out.bytesize} bytes)"
        end
      end
    end
  end
end
