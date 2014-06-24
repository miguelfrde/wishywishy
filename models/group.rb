class Group
  include Mongoid::Document
  field :name, type: String
  belongs_to :owner, :class_name => 'User', :inverse_of => :groups
  has_many :wishes, :class_name => 'Item', :inverse_of => :group
  has_and_belongs_to_many :friends, :class_name => 'User',
    :inverse_of => :in_groups
end
