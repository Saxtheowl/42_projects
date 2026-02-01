# frozen_string_literal: true

class Client < ApplicationRecord
  belongs_to :company, optional: true
  belongs_to :user, optional: true

  has_many :projects, dependent: :destroy
  has_many :activity_logs, as: :trackable, dependent: :destroy

  validates :first_name, :last_name, :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  def self.ordered_alphabetically
    order(:last_name, :first_name)
  end

  def self.ordered_by_company
    joins(:company).order('companies.name', :last_name, :first_name)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def self.import_from_csv(file, user)
    require 'roo'
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1).map(&:downcase)

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      company = Company.find_or_create_by(name: row['company']) if row['company'].present?

      client = Client.new(
        first_name: row['first_name'] || row['prenom'],
        last_name: row['last_name'] || row['nom'],
        email: row['email'],
        phone: row['phone'] || row['tel'],
        position: row['position'] || row['fonction'],
        company: company,
        user: user
      )
      client.save if client.valid?
    end
  end

  def self.to_csv
    require 'csv'
    attributes = %w[first_name last_name email phone position]

    CSV.generate(headers: true) do |csv|
      csv << attributes + ['company']
      all.each do |client|
        csv << attributes.map { |attr| client.send(attr) } + [client.company&.name]
      end
    end
  end
end
