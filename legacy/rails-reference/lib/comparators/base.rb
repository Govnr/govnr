require 'irwi/comparators/spans/changed_span'
require 'irwi/comparators/spans/not_changed_span'

class Comparators::Base

	def render_changes(old_text, new_text)
    build_changes(old_text, new_text).join('').gsub(/\r?\n/, '<br />')
  end

  protected

	def new_not_changed(value)
		Comparators::Spans::NotChangedSpan.new(value)
	end

	def new_changed(action, old_value, new_value)
	    Comparators::Spans::ChangedSpan.new(action, old_value, new_value)
	end

end