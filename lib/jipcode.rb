require "jipcode/version"
require 'csv'

module Jipcode
  ZIPCODE_PATH = "#{File.dirname(__FILE__)}/../zipcode/latest".freeze

  def locate(zipcode)
    path = "#{ZIPCODE_PATH}/#{zipcode[0..2]}.csv"
    return [] unless File.exist?(path)

    addresses_array = CSV.read(path).select { |address| address[0] == zipcode }
    addresses_array.map do |address_param|
      {
        zipcode:    address_param[0],
        prefecture: address_param[1],
        city:       address_param[2],
        town:       address_param[3]
      }
    end
  end

  module_function :locate
end
