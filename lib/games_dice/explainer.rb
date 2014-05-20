# This class models logical explanations for how a number or list of numbers is calculated from
# other numbers.
#
# An object of the class represents a single number, and a description of how it was calculated.
# The normal way to create an object of this class is to call #explanation_template on a dice
# object.
#
# @example Explanation for rolling 1 on 1d6, and the resulting template hash
#  ex = GamesDice::Explainer.new( '1d6', 1, GamesDice::ROLLED_VALUE_CAUSE, GamesDice::DieDescription.new( 6 ) )
#  ex.build_depth_first
#  # => { :label => "1d6", :number => 1, :cause => :roll, :depth => 0, :first => true, :last => true,
#  #      :only => true, :index => 0, :has_children => false, :die_sides => 6, :die_label => 'd6' }
#
# @example TDB 2
#  ex = GamesDice::Explainer.new( )
#
#

class GamesDice::Explainer
  # Tag class and instances as being of this type so they are allowed in the explainer heirarchy
  extend GamesDice::ExplainNodeType
  include GamesDice::ExplainNodeType

  # Creates new instance of GamesDice::Explainer.
  # @return [GamesDice::Explainer]
  def initialize label, number, cause, details
    @label = label.to_s
    @number = Integer(number)
    if ! cause.is_a?( GamesDice::ExplainerCause )
      raise TypeError, "Cause must be a GamesDice::ExplainerCause, but got #{cause.inspect}"
    end
    cause.check_details( details )
    @cause = cause
    @details = details
  end

  # @return [String] identifying label
  attr_reader :label

  # @return [Integer] numeric value that is being explained
  attr_reader :number

  # @return [GamesDice::ExplainerCause] semantics of how the value and details should be interpretted
  attr_reader :cause

  # @return [Array<GamesDice::Explainer>,GamesDice::DieDescription] "deeper" explanation of number
  attr_reader :details

  # Counts maximum number of explanation layers "deeper" than this one. A value of 0 means that this
  # explanation has no deeper cause.
  # @return [Integer] degree of deeper explanations
  def content_max_depth
    calc_content_depth
    @content_depth[1]
  end

  # Counts minimum number of explanation layers "deeper" than this one. A value of 0 means that this
  # explanation has at least one direct cause that needs no further explanation
  # @return [Integer] degree of deeper explanations
  def content_min_depth
    calc_content_depth
    @content_depth[0]
  end

  # @!visibility private
  # Represents the explanation without child data, as a hash. Used internally, but due to way self/other
  # split is done in Ruby, cannot make this a private method.
  # @return [Hash] description of this object
  def as_hash
    h = Hash[ :label => label, :number => number, :cause => cause, :id => self.object_id ]
    h.merge!( cause.to_h( details ) )
    h
  end

  # Creates an Array of Hashes suitable for use in template systems, based on explaining each
  # number in full detail, in turn.
  # @return [Array<Hash>] explanation template structure
  def build_depth_first
    visit_depth_first( self, 0 ) do | array, depth, item, stats |
      h = item.as_hash
      h[:depth] = depth
      h.merge!(stats)
      array << h
    end
  end

  # Creates an Array of Hashes suitable for use in template systems, based on explaining numbers
  # in groups at progressively higher levels of detail.
  # @return [Array<Hash>] explanation template structure
  def build_breadth_first
    visit_breadth_first( self, 0 ) do | array, depth, item, stats |
      h = item.as_hash
      h[:depth] = depth
      h.merge!(stats)
      array << h
    end
  end

  # Should use build_breadth_first to generate a template and then process it
  def standard_text
    items = build_breadth_first
    s = ''
    current_label = ''
    items.each do |i|
      if i[:first]
        if i[:depth] > 0
          s << ". "
        end
        current_label = i[:label]
        s << "#{i[:label]}: #{i[:number]}"
      else
        if current_label != i[:label]
          s << ", #{i[:label]}: #{i[:number]}"
          current_label = i[:label]
        else
          s << " + #{i[:number]}"
        end
      end
    end
    s
  end

  private

  def visit_depth_first explain_object, current_depth, build_structure = [], stats = default_stats, &block
    yield( build_structure, current_depth, explain_object, stats )
    return build_structure unless explain_object.cause.has_many_details
    return build_structure unless details = explain_object.details
    last_i = details.count - 1

    details.each_with_index do |detail,i|
      stats = counting_stats( i, last_i )
      if detail.is_a?( GamesDice::Explainer )
        visit_depth_first( detail, current_depth + 1, build_structure, stats, &block )
      else
        yield( build_structure, current_depth + 1, detail, stats )
      end
    end

    build_structure
  end

  def visit_breadth_first explain_object, current_depth, build_structure = [], stats = default_stats, &block
    yield( build_structure, current_depth, explain_object, stats ) unless current_depth > 0
    return build_structure unless explain_object.cause.has_many_details
    return build_structure unless details = explain_object.details

    last_i = details.count - 1

    details.each_with_index do |detail,i|
      stats = counting_stats( i, last_i )
      yield( build_structure, current_depth + 1, detail, stats )
    end

    details.each_with_index do |detail,i|
      stats = counting_stats( i, last_i )
      next unless detail.is_a?( GamesDice::Explainer )
      visit_breadth_first( detail, current_depth + 1, build_structure, stats, &block )
    end

    build_structure
  end

  def counting_stats i, last_i
    Hash[ :first => ( i == 0 ), :last => ( i == last_i ), :index => i, :only => ( last_i == 0 ) ]
  end

  def default_stats
    Hash[ :first => true, :last => true, :only => true, :index => 0 ]
  end

  def calc_content_depth
    @content_depth ||= recurse_max_depth( details, 0 )
  end

  def recurse_max_depth current_details, current_depth
    return current_depth unless current_details.is_a?( Array )

    current_details.map do |detail|
      case detail
      when Fixnum then current_depth
      when GamesDice::DieDescription then current_depth + ( detail.rolls.size > 1 ? 1 : 0 )
      when GamesDice::ExplainNodeType then
        recurse_max_depth( detail.details, current_depth + 1 )
      end
    end.flatten.minmax
  end
end # class GamesDice::Explainer
