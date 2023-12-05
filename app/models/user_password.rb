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

  def owner?
    role == 'Owner'
  end

  def viewer?
    role == 'Viewer'
  end

  def editor?
    role == 'Editor'
  end
end
