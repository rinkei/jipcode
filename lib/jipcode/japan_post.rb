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

    def update
      download_all
      import_all
    end

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
        town       = row[8] # 町域

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
      duplicated_row = false
      CSV.parse zipcodes do |row|
        address = yield(row)
        puts row unless address

        town = address[3]
        if duplicated_row
          duplicated_row = false if town.end_with?('）')
          next
        else
          duplicated_row = true if town.include?('（') && !town.include?('）')
        end

        # 町域等に含まれる曖昧な表記を削除
        unless town.include?('私書箱')
          address[3] = town.sub(/(（.+|一円|の次に番地がくる場合|以下に掲載がない場合)$/, '')
        end

        # 10万件以上あるので郵便番号上3桁ごとに分割
        filepath = "#{ZIPCODE_PATH}/#{address[0][0..2]}.csv"
        open(filepath, 'a') { |f| f.write("#{address.join(',')}\n") }
      end
    end

    module_function :update, :download_all, :import_all, :unpack, :import
    private_class_method :unpack, :import
  end
end
