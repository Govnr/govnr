class DraftVersion < ActiveRecord::Base
	belongs_to :draft
  belongs_to :updater, class_name: 'User'

  before_update :raise_on_update

  scope :between, lambda { |first, last|
    first = first.to_i
    last = last.to_i
    first, last = last, first if last < first # Reordering if neeeded

    where('number >= ? AND number <= ?', first, last)
  }

  def next
    self.class.first conditions: ["id > ? AND draft_id = ?", id, page_id], order: 'id ASC'
  end

  def previous
    self.class.first conditions: ["id < ? AND draft_id = ?", id, page_id], order: 'id DESC'
  end

  private

  def raise_on_update
    raise ActiveRecordError, "Can't modify existing version"
  end

end
