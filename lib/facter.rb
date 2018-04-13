# frozen_string_literal: true

module Facter
  def self.value(_name)
    'dummy'
  end

  def self.add(*); end

  def self.search(*); end

  def self.reset; end
end
