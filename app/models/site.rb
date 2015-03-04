class Site < ActiveRecord::Base
  has_many :contents

  validates :domain, presence: true

  # Class methods
  class << self
  end

  # Instance methods
end
