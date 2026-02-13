class Task < ApplicationRecord
  STATUSES = %w[pending doing done].freeze

  validates :title,
            presence: true,
            length: { minimum: 3 }

  validates :status,
            presence: true,
            inclusion: { in: STATUSES }
end
