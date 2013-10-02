require 'helpers'

describe GamesDice::ExplainerCause do

  describe "class method" do
    describe "#new" do
      it "should instantiate if provided with valid parameters" do
        GamesDice::ExplainerCause.new( GamesDice::DieDescription, false ).should be_a GamesDice::ExplainerCause
        GamesDice::ExplainerCause.new( GamesDice::Explainer, true ).should be_a GamesDice::ExplainerCause
      end

      it "should not instantiate if provided with invalid parameters" do
        lambda { GamesDice::ExplainerCause.new( :die_description, false ) }.should raise_error TypeError
      end
    end
  end # describe "class method"

  describe "instance method" do

  end # describe "instance method"

end # describe GamesDice::ExplainerCause