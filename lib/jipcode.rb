require "jipcode/version"
require 'csv'
require 'yaml'

module Jipcode
  ZIPCODE_PATH = "#{File.dirname(__FILE__)}/../zipcode/latest".freeze
  PREFECTURE_CODE = YAML.load_file("#{File.dirname(__FILE__)}/../data/prefecture_code.yml").freeze

  def locate(zipcode)
    # 数字7桁以外の入力は受け付けない
    return [] unless zipcode =~ /\A\d{7}?\z/

    # 上3桁にマッチするファイルが存在しなければ該当なし
    path = "#{ZIPCODE_PATH}/#{zipcode[0..2]}.csv"
    return [] unless File.exist?(path)

    addresses_array = CSV.read(path).select { |address| address[0] == zipcode }
    addresses_array.map do |address_param|
      {
        zipcode:         address_param[0],
        prefecture:      address_param[1],
        city:            address_param[2],
        town:            address_param[3],
        prefecture_code: PREFECTURE_CODE.invert[address_param[1]]
      }
    end
  end

  module_function :locate
end
