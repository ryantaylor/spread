require_relative "spread/version"
require_relative "spread/bond"

require "csv"

CORPORATE = "corporate"
GOVERNMENT = "government"

module Spread
  def self.calc(csv_file)
    corporate_bonds, government_bonds = parse_csv(csv_file)
    spread_to_benchmark(corporate_bonds, government_bonds)
    spread_to_curve(corporate_bonds, government_bonds)
  end

  def self.parse_csv(csv_file)
    corporate_bonds = Array.new
    government_bonds = Array.new

    input = CSV.read(csv_file)
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

    corporate_bonds.sort! { |a,b| a.term_years <=> b.term_years }
    government_bonds.sort! { |a,b| a.term_years <=> b.term_years }

    return corporate_bonds, government_bonds
  end

  def self.spread_to_benchmark(corporate_bonds, government_bonds)
    puts "bond,benchmark,spread_to_benchmark"

    corporate_bonds.each do |corp_bond|
      first = true
      bench_spread = 0.0
      benchmark = nil
      government_bonds.each do |gov_bond|
        if first
          bench_spread = (corp_bond.term_years - gov_bond.term_years).abs
          benchmark = gov_bond
          first = false
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

  def self.spread_to_curve(corporate_bonds, government_bonds)
    puts "bond,spread_to_curve"

    corporate_bonds.each do |corp_bond|
      upper_bench = nil
      lower_bench = nil
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
        yield_on_curve = lower_bench.yield_percent + 
                         (corp_bond.term_years - lower_bench.term_years) *
                         ((upper_bench.yield_percent - lower_bench.yield_percent) /
                          (upper_bench.term_years - lower_bench.term_years))
        spread_to_curve = corp_bond.yield_percent - yield_on_curve
      end

      puts "#{corp_bond.name},#{spread_to_curve.round(2)}%"
    end
    puts ""
  end
end
