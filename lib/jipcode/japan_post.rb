require 'jipcode'
require 'uri'
require 'net/http'
require 'zip'
require 'nkf'

module Jipcode
  module JapanPost
    ZIPCODE_URLS = {
      general: 'http://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip'.freeze,
      company: 'http://www.post.japanpost.jp/zipcode/dl/jigyosyo/zip/jigyosyo.zip'.freeze
    }.freeze
    ZIPCODE_FILES = {
      general: 'KEN_ALL.CSV'.freeze,
      company: 'JIGYOSYO.CSV'.freeze
    }.freeze

    def download_all
      ZIPCODE_URLS.each do |type, url|
        url = URI.parse(url)
        Net::HTTP.start(url.host, url.port) do |http|
          res = http.get(url.path)
          File.open("zipcode/#{type}.zip", 'wb') { |f| f.write(res.body) }
        end
      end
    end

    def import_all
      File.rename(ZIPCODE_PATH, 'zipcode/previous') if File.exist?(ZIPCODE_PATH)
      Dir.mkdir(ZIPCODE_PATH)

      zipcodes = unpack(:general)
      import(zipcodes) do |row|
        zipcode    = row[2] # 郵便番号
        prefecture = row[6] # 都道府県
        city       = row[7] # 市区町村
        # 郵便番号の下2桁が00の時、町域指定されない。
        # その場合、町域は「以下に掲載がない場合」となっているのでnilにする。
        town       = zipcode[5..6] == '00' ? nil : row[8]

        [zipcode, prefecture, city, town]
      end

      zipcodes = unpack(:company)
      import(zipcodes) do |row|
        zipcode    = row[7] # 郵便番号
        prefecture = row[3] # 都道府県
        city       = row[4] # 市区町村
        town       = row[5] + row[6] # 町域 + 番地

        [zipcode, prefecture, city, town]
      end

      FileUtils.rm_rf('zipcode/previous')
    rescue => e
      FileUtils.rm_rf(ZIPCODE_PATH)
      File.rename('zipcode/previous', ZIPCODE_PATH) if File.exist?('zipcode/previous')
      raise e, '日本郵便のデータを読み込めませんでした。'
    end

    # Private

    def unpack(type)
      download unless File.exist?("zipcode/#{type}.zip")

      content = ::Zip::File.open("zipcode/#{type}.zip") do |zip_file|
                  entry = zip_file.glob(ZIPCODE_FILES[type]).first
                  raise '日本郵便のファイルからデータが見つかりませんでした。' unless entry
                  entry.get_input_stream.read
                end

      # 文字コードをSHIFT JISからUTF-8に変換
      NKF.nkf('-w -Lu', content)
    end

    def import(zipcodes)
      CSV.parse zipcodes do |row|
        address = yield(row)
        zipcode = address.shift

        # 郵便番号は10万件以上あるので上3桁ごとにディレクトリを分割
        dir = "#{ZIPCODE_PATH}/#{zipcode[0..2]}"
        Dir.mkdir(dir) unless Dir.exist?(dir)
        open("#{dir}/#{zipcode[3..6]}.csv", 'a') { |f| f.write("#{address.join(',')}\n") }
      end
    end

    module_function :download_all, :import_all, :unpack, :import
    private_class_method :unpack, :import
  end
end
