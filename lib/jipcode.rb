require "jipcode/version"
require "jipcode/prefecture_exporter"
require 'csv'
require 'jaro_winkler'

module Jipcode
  ZIPCODE_PATH = "#{File.dirname(__FILE__)}/../zipcode/latest".freeze
  PREFECTURE_PATH = "#{File.dirname(__FILE__)}/../zipcode/by_prefecture/latest".freeze

  def locate(zipcode)
    # 数字7桁以外の入力は受け付けない
    return [] unless zipcode =~ /\A\d{7}?\z/

    # 上3桁にマッチするファイルが存在しなければ該当なし
    path = "#{ZIPCODE_PATH}/#{zipcode[0..2]}.csv"
    return [] unless File.exist?(path)

    addresses_array = CSV.read(path).select { |address| address[0] == zipcode }
    addresses_array.map { |address| make_address(address) }
  end

  def locate_by_address(search_address)
    prefecture_code = PrefectureExporter.prefecture_code(search_address)
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
      .map { |row| make_address(row) }
  end

  # Private

  def make_address(address_param)
    address = {
      zipcode:    address_param[0],
      prefecture: address_param[1],
      city:       address_param[2],
      town:       address_param[3]
    }

    if address_param[4]
      address[:distance] = address_param[4]
    end

    address
  end

  module_function :locate, :locate_by_address, :make_address
  private_class_method :make_address
end
