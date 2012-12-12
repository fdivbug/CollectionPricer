class Card < ActiveRecord::Base
  attr_accessible :expansion, :name, :price
end
