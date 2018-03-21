require "jipcode/version"
require 'csv'

module Jipcode
  ZIPCODE_PATH = 'zipcode/latest'.freeze

  def search(zipcode)
    path = "#{ZIPCODE_PATH}/#{zipcode[0..2]}/#{zipcode[3..6]}.csv"
    return [] unless File.exist?(path)
    addresses = open(path) { |f| f.read }
    CSV.parse(addresses)
  end

  module_function :search
end
