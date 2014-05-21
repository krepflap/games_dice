require 'helpers'

describe GamesDice::Explainer do
  let( :d6d ) { GamesDice::DieDescription.new( 6 ) }
  let( :d8d ) { GamesDice::DieDescription.new( 8 ) }
  let( :d20d ) { GamesDice::DieDescription.new( 20 ) }
  let( :plus_6 ) { GamesDice::ConstantDescription.new( 6, 'bonus' ) }
  let( :rolled_1 ) { GamesDice::Explainer.new( 'd6', 1, GamesDice::ROLLED_VALUE_CAUSE, d6d ) }
  let( :rolled_2 ) { GamesDice::Explainer.new( 'd6', 2, GamesDice::ROLLED_VALUE_CAUSE, d6d ) }
  let( :rolled_3 ) { GamesDice::Explainer.new( 'd6', 3, GamesDice::ROLLED_VALUE_CAUSE, d6d ) }
  let( :rolled_4 ) { GamesDice::Explainer.new( 'd6', 4, GamesDice::ROLLED_VALUE_CAUSE, d6d ) }
  let( :rolled_5 ) { GamesDice::Explainer.new( 'd6', 5, GamesDice::ROLLED_VALUE_CAUSE, d6d ) }
  let( :rolled_6 ) { GamesDice::Explainer.new( 'd6', 6, GamesDice::ROLLED_VALUE_CAUSE, d6d ) }

  describe "class method" do
    describe "#new" do
      it "should instantiate if provided with valid parameters" do
        valid_params = [
          ['d20', 12, GamesDice::ROLLED_VALUE_CAUSE, d20d],
          ['2d6', 12, GamesDice::SUM_OF_CAUSE, [ rolled_6, rolled_6 ]],
        ]
        valid_params.each do |p|
          GamesDice::Explainer.new( *p ).should be_a GamesDice::Explainer
        end
      end

      it "should not instantiate if provided with bad parameters" do
        bad_params = [
          ['2d6', 12, GamesDice::SUM_OF_CAUSE, []], # Sum with no explanation
        ]
        bad_params.each do |p|
          lambda { GamesDice::Explainer.new( *p ) }.should raise_error
        end
      end
    end
  end # describe "class method"

  describe "instance method" do
    let( :ge_simple ) { GamesDice::Explainer.new( '1d20', 12, GamesDice::ROLLED_VALUE_CAUSE, d20d ) }
    let( :ge_three ) { GamesDice::Explainer.new( '3d6', 12, GamesDice::SUM_OF_CAUSE, [ rolled_3, rolled_4, rolled_5 ] ) }
    let( :ge_bunch_plus ) { GamesDice::Explainer.new( '3d6+6', 18, GamesDice::SUM_OF_CAUSE,
      [ GamesDice::Explainer.new( '3d6', 12, GamesDice::SUM_OF_CAUSE, [ rolled_6, rolled_4, rolled_2 ] ),
        GamesDice::Explainer.new( 'bonus', 6, GamesDice::CONSTANT_VALUE_CAUSE, plus_6 ) ] ) }


    describe "#content_max_depth" do
      it "should return 0 for a simple explanation" do
        ge_simple.content_max_depth.should == 0
        ge_three.content_max_depth.should == 1
      end

      it "should return corrrect numbers for more complex explanations" do
        ge_bunch_plus.content_max_depth.should == 2
      end
    end

    describe "#content_min_depth" do
      it "should return 0 for a simple explanation" do
        ge_simple.content_min_depth.should == 0
        ge_three.content_min_depth.should == 1
      end

      it "should return correct numbers for more complex explanations" do
        ge_bunch_plus.content_min_depth.should == 1
      end
    end

    describe "#template_hash_depth_first" do
      it "should work with a simple structure" do
        ge_simple.template_hash_depth_first.should match_explanation [
          { :label=>"1d20", :number=>12, :cause=>:roll, :depth=>0, :first=>true, :last=>true, :only=>true, :index=>0, :has_children => false, :die_sides => 20, :die_label => 'd20' }
        ]
      end

      it "should explain 3d6 -> 12" do
        ge_three.template_hash_depth_first.should match_explanation [
          {:label=>"3d6", :number=>12, :cause=>:sum, :has_children=>true, :depth=>0, :first=>true, :last=>true, :only=>true, :index=>0},
          {:label=>"d6", :number=>3, :cause=>:roll, :has_children=>false, :die_sides=>6, :die_label=>"d6", :depth=>1, :first=>true, :last=>false, :index=>0, :only=>false},
          {:label=>"d6", :number=>4, :cause=>:roll, :has_children=>false, :die_sides=>6, :die_label=>"d6", :depth=>1, :first=>false, :last=>false, :index=>1, :only=>false},
          {:label=>"d6", :number=>5, :cause=>:roll, :has_children=>false, :die_sides=>6, :die_label=>"d6", :depth=>1, :first=>false, :last=>true, :index=>2, :only=>false}
        ]
      end

      it "should explain 3d6+6 -> 18" do
        ge_bunch_plus.template_hash_depth_first.should match_explanation [
          {:label=>"3d6+6", :number=>18, :cause=>:sum, :has_children=>true, :depth=>0, :first=>true, :last=>true, :only=>true, :index=>0},
          {:label=>"3d6", :number=>12, :cause=>:sum, :has_children=>true, :depth=>1, :first=>true, :last=>false, :index=>0, :only=>false},
          {:label=>"d6", :number=>6, :cause=>:roll, :has_children=>false, :die_sides=>6, :die_label=>"d6", :depth=>2, :first=>true, :last=>false, :index=>0, :only=>false},
          {:label=>"d6", :number=>4, :cause=>:roll, :has_children=>false, :die_sides=>6, :die_label=>"d6", :depth=>2, :first=>false, :last=>false, :index=>1, :only=>false},
          {:label=>"d6", :number=>2, :cause=>:roll, :has_children=>false, :die_sides=>6, :die_label=>"d6", :depth=>2, :first=>false, :last=>true, :index=>2, :only=>false},
          {:label=>"bonus", :number=>6, :cause=>:constant, :has_children=>false, :constant_value=>6, :constant_label=>"bonus", :depth=>1, :first=>false, :last=>true, :index=>1, :only=>false}
        ]
      end

    end

    describe "#template_hash_breadth_first" do
      it "should work with a simple structure" do
        ge_simple.template_hash_breadth_first.should match_explanation [
          { :label=>"1d20", :number=>12, :cause=>:roll, :depth=>0, :first=>true, :last=>true, :only=>true, :index=>0, :has_children => false, :die_sides => 20, :die_label => 'd20' }
        ]
      end

      it "should explain 3d6 -> 12" do
        ge_three.template_hash_breadth_first.should match_explanation [
          {:label=>"3d6", :number=>12, :cause=>:sum, :has_children=>true, :depth=>0, :first=>true, :last=>true, :only=>true, :index=>0},
          {:label=>"d6", :number=>3, :cause=>:roll, :has_children=>false, :die_sides=>6, :die_label=>"d6", :depth=>1, :first=>true, :last=>false, :index=>0, :only=>false},
          {:label=>"d6", :number=>4, :cause=>:roll, :has_children=>false, :die_sides=>6, :die_label=>"d6", :depth=>1, :first=>false, :last=>false, :index=>1, :only=>false},
          {:label=>"d6", :number=>5, :cause=>:roll, :has_children=>false, :die_sides=>6, :die_label=>"d6", :depth=>1, :first=>false, :last=>true, :index=>2, :only=>false}
        ]
      end

      it "should explain 3d6+6 -> 18" do
        ge_bunch_plus.template_hash_breadth_first.should match_explanation [
          {:label=>"3d6+6", :number=>18, :cause=>:sum, :has_children=>true, :depth=>0, :first=>true, :last=>true, :only=>true, :index=>0},
          {:label=>"3d6", :number=>12, :cause=>:sum, :has_children=>true, :depth=>1, :first=>true, :last=>false, :index=>0, :only=>false},
          {:label=>"bonus", :number=>6, :cause=>:constant, :has_children=>false, :constant_value=>6, :constant_label=>"bonus", :depth=>1, :first=>false, :last=>true, :index=>1, :only=>false},
          {:label=>"d6", :number=>6, :cause=>:roll, :has_children=>false, :die_sides=>6, :die_label=>"d6", :depth=>2, :first=>true, :last=>false, :index=>0, :only=>false},
          {:label=>"d6", :number=>4, :cause=>:roll, :has_children=>false, :die_sides=>6, :die_label=>"d6", :depth=>2, :first=>false, :last=>false, :index=>1, :only=>false},
          {:label=>"d6", :number=>2, :cause=>:roll, :has_children=>false, :die_sides=>6, :die_label=>"d6", :depth=>2, :first=>false, :last=>true, :index=>2, :only=>false},
        ]
      end

    end

    describe "#standard_text" do
      it "should explain 1d20 -> 12" do
        ge_simple.standard_text.should == "1d20: 12"
      end

      it "should explain 3d6 -> 12" do
        ge_three.standard_text.should == "3d6: 12. d6: 3 + 4 + 5"
      end

      it "should explain 3d6+6 -> 18" do
        ge_bunch_plus.standard_text.should == "3d6+6: 18. 3d6: 12 + bonus: 6. d6: 6 + 4 + 2"
      end
    end

  end # describe "instance method"

end # describe GamesDice::Explainer