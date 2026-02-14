class Task < ApplicationRecord
  STATUSES = %w[pending doing done].freeze

  validates :title,
            presence: true,
            length: { minimum: 3 }

  validates :status,
            presence: true,
            inclusion: { in: STATUSES }

  before_validation :set_default_status

  def self.list(filters = {})
    relation = all
    relation = relation.where(status: filters[:status]) if filters[:status].present?
    relation = relation.where(due_date: filters[:due_date]) if filters[:due_date].present?
    relation = relation.order(due_date: :asc)

    page = filters[:page].to_i.positive? ? filters[:page].to_i : 1
    per_page = filters[:per_page].to_i.positive? ? filters[:per_page].to_i : 10

    total = relation.count
    records = relation.offset((page - 1) * per_page).limit(per_page)

    { records: records, total: total, per_page: per_page, page: page }
  end

  private

  def set_default_status
    self.status ||= 'pending'
  end
end
