require 'helpers'

describe GamesDice::ExplainerCause do

  describe "class method" do
    describe "#new" do
      it "should instantiate if provided with valid parameters" do
        GamesDice::ExplainerCause.new( GamesDice::DieDescription, false, :complex_die ).should be_a GamesDice::ExplainerCause
        GamesDice::ExplainerCause.new( GamesDice::Explainer, true, :sum ).should be_a GamesDice::ExplainerCause
      end

      it "should not instantiate if provided with invalid parameters" do
        lambda { GamesDice::ExplainerCause.new( :die_description, false, :foo ) }.should raise_error TypeError
      end
    end
  end # describe "class method"

  describe "instance method" do
    let(:cause_dd) { GamesDice::ExplainerCause.new( GamesDice::DieDescription, false, :roll ) }
    let(:cause_explainlist) { GamesDice::ExplainerCause.new( GamesDice::Explainer, true, :sum ) }
    let(:valid_die_desc) { GamesDice::DieDescription.new(6) }
    let(:valid_explanation) { GamesDice::Explainer.new( 'foo', 6, cause_dd, valid_die_desc ) }

    describe "#check_details" do
      it "should not raise errors when details are valid" do
        lambda { cause_dd.check_details( valid_die_desc ) }.should_not raise_error
        lambda { cause_explainlist.check_details( [valid_explanation] ) }.should_not raise_error
      end

      it "should raise errors when details are not valid" do
        lambda { cause_explainlist.check_details( valid_die_desc ) }.should raise_error TypeError
        lambda { cause_explainlist.check_details( 44 ) }.should raise_error TypeError
        lambda { cause_explainlist.check_details( [] ) }.should raise_error ArgumentError
        lambda { cause_explainlist.check_details( [valid_die_desc] ) }.should raise_error TypeError

        lambda { cause_dd.check_details( 44 ) }.should raise_error TypeError
        lambda { cause_dd.check_details( [] ) }.should raise_error TypeError
        lambda { cause_dd.check_details( [valid_die_desc] ) }.should raise_error TypeError
        lambda { cause_dd.check_details( valid_explanation ) }.should raise_error TypeError
      end
    end
  end # describe "instance method"

end # describe GamesDice::ExplainerCause