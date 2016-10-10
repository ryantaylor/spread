module Spread
  # Representation of bond input information.
  class Bond
    # Percentage symbol removed from CSV when parsing.
    PERCENT = "%"

    # @return [String] Bond name.
    attr_reader :name
    # @return [String] Bond issue type. Assumed to be either "corporate" or "government".
    attr_reader :issue
    # @return [Numeric] Length of the bond's term, in years, as a float.
    attr_reader :term_years
    # @return [Numeric] Percentage yield of the bond, as a float out of 100%, for example 3.3(%).
    attr_reader :yield_percent

    # Constructs a new Bond object.
    # @param name [String] Bond name.
    # @param issue [String] Bond issue type. Assumed to be either "corporate" or "government".
    # @param term_years [String] Length of the bond's term. Assumed to be in the format "12.3 years".
    # @param yield_percent [String] Percentage yield of the bond. Assumed to be in the format "3.30%".
    # @return [Bond] A newly created Bond object with term_years and yield_percent parsed into floats.
    def initialize(name, issue, term_years, yield_percent)
      @name = name
      @issue = issue
      # This may fail without rescue or return an unknown value if term_years is
      # not a String in the format "13.2 years".
      @term_years = term_years.split[0].to_f
      # This may fail without rescue or return an unknown value if yield_percent
      # is not a String in the format "3.30%".
      @yield_percent = yield_percent.delete(PERCENT).to_f
    end
  end
end
