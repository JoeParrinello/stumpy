require 'open-uri'
require 'cinch'

# Automatically shorten URL's found in messages
# Using the tinyURL API

bot = Cinch::Bot.new do
  configure do |c|
    c.server   = "irc.freenode.org"
    c.channels = ["#hardorange"]
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

  on :channel, /^!stumpy (http.+)/ do |m, url_list|
    urls = URI.extract(url_list, "http")

    unless urls.empty?
      short_urls = urls.map {|url| shorten(url) }.compact

      unless short_urls.empty?
        m.reply short_urls.join(", ")
      end
    end
  end
end

bot.start
