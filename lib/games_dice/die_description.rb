# This class models the descriptive labelling of a die.
#
# An object of the class represents the description of a single die, separate from the
# implementation. Descriptions can be generated automatically, or provided when a die is
# created.
#

class GamesDice::DieDescription
  # Tag class and instances as being of this type so they are allowed in the explainer heirarchy
  extend GamesDice::ExplainNodeType
  include GamesDice::ExplainNodeType

  # Creates new instance of GamesDice::DieDescription.
  # @param [Integer] sides Number of sides
  # @param [String] label Text label to use for this die
  # @return [GamesDice::DieDescription]
  def initialize( sides, label = 'd' + sides.to_s )
    @sides = Integer(sides)
    @label = label.to_s
  end

  # The number of sides on the die. This is separate from the values shown on the die.
  # @return [Integer]
  attr_reader :sides

  # A short descriptive name for the die.
  # @return [String]
  attr_reader :label

  # Hash representation for templated output via GamesDice::Explainer
  # @return [Hash]
  def to_h
    Hash[ :die_sides => sides, :die_label => label ]
  end
end


class GamesDice::ConstantDescription
  # Tag class and instances as being of this type so they are allowed in the explainer heirarchy
  extend GamesDice::ExplainNodeType
  include GamesDice::ExplainNodeType

  # Creates new instance of GamesDice::ConstantDescription.
  # @param [Integer] value Numerical value used in dice calculations
  # @param [String] label Text label to use for this constant
  # @return [GamesDice::ConstantDescription]
  def initialize( value, label = 'constant' )
    @value = Integer(value)
    @label = label.to_s
  end

  # Numerical value used in dice calculations.
  # @return [Integer]
  attr_reader :value

  # A short descriptive name for the constant.
  # @return [String]
  attr_reader :label

  # Hash representation for templated output via GamesDice::Explainer
  # @return [Hash]
  def to_h
    Hash[ :constant_value => self.value, :constant_label => label ]
  end
end
