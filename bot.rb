require 'open-uri'
require 'cinch'

# Automatically shorten URL's found in messages
# Using the tinyURL API

bot = Cinch::Bot.new do
    configure do |c|
        raise "Environment Variable for Server not Set." unless ENV.has_key?("server")
        raise "Environment Variable for Channel not Set." unless ENV.has_key?("channel")
        c.server   = ENV['server']
        c.channels = ENV['channel']
        c.nick = "Stumpy"
    end

    helpers do
        def shorten(url)
            url = open("http://tinyurl.com/api-create.php?url=#{URI.escape(url)}").read
            url == "Error" ? nil : url
        rescue OpenURI::HTTPError
            nil
        end
    end

    on :channel, /^!stumpy (.+)/ do |m, url_list|
        urls = URI.extract(url_list, ["http","https"])

        unless urls.empty?
            short_urls = urls.map {|url| shorten(url) }.compact

            unless short_urls.empty?
                m.reply short_urls.join("\n")
            end
        end
    end
end

bot.start
