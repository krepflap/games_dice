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
    let( :d6d ) { GamesDice::DieDescription.new( 6 ) }
    let( :roll01 ) { GamesDice::Explainer.new( 'd6', 1, :atom, nil, d6d ) }
    let( :roll02 ) { GamesDice::Explainer.new( 'd6', 2, :atom, nil, d6d ) }
    let( :roll03 ) { GamesDice::Explainer.new( 'd6', 3, :atom, nil, d6d ) }
    let( :roll04 ) { GamesDice::Explainer.new( 'd6', 4, :atom, nil, d6d ) }
    let( :roll05 ) { GamesDice::Explainer.new( 'd6', 5, :atom, nil, d6d ) }
    let( :roll06 ) { GamesDice::Explainer.new( 'd6', 6, :atom, nil, d6d ) }

    let( :ge_simple ) { GamesDice::Explainer.new( '3d6', 12, :sum, [ roll01, roll05 , roll06 ] ) }
    let( :ge_complex01 ) { GamesDice::Explainer.new( '3d6', 12, :sum, [
        roll01, roll05, GamesDice::Explainer.new( '1d6', 6, :reroll, [ roll04, roll05, roll06 ] ) ] ) }
    let( :ge_complex02 ) { GamesDice::Explainer.new( '3d6', 12, :sum, [
        roll01, roll05, GamesDice::DieResult.new(6) ] ) }
    let( :ge_complex03 ) {
      result = GamesDice::DieResult.new(6)
      result.add_roll( 6, :reroll_replace )
      GamesDice::Explainer.new( '3d6', 12, :sum, [
        roll01, roll05, result ] ) }
    let( :ge_complex04 ) { GamesDice::Explainer.new( 'weird', 36, :sum, [ge_complex03, ge_simple, ge_complex01 ] ) }

    describe "#content_max_depth" do
      it "should return 0 for a simple explanation" do
        ge_simple.content_max_depth.should == 0
        ge_complex02.content_max_depth.should == 0
      end

      it "should return corrrect numbers for more complex explanations" do
        ge_complex01.content_max_depth.should == 1
        ge_complex03.content_max_depth.should == 1
        ge_complex04.content_max_depth.should == 2
      end
    end

    describe "#content_min_depth" do
      it "should return 0 for a simple explanation" do
        ge_simple.content_min_depth.should == 0
        ge_complex02.content_min_depth.should == 0
      end

      it "should return corrrect numbers for more complex explanations" do
        ge_complex01.content_min_depth.should == 0
        ge_complex03.content_min_depth.should == 0
        ge_complex04.content_min_depth.should == 1
      end
    end

    describe "#build_depth_first" do
      it "should work with a simple structure" do
        ge_simple.build_depth_first.should match_explanation [
         {:label=>"3d6", :number=>12, :cause=>:sum, :depth=>0, :first=>true, :last=>true, :index=>0, :only=>true },
         {:label=>"d6", :number=>1, :cause=>:atom, :depth=>1, :first=>true, :last=>false, :index=>0, :only=>false, :die_label => 'd6', :die_sides => 6 },
         {:label=>"d6", :number=>5, :cause=>:atom, :depth=>1, :first=>false, :last=>false, :index=>1, :only=>false, :die_label => 'd6', :die_sides => 6 },
         {:label=>"d6", :number=>6, :cause=>:atom, :depth=>1, :first=>false, :last=>true, :index=>2, :only=>false, :die_label => 'd6', :die_sides => 6 } ]
      end

      it "should work with a complex structure" do
        ge_complex04.build_depth_first.should match_explanation [
         {:label=>"weird", :number=>36, :cause=>:sum, :depth=>0, :first=>true, :last=>true, :index=>0, :only=>true},
         {:label=>"3d6", :number=>12, :cause=>:sum, :depth=>1, :first=>true, :last=>false, :index=>0, :only=>false},
         {:label=>"d6", :number=>1, :cause=>:atom, :depth=>2, :first=>true, :last=>false, :index=>0, :only=>false, :die_label => 'd6', :die_sides => 6 },
         {:label=>"d6", :number=>5, :cause=>:atom, :depth=>2, :first=>false, :last=>false, :index=>1, :only=>false, :die_label => 'd6', :die_sides => 6 },
         {:label=>"die", :number=>6, :cause=>:complex_die, :depth=>2, :first=>false, :last=>true, :index=>2, :only=>false},
         # TODO: This complex die needs explaining!

         {:label=>"3d6", :number=>12, :cause=>:sum, :depth=>1, :first=>false, :last=>false, :index=>1, :only=>false},
         {:label=>"d6", :number=>1, :cause=>:atom, :depth=>2, :first=>true, :last=>false, :index=>0, :only=>false, :die_label => 'd6', :die_sides => 6 },
         {:label=>"d6", :number=>5, :cause=>:atom, :depth=>2, :first=>false, :last=>false, :index=>1, :only=>false, :die_label => 'd6', :die_sides => 6 },
         {:label=>"d6", :number=>6, :cause=>:atom, :depth=>2, :first=>false, :last=>true, :index=>2, :only=>false, :die_label => 'd6', :die_sides => 6 },
         {:label=>"3d6", :number=>12, :cause=>:sum, :depth=>1, :first=>false, :last=>true, :index=>2, :only=>false },
         {:label=>"d6", :number=>1, :cause=>:atom, :depth=>2, :first=>true, :last=>false, :index=>0, :only=>false, :die_label => 'd6', :die_sides => 6 },
         {:label=>"d6", :number=>5, :cause=>:atom, :depth=>2, :first=>false, :last=>false, :index=>1, :only=>false, :die_label => 'd6', :die_sides => 6 },
         {:label=>"1d6", :number=>6, :cause=>:reroll, :depth=>2, :first=>false, :last=>true, :index=>2, :only=>false},
         {:label=>"d6", :number=>4, :cause=>:atom, :depth=>3, :first=>true, :last=>false, :index=>0, :only=>false, :die_label => 'd6', :die_sides => 6 },
         {:label=>"d6", :number=>5, :cause=>:atom, :depth=>3, :first=>false, :last=>false, :index=>1, :only=>false, :die_label => 'd6', :die_sides => 6 },
         {:label=>"d6", :number=>6, :cause=>:atom, :depth=>3, :first=>false, :last=>true, :index=>2, :only=>false, :die_label => 'd6', :die_sides => 6 },]
      end
    end

  end # describe "instance method"

end # describe GamesDice::Explainer