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
  # explanation has no deeper cause than the results of combining individual die rolls.
  # @return [Integer] degree of deeper explanations
  def content_depth
    @content_depth ||= calc_content_depth
  end

  # @return [Array<Hash>]
  # Types of explanation:
  # top_down vs bottom_up
  # depth_first vs breadth_first
  # flat vs layered
  # Each entry: an id, a parent id, a number, a label, how it contributes to an "upper" layer, how it derives from a "lower" layer

  private

  def calc_content_depth
    return recurse_max_depth( details, 0 )
  end

  def recurse_max_depth current_details, current_depth
    current_details.map do |detail|
      case detail
      when Fixnum then current_depth
      when GamesDice::DieResult then current_depth + ( detail.rolls.size > 1 ? 1 : 0 )
      when GamesDice::Explainer then recurse_max_depth( detail.details, current_depth + 1 )
      end
    end.max
  end
end # class GamesDice::Explainer
