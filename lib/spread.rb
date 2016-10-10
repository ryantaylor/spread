require_relative "spread/version"
require_relative "spread/bond"

require "csv"

# Bond spread-to-benchmark and spread-to-curve calculator.
module Spread
  # Corporate bond issue type identifier.
  CORPORATE = "corporate"
  # Government bond issue type identifier.
  GOVERNMENT = "government"

  # Parses the given CSV file and runs calculation procedures to determine the
  # spread to benchmark and spread to curve of the given bonds.
  #
  # @param csv_file [String] Path to a properly formatted CSV file of bond information.
  # @return [void]
  def self.calc(csv_file)
    corporate_bonds, government_bonds = parse_csv(csv_file)
    spread_to_benchmark(corporate_bonds, government_bonds)
    spread_to_curve(corporate_bonds, government_bonds)
  end

  # Parses the given CSV file and splits bonds into two arrays, one for
  # corporate issues and one for government issues. This function will fail
  # with an exception if the given path does not point to a valid and properly
  # formatted CSV file. Input CSV file is assumed to be in the following format:
  #
  # bond,type,term,yield<br>
  # C1,corporate,1.3 years,3.30%<br>
  # G1,government,0.9 years,1.70%<br>
  # G2,government,2.3 years,2.30%
  #
  # @param csv_file [String] Path to a properly formatted CSV file of bond information.
  # @return [[Array<Bond>, Array<Bond>]] A tuple of parsed Bond arrays separated by issue type in the format [corporate_bonds, government_bonds].
  def self.parse_csv(csv_file)
    corporate_bonds = Array.new
    government_bonds = Array.new

    # This will raise a (currently un-rescued) exception if csv_file does not
    # point to a valid CSV file.
    input = CSV.read(csv_file)

    # We shift the iterator one place to skip over the header row in the CSV
    # file. This could be changed to check if the header is as expected, but
    # because I'm already assuming valid input and failing outright otherwise I
    # didn't bother.
    input.shift

    input.each do |row|
      bond = Bond.new(row[0], row[1], row[2], row[3])
      case bond.issue
      when CORPORATE
        corporate_bonds.push(bond)
      when GOVERNMENT
        government_bonds.push(bond)
      end
    end

    # This sorting is important because the spread_to_curve function assumes
    # that these arrays are ordered by term, with shorter terms at the beginning
    # and longer terms at the end.
    corporate_bonds.sort! { |a,b| a.term_years <=> b.term_years }
    government_bonds.sort! { |a,b| a.term_years <=> b.term_years }

    return corporate_bonds, government_bonds
  end

  # Takes an array of corporate and an array of government bonds, finds the
  # appropriate government benchmark bond for each corporate bond, and then
  # calculates the yield spreads from the corporate bonds to their
  # corresponding benchmark government bonds. This function writes comma-
  # separated values to stdout, with a newline at the end, in the following
  # format:
  #
  # bond,benchmark,spread_to_yield<br>
  # C1,G1,1.60%
  #
  # @param corporate_bonds [Array<Bond>] an array of Bond objects with "corporate" issue types.
  # @param government_bonds [Array<Bond>] an array of Bond objects with "government" issue types.
  # @return [void]
  def self.spread_to_benchmark(corporate_bonds, government_bonds)
    puts "bond,benchmark,spread_to_benchmark"

    corporate_bonds.each do |corp_bond|
      bench_spread = nil
      benchmark = nil

      # This block iterates through each of the government bonds and finds the
      # bond with the smallest term spread to use as the benchmark. Because the
      # government_bonds array was sorted when loaded from CSV, this loop could
      # be short-circuited for increased performance. However, I couldn't find a
      # clean way to do it, and decided that readability was more important than
      # a negligible performance improvement in this situation.
      government_bonds.each do |gov_bond|
        if bench_spread == nil
          bench_spread = (corp_bond.term_years - gov_bond.term_years).abs
          benchmark = gov_bond
        else
          term_spread = (corp_bond.term_years - gov_bond.term_years).abs
          if term_spread < bench_spread
            bench_spread = term_spread
            benchmark = gov_bond
          end
        end
      end

      spread_to_benchmark = (corp_bond.yield_percent - benchmark.yield_percent).abs
      puts "#{corp_bond.name},#{benchmark.name},#{spread_to_benchmark.round(2)}%"
    end
    puts ""
  end

  # Takes an array of corporate and an array of government bonds and calculates,
  # using linear interpolation, the spread to curve for each corporate bond.
  # This function writes comma-separated values to stdout, with a newline at the
  # end, in the following format:
  #
  # bond,spread_to_curve<br>
  # C1,1.22%<br>
  # C2,2.98%
  #
  # From http://www.blueleafsoftware.com/Products/Dagra/LinearInterpolationExcel.php,
  # the formula for linear interpolation is as follows:
  #
  # y = y1 + (x - x1) * ((y2 - y1) / (x2 - x1))
  #
  # Where
  #
  # x1 = term in years of the lower-bound benchmark government bond.<br>
  # y1 = yield in percentage of the lower-bound benchmark government bond.<br>
  # x2 = term in years of the higher-bound benchmark government bond.<br>
  # y2 = yield in percentage of the higher-bound benchmark government bond.<br>
  # x = term in years of the corporate bond whose spread-to-curve is being calculated.<br>
  # y = yield in percentage on the curve between benchmark government bonds at the term of the corporate bond.
  #
  # And the formula for spread-to-curve is as follows:
  #
  # spread_to_curve = corporate_bond_yield - y
  #
  # @param corporate_bonds [Array<Bond>] an array of Bond objects with "corporate" issue types.
  # @param government_bonds [Array<Bond>] an array of Bond objects with "government" issue types.
  # @return [void]
  def self.spread_to_curve(corporate_bonds, government_bonds)
    puts "bond,spread_to_curve"

    corporate_bonds.each do |corp_bond|
      upper_bench = nil
      lower_bench = nil

      # This block assumes that for every corporate bond in the given input,
      # there exists a government bond with a term less than or equal to the
      # corporate bond's term. It also assumes that there exists a government
      # bond with a term greater than the corporate bond's term. I added edge
      # case handling for a government bond with the same term as the corporate
      # bond, but I haven't used Ruby enough to know how it handles float
      # comparison, and because it wasn't part of the requirements I didn't
      # investigate further.
      #
      # Note that this block assumes the government_bonds array is sorted by
      # ascending terms. This allows me to assume that lower_bench will always
      # be populated before upper_bench, which means I can short-circuit the
      # loop once I find my upper_bench bond.
      government_bonds.each do |gov_bond|
        if corp_bond.term_years == gov_bond.term_years
          lower_bench = gov_bond
          break
        elsif gov_bond.term_years < corp_bond.term_years
          lower_bench = gov_bond
        else
          upper_bench = gov_bond
          break
        end
      end

      if lower_bench.term_years == corp_bond.term_years
        spread_to_curve = corp_bond.yield_percent - lower_bench.yield_percent
      else
        # This is the equation for linear interpolation as described above.
        yield_on_curve = lower_bench.yield_percent + 
                         (corp_bond.term_years - lower_bench.term_years) *
                         ((upper_bench.yield_percent - lower_bench.yield_percent) /
                          (upper_bench.term_years - lower_bench.term_years))
        # This is the equation for spread-to-curve as described above.
        spread_to_curve = corp_bond.yield_percent - yield_on_curve
      end

      puts "#{corp_bond.name},#{spread_to_curve.round(2)}%"
    end
    puts ""
  end
end
