module Spread
  class Bond
    PERCENT = "%"

    attr_reader :name, :issue, :term_years, :yield_percent

    def initialize(name, issue, term_years, yield_percent)
      @name = name
      @issue = issue
      @term_years = term_years.split[0].to_f
      @yield_percent = yield_percent.delete(PERCENT).to_f
    end
  end
end
