# This class models descriptions of causes for numbers, such as whether a cause is the roll of a
# die, or a rule for combining several dice. It represents applies constraints to the explanation
# graph, so that code traversing an explanation tree can determine how to process each node.
#
# An object of the class represents a *type* of cause (which may be shared between many numbers),
# and represents what kind of detailed explanation should exist.
#
# @example When the explanation node contains an array of deeper explanations
#  cause = GamesDice::ExplainerCause.new( GamesDice::Explainer, true )
#
# @example When the explanation node is a single die roll
#  cause = GamesDice::ExplainerCause.new( GamesDice::DieDesription, false )
#

class GamesDice::ExplainerCause
  # Creates new instance of GamesDice::ExplainerCause.
  # @param [Class] details_class
  # @param [Boolean] has_many_details
  # @return [GamesDice::ExplainerCause]
  def initialize details_class, has_many_details
    raise TypeError, "Details class #{details_class} not allowed as explanation detail" \
      unless details_class.is_a?(GamesDice::ExplainNodeType) || details_class == GamesDice::ExplainNodeType
    @details_class = details_class
    @has_many_details = has_many_details ? true : false
  end

  # Which class is used for details of the cause (e.g. number of sides for a die)
  # @return [Class] Ruby class that should be used for explanation details
  attr_reader :details_class

  # Whether or not the details should be in an array
  # @return [Boolean] true if details should be an array
  attr_reader :has_many_details

  # Raises an error if input param cannot be used as details for this cause.
  # @param [Object] details cause details to check
  # @return [nil] nothing
  def check_details details
    if has_many_details
      if ! details.is_a?( Array )
        raise TypeError, "Details should be an Array, but got #{details.inspect}"
      end
      raise ArgumentError, "Details array is empty" if details.size ==  0
      if bad_detail = details.find { |d| ! d.is_a?( details_class ) }
        raise TypeError, "Details should be a #{details_class}, but got #{bad_detail.inspect}"
      end
    else
      if ! details.is_a?( details_class )
        raise TypeError, "Details should be a #{details_class}, but got #{details.inspect}"
      end
    end
    return
  end

  def to_h details
    hash = Hash[
      :cause => :roll, # TODO: Expand to full set of causes
    ]
  end

end # class GamesDice::ExplainerCause

module GamesDice::ExplainNodeType
end
