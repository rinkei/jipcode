require 'jipcode'
require 'uri'
require 'net/http'
require 'zip'
require 'nkf'

module Jipcode
  module JapanPost
    ZIPCODE_URLS = {
      general: 'https://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip'.freeze,
      company: 'https://www.post.japanpost.jp/zipcode/dl/jigyosyo/zip/jigyosyo.zip'.freeze
    }.freeze
    ZIPCODE_FILES = {
      general: 'KEN_ALL.CSV'.freeze,
      company: 'JIGYOSYO.CSV'.freeze
    }.freeze

    def update
      download_all
      import_all

      # データの更新月を記録する
      File.open('zipcode/current_month', 'w') { |f| f.write(Time.now.strftime('%Y%m')) }
    end

    def download_all
      ZIPCODE_URLS.each do |type, url|
        url = URI.parse(url)
        http = Net::HTTP.new(url.host, 443)
        http.use_ssl = true
        res = http.get(url.path)
        File.open("zipcode/#{type}.zip", 'wb') { |f| f.write(res.body) }
      end
    end

    def import_all
      File.rename(ZIPCODE_PATH, 'zipcode/previous') if File.exist?(ZIPCODE_PATH)
      Dir.mkdir(ZIPCODE_PATH)

      # 事業所のデータには都道府県、市区町村、町域、番地のカナが与えられていない
      # そのため、郵便番号情報から、都道府県、市区町村、町域のカナ読みを持っていきたいため、hashに保存しておく
      kana_dict = Hash.new ""

      zipcodes = unpack(:general)
      import(zipcodes) do |row|
        zipcode    = row[2] # 郵便番号
        prefecture = row[6] # 都道府県
        city       = row[7] # 市区町村
        town       = row[8] # 町域

        prefecture_kana = row[3] # 都道府県カナ
        city_kana       = row[4] # 市区町村カナ
        town_kana       = row[5] # 町域カナ

        kana_dict[prefecture] = prefecture_kana
        kana_dict[city]       = city_kana

        [zipcode, prefecture, city, town, prefecture_kana, city_kana, town_kana]
      end

      zipcodes = unpack(:company)
      import(zipcodes) do |row|
        zipcode    = row[7] # 郵便番号
        prefecture = row[3] # 都道府県
        city       = row[4] # 市区町村
        town       = row[5] + row[6] # 町域 + 番地

        prefecture_kana = kana_dict[prefecture]
        city_kana       = kana_dict[city]
        town_kana       = "" # [MEMO] 事業所データの町域番地に対してのカナは提供しない

        [zipcode, prefecture, city, town, prefecture_kana, city_kana, town_kana]
      end

      FileUtils.rm_rf('zipcode/previous')
    rescue => e
      FileUtils.rm_rf(ZIPCODE_PATH)
      File.rename('zipcode/previous', ZIPCODE_PATH) if File.exist?('zipcode/previous')
      raise e, '日本郵便のデータを読み込めませんでした。'
    end

    # Private

    def unpack(type)
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
        town_kana = address[6]

        if duplicated_row
          duplicated_row = false if town.end_with?('）')
          next
        else
          duplicated_row = true if town.include?('（') && !town.include?('）')
        end

        # 町域等に含まれる曖昧な表記を削除
        unless town.include?('私書箱')
          address[3] = town.sub(/(（.+|以下に掲載がない場合)$/, '')
          address[6] = town_kana.sub(/(（.+|イカニケイサイガナイバアイ)$/, '')
        end

        # 町域等の内容が市区町村の内容と重複する場合、空にする
        if town.include?('の次に番地がくる場合') || town.include?('一円')
          address[3] = nil
          address[6] = nil
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
