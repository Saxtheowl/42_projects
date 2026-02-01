# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ROLES = %w[admin manager operator].freeze
  OPERATOR_GROUPS = %w[Production International Commercial].freeze

  has_many :sent_mails, class_name: 'InMail', foreign_key: 'sender_id', dependent: :destroy
  has_many :received_mails, class_name: 'InMail', foreign_key: 'recipient_id', dependent: :destroy
  has_many :clients, dependent: :nullify
  has_many :projects, dependent: :nullify
  has_many :surveys, dependent: :destroy
  has_many :activity_logs, dependent: :destroy

  validates :role, inclusion: { in: ROLES }, allow_nil: true
  validates :operator_group, inclusion: { in: OPERATOR_GROUPS }, allow_nil: true
  validates :first_name, :last_name, presence: true

  def admin?
    role == 'admin'
  end

  def manager?
    role == 'manager'
  end

  def operator?
    role == 'operator'
  end

  def registered?
    persisted?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def can_access_admin?
    admin?
  end

  def can_access_backoffice?
    admin? || manager?
  end

  def can_manage_users?
    admin?
  end

  def can_assign_groups?
    admin? || manager?
  end

  def can_create_project?
    manager? || admin?
  end

  def can_read_all_mails?
    manager? || admin?
  end

  def unread_mails_count
    received_mails.where(read: false).count
  end
end
