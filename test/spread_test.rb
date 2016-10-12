require 'test_helper'

class SpreadTest < Minitest::Test
  @sample_output = "bond,benchmark,spread_to_benchmark
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

  def test_that_it_has_a_version_number
    refute_nil ::Spread::VERSION
  end

  def test_it_handles_sample_input
    assert_output(@sample_output) { ::Spread.calc("test/sample_input.csv") }
  end

  def test_it_handles_unordered_sample_input
    assert_output(@sample_output) { ::Spread.calc("test/sample_input_unordered.csv") }
  end
end
