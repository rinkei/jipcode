require "jipcode/version"
require "jipcode/address_locator"
require 'csv'

module Jipcode
  ZIPCODE_PATH = "#{File.dirname(__FILE__)}/../zipcode/latest".freeze

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
    AddressLocator
      .locate(search_address)
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
