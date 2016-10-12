require 'test_helper'

class SpreadTest < Minitest::Test
  @sample_output_a = "bond,benchmark,spread_to_benchmark
C1,G1,1.6%
C2,G2,1.5%
C3,G3,2.0%
C4,G3,2.9%
C5,G4,0.9%
C6,G5,1.8%
C7,G6,2.5%

bond,spread_to_curve
C1,1.43%
C2,1.63%
C3,2.47%
C4,2.27%
C5,1.9%
C6,1.57%
C7,2.83%

"

  @sample_output_b = "bond,benchmark,spread_to_benchmark
C1,G1,1.0%

bond,spread_to_curve
C1,1.0%

"

  @sample_output_c = "bond,benchmark,spread_to_benchmark
C1,G2,1.0%

bond,spread_to_curve
C1,1.0%

"

  @sample_output_d = "bond,benchmark,spread_to_benchmark
C1,G2,0.5%

"

  def test_that_it_has_a_version_number
    refute_nil ::Spread::VERSION
  end

  def test_it_handles_sample_input
    assert_output(@sample_output_a) { ::Spread.calc("test/sample_input.csv") }
  end

  def test_it_handles_unordered_sample_input
    assert_output(@sample_output_a) { ::Spread.calc("test/sample_input_unordered.csv") }
  end

  def test_it_handles_equal_term_bench_lower
    assert_output(@sample_output_b) { ::Spread.calc("test/sample_input_edge.csv") }
  end

  def test_it_handles_equal_term_bench_upper
    assert_output(@sample_output_c) { ::Spread.calc("test/sample_input_edge_2.csv") }
  end

  def test_curve_fails_on_low_curve
    corporate_bonds, government_bonds = ::Spread.parse_csv("test/sample_input_bad.csv")
    assert_raises(Exception) { ::Spread.spread_to_curve(corporate_bonds, government_bonds) }
  end

  def test_curve_fails_on_high_curve
    corporate_bonds, government_bonds = ::Spread.parse_csv("test/sample_input_bad_2.csv")
    assert_raises(Exception) { ::Spread.spread_to_curve(corporate_bonds, government_bonds) }
  end

  def test_bench_works_on_low_curve
    corporate_bonds, government_bonds = ::Spread.parse_csv("test/sample_input_bad.csv")
    assert_output(@sample_output_d) { ::Spread.spread_to_benchmark(corporate_bonds, government_bonds) }
  end

  def test_bench_works_on_high_curve
    corporate_bonds, government_bonds = ::Spread.parse_csv("test/sample_input_bad_2.csv")
    assert_output(@sample_output_d) { ::Spread.spread_to_benchmark(corporate_bonds, government_bonds) }
  end
end
