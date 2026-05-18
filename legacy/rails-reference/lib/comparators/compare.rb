require 'active_support'

class Comparators::Compare

  # Object using to compare pages
  attr_writer :comparator

  # def comparator
  #   @comparator ||= begin
  #                     require '/comparators/diff_lcs'
  #                     self.comparator = Comparators::DiffLcs.new
  #                   end
  # end

    def self.comparator
	    @comparator ||= begin
                      require 'comparators/diff_lcs'
                      Comparators::DiffLcs.new
                    end
	end

end