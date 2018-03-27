require "jipcode/version"
require 'csv'

module Jipcode
  ZIPCODE_PATH = "#{File.dirname(__FILE__)}/../zipcode/latest".freeze

  def locate(zipcode)
    path = "#{ZIPCODE_PATH}/#{zipcode[0..2]}.csv"
    return [] unless File.exist?(path)

    addresses_csv = open(path) { |f| f.read }
    addresses_array = CSV.parse(addresses_csv).select { |address| address[0] == zipcode }
    addresses_array.map do |address_param|
      {
        zipcode:    address_param[0],
        prefecture: address_param[1],
        city:       address_param[2],
        town:       address_param[3]
      }
    end
  end

  def search(zipcode)
    warn '[DEPRECATION] `search` is deprecated.  Please use `locate` instead.'
    path = "#{ZIPCODE_PATH}/#{zipcode[0..2]}.csv"
    return [] unless File.exist?(path)
    addresses = open(path) { |f| f.read }
    CSV.parse(addresses).select { |address| address[0] == zipcode }
  end

  module_function :locate, :search
end
