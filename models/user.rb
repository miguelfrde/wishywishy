class User
  include Mongoid::Document
  field :fbid, type: String
  embeds_many :events
  has_many :groups, :inverse_of => :owner
  has_many :gifts, :class_name => 'Item', :inverse_of => :picker
end
