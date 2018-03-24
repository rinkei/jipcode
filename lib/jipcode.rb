require "jipcode/version"
require 'csv'

module Jipcode
  ZIPCODE_PATH = 'zipcode/latest'.freeze

  def search(zipcode)
    path = "#{ZIPCODE_PATH}/#{zipcode[0..2]}.csv"
    return [] unless File.exist?(path)
    addresses = open(path) { |f| f.read }
    CSV.parse(addresses).select { |address| address[0] == zipcode }
  end

  module_function :search
end
