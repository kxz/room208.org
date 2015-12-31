module Room208
  module TumblrRewrites
    require 'nokogiri'
    require 'uri'

    def rewrite_media_url(tumblr_url)
      "/blog/media/#{File.basename(URI.parse(tumblr_url).path)}"
    end

    def rewrite_img_srcs(html)
      node_set = Nokogiri::HTML::fragment(html)
      node_set.css('img').each do |img|
        img.attribute('src').value = rewrite_media_url(img.attribute('src'))
      end
      node_set.to_html
    end
  end
end

include Room208::TumblrRewrites
