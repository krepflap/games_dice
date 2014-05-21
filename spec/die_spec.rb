require 'helpers'

describe GamesDice::Die do

  before do
    # Set state of default PRNG
    srand(4567)
  end

  describe "#new" do
    it "should return an object that represents e.g. a six-sided die" do
      die = GamesDice::Die.new(6)
      die.min.should == 1
      die.max.should == 6
      die.sides.should == 6
    end

    it "should accept any object with a rand(Integer) method as the second param" do
      prng = TestPRNG.new()
      die = GamesDice::Die.new(20,prng)
      [16,7,3,11,16,18,20,7].each do |expected|
        die.roll.should == expected
        die.result.should == expected
      end
    end
  end

  describe "#roll and #result" do
    it "should return results based on Ruby's internal rand() by default" do
    die = GamesDice::Die.new(10)
      [5,4,10,4,7,8,1,9].each do |expected|
        die.roll.should == expected
        die.result.should == expected
      end
    end
  end

  describe "#min and #max" do
    it "should calculate correct min, max" do
      die = GamesDice::Die.new(20)
      die.min.should == 1
      die.max.should == 20
    end
  end

  describe "#probabilities" do
    it "should return the die's probability distribution as a GamesDice::Probabilities object" do
      die = GamesDice::Die.new(6)
      probs = die.probabilities
      probs.is_a?( GamesDice::Probabilities ).should be_true

      probs.to_h.should be_valid_distribution

      probs.p_eql(1).should be_within(1e-10).of 1/6.0
      probs.p_eql(2).should be_within(1e-10).of 1/6.0
      probs.p_eql(3).should be_within(1e-10).of 1/6.0
      probs.p_eql(4).should be_within(1e-10).of 1/6.0
      probs.p_eql(5).should be_within(1e-10).of 1/6.0
      probs.p_eql(6).should be_within(1e-10).of 1/6.0

      probs.expected.should be_within(1e-10).of 3.5
    end
  end

  describe "#all_values" do
    it "should return array with one result value per side" do
      die = GamesDice::Die.new(8)
      die.all_values.should == [1,2,3,4,5,6,7,8]
    end
  end

  describe "#each_value" do
    it "should iterate through all sides of the die" do
      die = GamesDice::Die.new(10)
      arr = []
      die.each_value { |x| arr << x }
      arr.should == [1,2,3,4,5,6,7,8,9,10]
    end
  end

  describe "#description" do
    it "should return a description object" do
      die = GamesDice::Die.new(12)
      die.description.should be_a GamesDice::DieDescription
      die.description.sides.should == 12
      die.description.label.should == 'd12'
    end
  end

  describe "#result_explainer" do
    it "should return an explanation of the result" do
      die = GamesDice::Die.new(10)
      die.roll
      ex = die.result_explainer
      ex.should be_a GamesDice::Explainer
      ex.number.should == 5
      ex.template_hash_depth_first.should match_explanation [
        { :label=>"1d10", :number=>5, :cause=>:roll, :depth=>0, :first=>true, :last=>true,
          :only=>true, :index=>0, :has_children => false, :die_sides => 10, :die_label => 'd10' }
      ]
      ex.standard_text.should == "1d10: 5"
    end
  end

  describe "#explain_result" do
    it "should return a string explanation of the result" do
      die = GamesDice::Die.new(10)
      die.roll
      die.explain_result.should == "1d10: 5"
    end
  end

end