class UserPassword < ApplicationRecord
  ROLES = %w[Owner Viewer Editor].freeze

  belongs_to :password
  belongs_to :user

  validates :role, presence: true, inclusion: { in: ROLES }

  attribute :role, default: :Viewer

  def editable?
    owner? || editor?
  end

  def shareable?
    owner?
  end

  def destroyable?
    owner?
  end

  private

  ROLES.each do |type|
    define_method("#{type.downcase}?") do
      role == type
    end
  end
end
