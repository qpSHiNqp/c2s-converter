require 'nokogiri'
require 'open-uri'
require 'json'

module C2s
  class Attachment
    attr_accessor :input_dir, :output_dir, :token
    def initialize(input_dir, output_dir)
      @input_dir = input_dir
      @output_dir = output_dir
      @token = ENV['CW_TOKEN']
    end

    def run
      base = Pathname.new(input_dir)
      Dir[File.join(input_dir, "**", "*")].each do |absolute_path|
        next unless FileTest.file? absolute_path
        file = Pathname.new(absolute_path).relative_path_from(base)
        if file.to_s =~ /file\.html/
          doc = Nokogiri::HTML.parse(File.read(absolute_path), nil)
          room_id = File.basename(File.dirname(absolute_path))
          room = nil
          doc.xpath('//h1[@class="autotrim"]').each do |room_node|
            room = room_node.inner_text
            room.gsub!(/\//, "_") if room =~ /\//
          end
          doc.xpath('//tbody/tr').each do |node|
            anchor = node.css('td.d-chat_list-file-name span a')
            fid = anchor.attribute('href').text().match(/fid=(\d+)$/)[1]
            name = anchor.inner_text
            user = node.css('td.d-chat_list-file-user span').inner_text
            user.gsub!(/\s/, "") if user =~ /\s/
            time = node.css('td.d-chat_list-file-update').inner_text.gsub!(/\s/, "")
            filename = [time, user, name].join("__")
            filename.gsub!(/\//, "_") if filename =~ /\//
            begin
              res =  open("https://api.chatwork.com/v2/rooms/#{room_id}/files/#{fid}?create_download_url=1", "X-ChatWorkToken" => token).read
              info = JSON.parse(res)
              output_filename = File.join(output_dir, room, filename)
              FileUtils.mkdir_p(File.dirname(output_filename))
              open(output_filename, "wb") do |output|
                open(info["download_url"]) do |data|
                  output.write(data.read)
                end
              end
            rescue OpenURI::HTTPError => e
              puts "Error #{e}"
            end
            puts "Saved #{output_filename}"
          end
          puts "Processed #{room} (#{room_id})"
        end
      end
    end
  end
end
