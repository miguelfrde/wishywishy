class Item
  include Mongoid::Document
  belongs_to :group, :inverse_of => :wishes
  belongs_to :picker, :class_name => 'User', :inverse_of => :gifts
  field :picked, type: Boolean
  field :name, type: String
  # TODO: handle images
  # field :image_path, type: String
  field :event, type: String
end
