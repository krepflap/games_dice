# This class models logical explanations for how a number or list of numbers is calculated from
# other numbers.
#
# An object of the class represents a single number, and a description of how it was calculated.
# The normal way to access an object of this class is to call #result_explainer on a dice
# object.
#
# @example Explanation for rolling 1 on 1d6, and the resulting template hash
#  ex = GamesDice::Explainer.new( '1d6', 1, GamesDice::ROLLED_VALUE_CAUSE, GamesDice::DieDescription.new( 6 ) )
#  ex.template_hash_depth_first
#  # => { :label => "1d6", :number => 1, :cause => :roll, :depth => 0, :first => true, :last => true,
#  #      :only => true, :index => 0, :has_children => false, :die_sides => 6, :die_label => 'd6' }
#
#

class GamesDice::Explainer
  # Tag class and instances as being of this type so they are allowed in the explainer heirarchy
  extend GamesDice::ExplainNodeType
  include GamesDice::ExplainNodeType

  # Creates new instance of GamesDice::Explainer.
  # @param [String] label identifying label, used in template hash and text output
  # @param [Integer] number value that is being explained
  # @param [GamesDice::ExplainerCause] cause semantics of how the value and details should be interpretted
  # @param [Array<GamesDice::Explainer>,GamesDice::DieDescription] details "deeper" explanation of number
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

  # @return [String] identifying label, used in template hash and text output
  attr_reader :label

  # @return [Integer] numeric value that is being explained
  attr_reader :number

  # @return [GamesDice::ExplainerCause] semantics of how the value and details should be interpretted
  attr_reader :cause

  # @return [Array<GamesDice::Explainer>,GamesDice::DieDescription] "deeper" explanation of number
  attr_reader :details

  # Counts maximum number of explanation layers "deeper" than this one. A value of 0 means that this
  # explanation has no deeper cause (for instance it is a simple die roll or constant)
  # @return [Integer] degree of deeper explanations
  def content_max_depth
    calc_content_depth
    @content_depth[1]
  end

  # Counts minimum number of explanation layers "deeper" than this one. Results where some dice
  # have been rolled multiple times, but others only once will have different depths of explanation
  # and therefore different values for #content_max_depth and content_min_depth
  # @return [Integer] degree of deeper explanations
  def content_min_depth
    calc_content_depth
    @content_depth[0]
  end

  # @!visibility private
  # Represents the explanation without child data, as a hash. Used internally, but due to way
  # self/other split is done in Ruby, cannot make this a private method.
  # @return [Hash] description of this object
  def as_hash( prefix = nil )
    h = Hash[ :label => label, :number => number, :id => self.object_id ]
    h.merge!( cause.to_h( details ) )
    if prefix
      h = Hash[ h.map{ |k,v| [ (prefix + k.to_s).to_sym, v] } ]
    end
    h
  end

  # Creates an Array of Hashes suitable for use in template systems, based on explaining each
  # number in full detail, in turn.
  # @return [Array<Hash>] explanation template structure
  def template_hash_depth_first
    visit_depth_first( self, 0 ) do | array, depth, item, stats, parent_object, parent_stats |
      h = item.as_hash
      h[:depth] = depth
      if parent_object
        h.merge!( parent_object.as_hash( 'parent_' ))
        h.merge!( Hash[ parent_stats.map{ |k,v| [ ('parent_' + k.to_s).to_sym, v] } ])
      end
      h.merge!(stats)
      array << h
    end
  end

  # Creates an Array of Hashes suitable for use in template systems, based on explaining numbers
  # in groups at progressively higher levels of detail.
  # @return [Array<Hash>] explanation template structure
  def template_hash_breadth_first
    visit_breadth_first( self, 0 ) do | array, depth, item, stats, parent_object, parent_stats |
      h = item.as_hash
      h[:depth] = depth
      if parent_object
        h.merge!( parent_object.as_hash( 'parent_' ))
        h.merge!( Hash[ parent_stats.map{ |k,v| [ ('parent_' + k.to_s).to_sym, v] } ])
      end
      h.merge!(stats)
      array << h
    end
  end

  # Creates a text version of the explanation, suitable for debugging, logging or
  # feedback on how a result was obtained. Internally, it uses #template_hash_breadth_first
  # @return [String] explanation text
  def standard_text
    items = template_hash_breadth_first
    s = ''
    group_label = nil # This needs to find its way into the template hash data e.g. i[:group_end]
    items.each do |i|
      if i[:depth] == 0
        s << "#{i[:label]}: "
      elsif i[:first] && (! i[:only] ) && (! i[:parent_only] )
        s << ". #{i[:parent_label]}: #{i[:parent_number]}  =  "
      end

      if group_label && group_label != i[:label] && ! i[:first] && i[:label] != i[:parent_label]
        s << " (#{group_label})"
      end

      sign = i[:first] ? '' : ' + '
      if i[:number] < 0
        sign = i[:first] ? '-' : ' - '
      end
      s << sign
      s << "#{i[:number].abs}"

      if i[:last] && ! i[:only] && i[:label] != i[:parent_label]
        s << " (#{i[:label]})"
      end

      if i[:has_children] && i[:only]
        s << "  =  "
      elsif i[:has_children] && i[:last]
        s << ". "
      end

      group_label = i[:label]
    end
    s
  end

  private

  def visit_depth_first explain_object, current_depth, build_structure = [], stats = default_stats, parent_object=nil, parent_stats=nil, &block
    yield( build_structure, current_depth, explain_object, stats, parent_object, parent_stats )
    return build_structure unless explain_object.cause.has_many_details
    return build_structure unless details = explain_object.details
    last_i = details.count - 1
    parent_stats = stats

    details.each_with_index do |detail,i|
      stats = counting_stats( i, last_i )
      if detail.is_a?( GamesDice::Explainer )
        visit_depth_first( detail, current_depth + 1, build_structure, stats, explain_object, parent_stats, &block )
      else
        yield( build_structure, current_depth + 1, detail, stats, explain_object, parent_stats )
      end
    end

    build_structure
  end

  def visit_breadth_first explain_object, current_depth, build_structure = [], stats = default_stats, &block
    yield( build_structure, current_depth, explain_object, stats, nil, nil ) unless current_depth > 0
    return build_structure unless explain_object.cause.has_many_details
    return build_structure unless details = explain_object.details

    last_i = details.count - 1
    parent_stats = stats

    details.each_with_index do |detail,i|
      stats = counting_stats( i, last_i )
      yield( build_structure, current_depth + 1, detail, stats, explain_object, parent_stats )
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

    # TODO: Revise this, it should inspect *cause* at each level, not details
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
