class User
  include Mongoid::Document
  field :fbid, type: String
  embeds_many :events
  has_many :groups, :inverse_of => :owner
  has_and_belongs_to_many :in_groups, :class_name => 'Group',
    :inverse_of => :friends
  has_many :gifts, :class_name => 'Item', :inverse_of => :picker
end
