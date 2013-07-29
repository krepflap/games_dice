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
  def initialize label, number, cause, details
    @label = label.to_s
    @number = Integer(number)
    @cause = cause.to_sym
    @details = details
  end

  # @return [Integer] numeric value that is being explained
  attr_reader :number

  # @return [Symbol] semantics of how the details are combined
  attr_reader :cause

  # @return [Symbol] an array, either of "deeper" explanations, or of Integers
  attr_reader :details

  # Counts number of explanation layers "deeper" than this one. A value of 0 means that this
  # explanation has no deeper cause than the results of simple die rolls.
  # @return [Integer] degree of deeper explanations
  def content_depth
    @content_depth ||= calc_content_depth
  end

  private

  def calc_content_depth

  end

end # class GamesDice::Explainer
