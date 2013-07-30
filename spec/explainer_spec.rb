require 'helpers'

describe GamesDice::Explainer do
  describe "class method" do
    describe "#new" do
      it "should instantiate if provided with valid parameters" do
        GamesDice::Explainer.new( '3d6', 12, :sum, [1,5,6] ).should be_a GamesDice::Explainer
      end
    end
  end # describe "class method"

  describe "instance method" do
    let( :ge_simple ) { GamesDice::Explainer.new( '3d6', 12, :sum, [1,5,6] ) }
    let( :ge_complex01 ) { GamesDice::Explainer.new( '3d6', 12, :sum, [
        1,5, GamesDice::Explainer.new('1d6', 6, :reroll, [4,5,6] ) ] ) }
    let( :ge_complex02 ) { GamesDice::Explainer.new( '3d6', 12, :sum, [
        1,5, GamesDice::DieResult.new(6) ] ) }
    let( :ge_complex03 ) {
      result = GamesDice::DieResult.new(6)
      result.add_roll( 6, :reroll_replace )
      GamesDice::Explainer.new( '3d6', 12, :sum, [
        1,5, result ] ) }
    let( :ge_complex04 ) { GamesDice::Explainer.new( 'weird', 36, :sum, [ge_complex03, ge_simple, ge_complex01 ] ) }

    describe "#content_depth" do
      it "should return 0 for a simple explanation" do
        ge_simple.content_depth.should == 0
        ge_complex02.content_depth.should == 0
      end

      it "should return corrrect numbers for more complex explanations" do
        ge_complex01.content_depth.should == 1
        ge_complex03.content_depth.should == 1
        ge_complex04.content_depth.should == 2
      end
    end


  end # describe "instance method"

end # describe GamesDice::Explainer