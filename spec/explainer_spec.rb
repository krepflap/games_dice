require 'helpers'

describe GamesDice::Explainer do
  let( :d6d ) { GamesDice::DieDescription.new( 6 ) }
  let( :d8d ) { GamesDice::DieDescription.new( 8 ) }
  let( :d20d ) { GamesDice::DieDescription.new( 20 ) }
  let( :plus_6 ) { GamesDice::ConstantDescription.new( 6, 'bonus' ) }
  let( :plus_5 ) { GamesDice::ConstantDescription.new( 5, 'bonus' ) }
  let( :rolled_1 ) { GamesDice::Explainer.new( 'd6', 1, GamesDice::ROLLED_VALUE_CAUSE, d6d ) }
  let( :rolled_2 ) { GamesDice::Explainer.new( 'd6', 2, GamesDice::ROLLED_VALUE_CAUSE, d6d ) }
  let( :rolled_3 ) { GamesDice::Explainer.new( 'd6', 3, GamesDice::ROLLED_VALUE_CAUSE, d6d ) }
  let( :rolled_4 ) { GamesDice::Explainer.new( 'd6', 4, GamesDice::ROLLED_VALUE_CAUSE, d6d ) }
  let( :rolled_5 ) { GamesDice::Explainer.new( 'd6', 5, GamesDice::ROLLED_VALUE_CAUSE, d6d ) }
  let( :rolled_6 ) { GamesDice::Explainer.new( 'd6', 6, GamesDice::ROLLED_VALUE_CAUSE, d6d ) }
  let( :d8_rolled_1 ) { GamesDice::Explainer.new( 'd8', 1, GamesDice::ROLLED_VALUE_CAUSE, d8d ) }
  let( :d8_rolled_2 ) { GamesDice::Explainer.new( 'd8', 2, GamesDice::ROLLED_VALUE_CAUSE, d8d ) }
  let( :d8_rolled_3 ) { GamesDice::Explainer.new( 'd8', 3, GamesDice::ROLLED_VALUE_CAUSE, d8d ) }
  let( :d8_rolled_4 ) { GamesDice::Explainer.new( 'd8', 4, GamesDice::ROLLED_VALUE_CAUSE, d8d ) }
  let( :d8_rolled_5 ) { GamesDice::Explainer.new( 'd8', 5, GamesDice::ROLLED_VALUE_CAUSE, d8d ) }
  let( :d8_rolled_6 ) { GamesDice::Explainer.new( 'd8', 6, GamesDice::ROLLED_VALUE_CAUSE, d8d ) }
  let( :d8_rolled_7 ) { GamesDice::Explainer.new( 'd8', 7, GamesDice::ROLLED_VALUE_CAUSE, d8d ) }
  let( :d8_rolled_8 ) { GamesDice::Explainer.new( 'd8', 8, GamesDice::ROLLED_VALUE_CAUSE, d8d ) }


  describe "class method" do
    describe "#new" do
      it "should instantiate if provided with valid parameters" do
        valid_params = [
          ['d20', 12, GamesDice::ROLLED_VALUE_CAUSE, d20d],
          ['2d6', 12, GamesDice::SUM_OF_CAUSE, [ rolled_6, rolled_6 ]],
        ]
        valid_params.each do |p|
          expect( GamesDice::Explainer.new( *p ) ).to be_a GamesDice::Explainer
        end
      end

      it "should not instantiate if provided with bad parameters" do
        bad_params = [
          ['2d6', 12, GamesDice::SUM_OF_CAUSE, []], # Sum with no explanation
        ]
        bad_params.each do |p|
          expect { GamesDice::Explainer.new( *p ) }.to raise_error
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
    let( :ge_attack ) { GamesDice::Explainer.new( 'Attack', 17, GamesDice::SUM_OF_CAUSE,
      [ GamesDice::Explainer.new( '1d20', 12, GamesDice::ROLLED_VALUE_CAUSE, d20d ),
        GamesDice::Explainer.new( 'modifier', 5, GamesDice::CONSTANT_VALUE_CAUSE, plus_5 ) ] ) }
    let( :ge_2d8_add_2d6 ) { GamesDice::Explainer.new( '2d8+2d6', 19, GamesDice::SUM_OF_CAUSE,
      [ GamesDice::Explainer.new( '2d8', 10, GamesDice::SUM_OF_CAUSE, [ d8_rolled_6, d8_rolled_4 ] ),
        GamesDice::Explainer.new( '2d6', 9, GamesDice::SUM_OF_CAUSE, [ rolled_3, rolled_6 ] ) ] ) }


    describe "#content_max_depth" do
      it "should return 0 for a simple explanation" do
        expect( ge_simple.content_max_depth ).to eql 0
      end

      it "should return corrrect numbers for more complex explanations" do
        expect( ge_three.content_max_depth ).to eql 1
        expect( ge_bunch_plus.content_max_depth ).to eql 2
      end
    end

    describe "#content_min_depth" do
      it "should return 0 for a simple explanation" do
        expect( ge_simple.content_min_depth ).to eql 0
      end

      it "should return correct numbers for more complex explanations" do
        expect( ge_three.content_min_depth ).to eql 1
        expect( ge_bunch_plus.content_min_depth ).to eql 1
      end
    end

    describe "#template_hash_depth_first" do
      it "should work with a simple structure" do
        expect( ge_simple.template_hash_depth_first ).to match_explanation [
          { :label=>"1d20", :number=>12, :cause=>:roll, :depth=>0, :first=>true, :last=>true,
            :only=>true, :index=>0, :has_children => false, :die_sides => 20, :die_label => 'd20'}
        ]
      end

      it "should explain 3d6 -> 12" do
        expect( ge_three.template_hash_depth_first ).to match_explanation [
          { :label=>"3d6", :number=>12, :cause=>:sum, :has_children=>true, :depth=>0,
             :first=>true, :last=>true, :only=>true, :index=>0},
          { :label=>"d6", :number=>3, :cause=>:roll, :has_children=>false, :die_sides=>6,
            :die_label=>"d6", :depth=>1, :first=>true, :last=>false, :index=>0, :only=>false,
            :parent_label => '3d6', :parent_number => 12, :parent_cause => :sum,
            :parent_first=>true, :parent_last=>true, :parent_only=>true, :parent_index=>0 },
          { :label=>"d6", :number=>4, :cause=>:roll, :has_children=>false, :die_sides=>6,
            :die_label=>"d6", :depth=>1, :first=>false, :last=>false, :index=>1, :only=>false,
            :parent_label => '3d6', :parent_number => 12, :parent_cause => :sum,
            :parent_first=>true, :parent_last=>true, :parent_only=>true, :parent_index=>0 },
          { :label=>"d6", :number=>5, :cause=>:roll, :has_children=>false, :die_sides=>6,
            :die_label=>"d6", :depth=>1, :first=>false, :last=>true, :index=>2, :only=>false,
            :parent_label => '3d6', :parent_number => 12, :parent_cause => :sum,
            :parent_first=>true, :parent_last=>true, :parent_only=>true, :parent_index=>0 }
        ]
      end

      it "should explain 3d6+6 -> 18" do
        expect( ge_bunch_plus.template_hash_depth_first ).to match_explanation [
          {:label=>"3d6+6", :number=>18, :cause=>:sum, :has_children=>true, :depth=>0,
            :first=>true, :last=>true, :only=>true, :index=>0},
          {:label=>"3d6", :number=>12, :cause=>:sum, :has_children=>true, :depth=>1,
            :first=>true, :last=>false, :index=>0, :only=>false,
            :parent_label => '3d6+6', :parent_number => 18, :parent_cause => :sum,
            :parent_first=>true, :parent_last=>true, :parent_only=>true, :parent_index=>0 },
          {:label=>"d6", :number=>6, :cause=>:roll, :has_children=>false, :die_sides=>6,
            :die_label=>"d6", :depth=>2, :first=>true, :last=>false, :index=>0, :only=>false,
            :parent_label => '3d6', :parent_number => 12, :parent_cause => :sum,
            :parent_first=>true, :parent_last=>false, :parent_only=>false, :parent_index=>0 },
          {:label=>"d6", :number=>4, :cause=>:roll, :has_children=>false, :die_sides=>6,
            :die_label=>"d6", :depth=>2, :first=>false, :last=>false, :index=>1, :only=>false,
            :parent_label => '3d6', :parent_number => 12, :parent_cause => :sum,
            :parent_first=>true, :parent_last=>false, :parent_only=>false, :parent_index=>0 },
          {:label=>"d6", :number=>2, :cause=>:roll, :has_children=>false, :die_sides=>6,
            :die_label=>"d6", :depth=>2, :first=>false, :last=>true, :index=>2, :only=>false,
            :parent_label => '3d6', :parent_number => 12, :parent_cause => :sum,
            :parent_first=>true, :parent_last=>false, :parent_only=>false, :parent_index=>0 },
          {:label=>"bonus", :number=>6, :cause=>:constant, :has_children=>false, :constant_value=>6,
            :constant_label=>"bonus", :depth=>1, :first=>false, :last=>true, :index=>1, :only=>false,
            :parent_label => '3d6+6', :parent_number => 18, :parent_cause => :sum,
            :parent_first=>true, :parent_last=>true, :parent_only=>true, :parent_index=>0 }
        ]
      end

      it "should explain 'attack', 1d20+5 -> 17" do
        expect( ge_attack.template_hash_depth_first ).to match_explanation [
          { :label=>"Attack", :number=>17, :cause=>:sum, :has_children=>true, :depth=>0,
             :first=>true, :last=>true, :only=>true, :index=>0},
          { :label=>"1d20", :number=>12, :cause=>:roll, :has_children=>false, :die_sides=>20,
            :die_label=>"d20", :depth=>1, :first=>true, :last=>false, :index=>0, :only=>false,
            :parent_label => "Attack", :parent_number => 17, :parent_cause => :sum,
            :parent_first=>true, :parent_last=>true, :parent_only=>true, :parent_index=>0 },
          {:label=>"modifier", :number=>5, :cause=>:constant, :has_children=>false, :constant_value=>5,
            :constant_label=>"bonus", :depth=>1, :first=>false, :last=>true, :index=>1, :only=>false,
            :parent_label => 'Attack', :parent_number => 17, :parent_cause => :sum,
            :parent_first=>true, :parent_last=>true, :parent_only=>true, :parent_index=>0 }
        ]
      end

      it "should explain 2d8+2d6 -> 19" do
        expect( ge_2d8_add_2d6.template_hash_depth_first ).to match_explanation [
          {:label=>"2d8+2d6", :number=>19, :cause=>:sum, :has_children=>true,
          :depth=>0, :first=>true, :last=>true, :only=>true, :index=>0},

          {:label=>"2d8", :number=>10, :cause=>:sum, :has_children=>true, :depth=>1,
          :parent_label=>"2d8+2d6", :parent_number=>19, :parent_cause=>:sum,
          :parent_has_children=>true, :parent_first=>true, :parent_last=>true, :parent_only=>true,
          :parent_index=>0, :first=>true, :last=>false, :index=>0, :only=>false},
            {:label=>"d8", :number=>6, :cause=>:roll, :has_children=>false, :die_sides=>8, :die_label=>"d8",
            :depth=>2, :parent_label=>"2d8", :parent_number=>10, :parent_cause=>:sum,
            :parent_has_children=>true, :parent_first=>true, :parent_last=>false, :parent_index=>0,
            :parent_only=>false, :first=>true, :last=>false, :index=>0, :only=>false},
            {:label=>"d8",:number=>4, :cause=>:roll, :has_children=>false, :die_sides=>8, :die_label=>"d8",
            :depth=>2, :parent_label=>"2d8", :parent_number=>10, :parent_cause=>:sum,
            :parent_has_children=>true, :parent_first=>true, :parent_last=>false, :parent_index=>0,
            :parent_only=>false, :first=>false, :last=>true, :index=>1, :only=>false},

          {:label=>"2d6", :number=>9, :cause=>:sum, :has_children=>true, :depth=>1, :parent_label=>"2d8+2d6",
          :parent_number=>19, :parent_cause=>:sum, :parent_has_children=>true, :parent_first=>true,
          :parent_last=>true, :parent_only=>true, :parent_index=>0, :first=>false, :last=>true,
          :index=>1, :only=>false},
            {:label=>"d6", :number=>3, :cause=>:roll, :has_children=>false,
            :die_sides=>6, :die_label=>"d6", :depth=>2, :parent_label=>"2d6", :parent_number=>9,
            :parent_cause=>:sum, :parent_has_children=>true, :parent_first=>false, :parent_last=>true,
            :parent_index=>1, :parent_only=>false, :first=>true, :last=>false, :index=>0,
            :only=>false},
            {:label=>"d6", :number=>6, :cause=>:roll, :has_children=>false,
            :die_sides=>6, :die_label=>"d6", :depth=>2, :parent_label=>"2d6", :parent_number=>9,
            :parent_cause=>:sum, :parent_has_children=>true, :parent_first=>false, :parent_last=>true,
            :parent_index=>1, :parent_only=>false, :first=>false, :last=>true, :index=>1,
            :only=>false}
        ]
      end



    end

    describe "#template_hash_breadth_first" do
      it "should work with a simple structure" do
        expect( ge_simple.template_hash_breadth_first ).to match_explanation [
          { :label=>"1d20", :number=>12, :cause=>:roll, :depth=>0, :first=>true, :last=>true,
            :only=>true, :index=>0, :has_children => false, :die_sides => 20, :die_label => 'd20' }
        ]
      end

      it "should explain 3d6 -> 12" do
        expect( ge_three.template_hash_breadth_first ).to match_explanation [
          {:label=>"3d6", :number=>12, :cause=>:sum, :has_children=>true, :depth=>0, :first=>true,
           :last=>true, :only=>true, :index=>0 },
          {:label=>"d6", :number=>3, :cause=>:roll, :has_children=>false, :die_sides=>6,
            :die_label=>"d6", :depth=>1, :first=>true, :last=>false, :index=>0, :only=>false,
            :parent_label => '3d6', :parent_number => 12, :parent_cause => :sum,
            :parent_first=>true, :parent_last=>true, :parent_only=>true, :parent_index=>0 },
          {:label=>"d6", :number=>4, :cause=>:roll, :has_children=>false, :die_sides=>6,
            :die_label=>"d6", :depth=>1, :first=>false, :last=>false, :index=>1, :only=>false,
            :parent_label => '3d6', :parent_number => 12, :parent_cause => :sum,
            :parent_first=>true, :parent_last=>true, :parent_only=>true, :parent_index=>0 },
          {:label=>"d6", :number=>5, :cause=>:roll, :has_children=>false, :die_sides=>6,
            :die_label=>"d6", :depth=>1, :first=>false, :last=>true, :index=>2, :only=>false,
            :parent_label => '3d6', :parent_number => 12, :parent_cause => :sum,
            :parent_first=>true, :parent_last=>true, :parent_only=>true, :parent_index=>0 }
        ]
      end

      it "should explain 3d6+6 -> 18" do
        expect( ge_bunch_plus.template_hash_breadth_first ).to match_explanation [
          {:label=>"3d6+6", :number=>18, :cause=>:sum, :has_children=>true, :depth=>0,
            :first=>true, :last=>true, :only=>true, :index=>0 },
          {:label=>"3d6", :number=>12, :cause=>:sum, :has_children=>true, :depth=>1,
            :first=>true, :last=>false, :index=>0, :only=>false,
            :parent_label => '3d6+6', :parent_number => 18, :parent_cause => :sum,
            :parent_first=>true, :parent_last=>true, :parent_only=>true, :parent_index=>0 },
          {:label=>"bonus", :number=>6, :cause=>:constant, :has_children=>false,
            :constant_value=>6, :constant_label=>"bonus", :depth=>1, :first=>false,
            :last=>true, :index=>1, :only=>false, :parent_label => '3d6+6', :parent_number => 18, :parent_cause => :sum,
            :parent_first=>true, :parent_last=>true, :parent_only=>true, :parent_index=>0 },
          {:label=>"d6", :number=>6, :cause=>:roll, :has_children=>false, :die_sides=>6,
            :die_label=>"d6", :depth=>2, :first=>true, :last=>false, :index=>0, :only=>false,
            :parent_label => '3d6', :parent_number => 12, :parent_cause => :sum,
            :parent_first=>true, :parent_last=>false, :parent_only=>false, :parent_index=>0 },
          {:label=>"d6", :number=>4, :cause=>:roll, :has_children=>false, :die_sides=>6,
            :die_label=>"d6", :depth=>2, :first=>false, :last=>false, :index=>1, :only=>false,
            :parent_label => '3d6', :parent_number => 12, :parent_cause => :sum,
            :parent_first=>true, :parent_last=>false, :parent_only=>false, :parent_index=>0 },
          {:label=>"d6", :number=>2, :cause=>:roll, :has_children=>false, :die_sides=>6,
            :die_label=>"d6", :depth=>2, :first=>false, :last=>true, :index=>2, :only=>false,
            :parent_label => '3d6', :parent_number => 12, :parent_cause => :sum,
            :parent_first=>true, :parent_last=>false, :parent_only=>false, :parent_index=>0 }
        ]
      end

      it "should explain 'attack', 1d20+5 -> 17" do
        expect( ge_attack.template_hash_breadth_first ).to match_explanation [
          { :label=>"Attack", :number=>17, :cause=>:sum, :has_children=>true, :depth=>0,
             :first=>true, :last=>true, :only=>true, :index=>0},
          { :label=>"1d20", :number=>12, :cause=>:roll, :has_children=>false, :die_sides=>20,
            :die_label=>"d20", :depth=>1, :first=>true, :last=>false, :index=>0, :only=>false,
            :parent_label => "Attack", :parent_number => 17, :parent_cause => :sum,
            :parent_first=>true, :parent_last=>true, :parent_only=>true, :parent_index=>0 },
          {:label=>"modifier", :number=>5, :cause=>:constant, :has_children=>false, :constant_value=>5,
            :constant_label=>"bonus", :depth=>1, :first=>false, :last=>true, :index=>1, :only=>false,
            :parent_label => 'Attack', :parent_number => 17, :parent_cause => :sum,
            :parent_first=>true, :parent_last=>true, :parent_only=>true, :parent_index=>0 }
        ]
      end

      it "should explain 2d8+2d6 -> 19" do
        expect( ge_2d8_add_2d6.template_hash_breadth_first ).to match_explanation [
          {:label=>"2d8+2d6", :number=>19, :cause=>:sum, :has_children=>true,
          :depth=>0, :first=>true, :last=>true, :only=>true, :index=>0},

          {:label=>"2d8", :number=>10, :cause=>:sum, :has_children=>true, :depth=>1,
          :parent_label=>"2d8+2d6", :parent_number=>19, :parent_cause=>:sum,
          :parent_has_children=>true, :parent_first=>true, :parent_last=>true, :parent_only=>true,
          :parent_index=>0, :first=>true, :last=>false, :index=>0, :only=>false},
          {:label=>"2d6", :number=>9, :cause=>:sum, :has_children=>true, :depth=>1, :parent_label=>"2d8+2d6",
          :parent_number=>19, :parent_cause=>:sum, :parent_has_children=>true, :parent_first=>true,
          :parent_last=>true, :parent_only=>true, :parent_index=>0, :first=>false, :last=>true,
          :index=>1, :only=>false},

            {:label=>"d8", :number=>6, :cause=>:roll, :has_children=>false, :die_sides=>8, :die_label=>"d8",
            :depth=>2, :parent_label=>"2d8", :parent_number=>10, :parent_cause=>:sum,
            :parent_has_children=>true, :parent_first=>true, :parent_last=>false, :parent_index=>0,
            :parent_only=>false, :first=>true, :last=>false, :index=>0, :only=>false},
            {:label=>"d8",:number=>4, :cause=>:roll, :has_children=>false, :die_sides=>8, :die_label=>"d8",
            :depth=>2, :parent_label=>"2d8", :parent_number=>10, :parent_cause=>:sum,
            :parent_has_children=>true, :parent_first=>true, :parent_last=>false, :parent_index=>0,
            :parent_only=>false, :first=>false, :last=>true, :index=>1, :only=>false},
            {:label=>"d6", :number=>3, :cause=>:roll, :has_children=>false,
            :die_sides=>6, :die_label=>"d6", :depth=>2, :parent_label=>"2d6", :parent_number=>9,
            :parent_cause=>:sum, :parent_has_children=>true, :parent_first=>false, :parent_last=>true,
            :parent_index=>1, :parent_only=>false, :first=>true, :last=>false, :index=>0,
            :only=>false},
            {:label=>"d6", :number=>6, :cause=>:roll, :has_children=>false,
            :die_sides=>6, :die_label=>"d6", :depth=>2, :parent_label=>"2d6", :parent_number=>9,
            :parent_cause=>:sum, :parent_has_children=>true, :parent_first=>false, :parent_last=>true,
            :parent_index=>1, :parent_only=>false, :first=>false, :last=>true, :index=>1,
            :only=>false}
        ]
      end

    end

    describe "#standard_text" do
      it "should explain 1d20 -> 12" do
        expect( ge_simple.standard_text ).to eql "1d20: 12"
      end

      it "should explain 3d6 -> 12" do
        expect( ge_three.standard_text ).to eql "3d6: 12  =  3 + 4 + 5 (d6)"
      end

      it "should explain 3d6+6 -> 18" do
        expect( ge_bunch_plus.standard_text ).to eql "3d6+6: 18  =  12 (3d6) + 6 (bonus). 3d6: 12  =  6 + 4 + 2 (d6)"
      end

      it "should explain 'attack', 1d20+5 -> 17" do
        expect( ge_attack.standard_text ).to eql "Attack: 17  =  12 (1d20) + 5 (modifier)"
      end

      it "should explain 2d8+2d6 -> 19" do
        expect( ge_2d8_add_2d6.standard_text ).to eql "2d8+2d6: 19  =  10 (2d8) + 9 (2d6). 2d8: 10  =  6 + 4 (d8). 2d6: 9  =  3 + 6 (d6)"
      end
    end

  end # describe "instance method"

end # describe GamesDice::Explainer