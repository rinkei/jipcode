require 'csv'
require 'jaro_winkler'
require 'jipcode'

module Jipcode
  module AddressLocator
    # http://nlftp.mlit.go.jp/ksj/gml/codelist/PrefCd.html
    PREFECTURE_CODE = {
      '北海道' => 1,
      '青森県' => 2,
      '岩手県' => 3,
      '宮城県' => 4,
      '秋田県' => 5,
      '山形県' => 6,
      '福島県' => 7,
      '茨城県' => 8,
      '栃木県' => 9,
      '群馬県' => 10,
      '埼玉県' => 11,
      '千葉県' => 12,
      '東京都' => 13,
      '神奈川県' => 14,
      '新潟県' => 15,
      '富山県' => 16,
      '石川県' => 17,
      '福井県' => 18,
      '山梨県' => 19,
      '長野県' => 20,
      '岐阜県' => 21,
      '静岡県' => 22,
      '愛知県' => 23,
      '三重県' => 24,
      '滋賀県' => 25,
      '京都府' => 26,
      '大阪府' => 27,
      '兵庫県' => 28,
      '奈良県' => 29,
      '和歌山県' => 30,
      '鳥取県' => 31,
      '島根県' => 32,
      '岡山県' => 33,
      '広島県' => 34,
      '山口県' => 35,
      '徳島県' => 36,
      '香川県' => 37,
      '愛媛県' => 38,
      '高知県' => 39,
      '福岡県' => 40,
      '佐賀県' => 41,
      '長崎県' => 42,
      '熊本県' => 43,
      '大分県' => 44,
      '宮崎県' => 45,
      '鹿児島県' => 46,
      '沖縄県' => 47
    }

    PREFECTURE_PATH = "#{File.dirname(__FILE__)}/../../zipcode/by_prefecture/latest".freeze

    PREVIOUS_PREFECTURE_PATH = "#{File.dirname(__FILE__)}/../../zipcode/by_prefecture/previous".freeze

    def export_csv_by_prefecture
      File.rename(PREFECTURE_PATH, PREVIOUS_PREFECTURE_PATH) if File.exist?(PREFECTURE_PATH)
      Dir.mkdir(PREFECTURE_PATH)

      # 都道府県コードは1から始まるので一つ余計に作る
      prefecture_csvs = Array.new(PREFECTURE_CODE.size + 1) { [] }

      Dir.glob("#{ZIPCODE_PATH}/*.csv").each do |file_name|
        csv = CSV.read(file_name)
        csv.each do |row|
          _zipcode, prefecture, _city, _town = row
          prefecture_code = PREFECTURE_CODE[prefecture]
          prefecture_csvs[prefecture_code] << row
        end
      end

      # 都道府県コード0を削除
      prefecture_csvs.shift

      # Export
      prefecture_csvs.each.with_index(1) do |rows, prefecture_code|
        rows.sort_by! { |row| row[0] }
        CSV.open("#{PREFECTURE_PATH}/#{prefecture_code}.csv", "wb") do |csv|
          rows.each { |row| csv << row }
        end
      end

      FileUtils.rm_rf(PREVIOUS_PREFECTURE_PATH)
    rescue => e
      FileUtils.rm_rf(PREFECTURE_PATH)
      File.rename(PREVIOUS_PREFECTURE_PATH, PREFECTURE_PATH) if File.exist?(PREVIOUS_PREFECTURE_PATH)
      raise e, '都道府県別CSVの出力に失敗しました'
    end

    def locate(search_address)
      prefecture_code = prefecture_code(search_address)
      return [] if prefecture_code.nil?
      path = "#{PREFECTURE_PATH}/#{prefecture_code}.csv"

      # 検索語句と住所データ
      filtered = CSV.read(path).select do |row|
        address = row[1..3].join('')
        # 長いほうが短い方に含まれてるか判別
        long = [address, search_address].max
        short = [address, search_address].min
        long.start_with?(short)
      end

      # 編集距離を測定
      with_distance = filtered.map do |row|
        combined = row[1..3].join('')
        distance = JaroWinkler.distance(combined, search_address)
        row << distance
      end

      # 近い順にソート
      # ジャロウィンクラー距離は1に近いほど類似度が高い
      with_distance
        .sort_by { |row| row.last }
        .reverse
    end

    def prefecture_code(address)
      prefecture_name = address.match(/\A(#{prefecture_names.join('|')})/).to_s
      PREFECTURE_CODE[prefecture_name]
    end

    def prefecture_names
      PREFECTURE_CODE.keys
    end

    module_function :export_csv_by_prefecture, :locate, :prefecture_code, :prefecture_names
    private_class_method :prefecture_names, :prefecture_code
  end
end
