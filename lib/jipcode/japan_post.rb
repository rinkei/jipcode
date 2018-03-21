require 'uri'
require 'net/http'

module Jipcode
  module JapanPost
    ZIPCODE_URL = 'http://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip'.freeze

    def download
      url = URI.parse(ZIPCODE_URL)
      Net::HTTP.start(url.host, url.port) do |http|
        res = http.get(url.path)
        File.open('ken_all.zip', 'wb') { |f| f.write(res.body) }
      end
    end

    module_function :download
  end
end
