require 'helpers'

describe GamesDice::DieDescription do

  describe ".new" do

    it "should accept a single parameter: sides" do
      dd = GamesDice::DieDescription.new( 6 )
      dd.should be_a GamesDice::DieDescription
      dd.sides.should == 6
      dd.label.should == 'd6'
    end

    it "should accept two params: sides, label" do
      dd = GamesDice::DieDescription.new( 8, 'brutal-d8' )
      dd.should be_a GamesDice::DieDescription
      dd.sides.should == 8
      dd.label.should == 'brutal-d8'
    end

  end

end
