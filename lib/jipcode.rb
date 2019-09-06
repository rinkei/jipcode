require "jipcode/version"
require 'csv'
require 'yaml'

module Jipcode
  ZIPCODE_PATH = "#{File.dirname(__FILE__)}/../zipcode/latest".freeze
  PREFECTURE_CODE_PATH = "#{File.dirname(__FILE__)}/../prefecture_code.yml".freeze

  def locate(zipcode, opt={})
    # 数字7桁以外の入力は受け付けない
    return [] unless zipcode =~ /\A\d{7}?\z/

    # 上3桁にマッチするファイルが存在しなければ該当なし
    path = "#{ZIPCODE_PATH}/#{zipcode[0..2]}.csv"
    return [] unless File.exist?(path)

    addresses_array = CSV.read(path).select { |address| address[0] == zipcode }

    if opt.empty?
      addresses_array.map { |address_params| address_from(address_params) }
    else
      extending_params = {}

      if opt[:prefecture_code]
        return [] unless prefecture = addresses_array[0] && addresses_array[0][1]
        extending_params[:prefecture_code] = YAML.load_file(PREFECTURE_CODE_PATH).invert[prefecture]
      end

      addresses_array.map { |address_params| address_from(address_params).merge(extending_params) }
    end
  end

  def address_from(address_params)
    {
      zipcode:    address_params[0],
      prefecture: address_params[1],
      city:       address_params[2],
      town:       address_params[3]
    }
  end

  module_function :locate, :address_from
end
