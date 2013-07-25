# This class models logical explanations for how a number or list of numbers is calculated from
# other numbers.
#
# An object of the class represents a single number, and a description of how it was calculated.
#
# @example TDB 1
#  ex = GamesDice::Explanation.new( )
#
# @example TDB 2
#  ex = GamesDice::Explanation.new( )
#
#

class GamesDice::Explainer

  # Creates new instance of GamesDice::Explainer.
  # @return [GamesDice::Explainer]
  def initialize number, cause, details
    @number = number
    @cause = cause
    @details = details
  end

  attr_reader :number

  attr_reader :cause

  attr_reader :details

end # class GamesDice::Explainer
