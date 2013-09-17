# This class models the descriptive labelling of a die.
#
# An object of the class represents the description of a single die, separate from the
# implementation. Descriptions can be generated automatically, or provided when a die is
# created.
#

class GamesDice::DieDescription

  # Creates new instance of GamesDice::DieResult. The object can be initialised "empty" or with a first result.
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
end
