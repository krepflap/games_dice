require 'helpers'

describe GamesDice::ExplainerCause do

  describe "class method" do
    describe "#new" do
      it "should instantiate if provided with valid parameters" do
        expect( GamesDice::ExplainerCause.new( GamesDice::DieDescription, false, :complex_die ) ).to be_a GamesDice::ExplainerCause
        expect( GamesDice::ExplainerCause.new( GamesDice::Explainer, true, :sum ) ).to be_a GamesDice::ExplainerCause
      end

      it "should not instantiate if provided with invalid parameters" do
        expect { GamesDice::ExplainerCause.new( :die_description, false, :foo ) }.to raise_error TypeError
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
        expect { cause_dd.check_details( valid_die_desc ) }.to_not raise_error
        expect { cause_explainlist.check_details( [valid_explanation] ) }.to_not raise_error
      end

      it "to raise errors when details are not valid" do
        expect { cause_explainlist.check_details( valid_die_desc ) }.to raise_error TypeError
        expect { cause_explainlist.check_details( 44 ) }.to raise_error TypeError
        expect { cause_explainlist.check_details( [] ) }.to raise_error ArgumentError
        expect { cause_explainlist.check_details( [valid_die_desc] ) }.to raise_error TypeError

        expect { cause_dd.check_details( 44 ) }.to raise_error TypeError
        expect { cause_dd.check_details( [] ) }.to raise_error TypeError
        expect { cause_dd.check_details( [valid_die_desc] ) }.to raise_error TypeError
        expect { cause_dd.check_details( valid_explanation ) }.to raise_error TypeError
      end
    end

    describe "#to_h" do
      it "should describe itself and supplied details as a Hash" do
        h = cause_dd.to_h( valid_die_desc )
        expect( h ).to be_a Hash
        expect( h ).to eql Hash[ :cause => :roll, :has_children => false, :die_sides => 6, :die_label => "d6" ]

        h = cause_explainlist.to_h( [ valid_explanation ] )
        expect( h ).to be_a Hash
        expect( h ).to eql Hash[ :cause=> :sum, :has_children => true ]# TODO: Not sure where child explanations will be covered
      end
    end

  end # describe "instance method"

end # describe GamesDice::ExplainerCause