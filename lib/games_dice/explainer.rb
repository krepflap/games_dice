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

  # @return [String] identifying label
  attr_reader :label

  # @return [Integer] numeric value that is being explained
  attr_reader :number

  # @return [Symbol] semantics of how the details are combined
  attr_reader :cause

  # @return [Symbol] an array, either of "deeper" explanations, or of Integers
  attr_reader :details

  # Counts maximum number of explanation layers "deeper" than this one. A value of 0 means that this
  # explanation has no deeper cause than the results of combining individual die rolls.
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
    Hash[ :label => label, :number => number, :cause => cause, :id => self.object_id ]
  end

  def build_depth_first
    visit_depth_first( self, 0 ) do | array, depth, item, stats |
      array << case item
      when Fixnum
        Hash[ :label => item.to_s, :number => item, :cause => :atom, :id => nil, :depth => depth ].merge(stats)
      when GamesDice::DieResult
        Hash[ :label => 'die', :number => item.value, :cause => :complex_die, :id => item.object_id, :depth => depth ].merge(stats)
      when GamesDice::Explainer
        h = item.as_hash
        h[:depth] = depth
        h.merge(stats)
      end
    end
  end

  private

  def visit_depth_first explain_object, current_depth, build_structure = [], stats = default_stats, &block
    yield( build_structure, current_depth, explain_object, stats )
    i = 0
    last_i = explain_object.details.count - 1
    explain_object.details.each do |detail|
      stats = Hash[ :first => ( i == 0 ), :last => ( i == last_i ), :index => i, :only => ( last_i == 0 ) ]
      i += 1
      if detail.is_a?( GamesDice::Explainer )
        visit_depth_first( detail, current_depth + 1, build_structure, stats, &block )
      else
        yield( build_structure, current_depth + 1, detail, stats )
      end
    end
    build_structure
  end

  def default_stats
    Hash[ :first => true, :last => true, :only => true, :index => 0 ]
  end

  def calc_content_depth
    @content_depth ||= recurse_max_depth( details, 0 )
  end

  def recurse_max_depth current_details, current_depth
    current_details.map do |detail|
      case detail
      when Fixnum then current_depth
      when GamesDice::DieResult then current_depth + ( detail.rolls.size > 1 ? 1 : 0 )
      when GamesDice::Explainer then recurse_max_depth( detail.details, current_depth + 1 )
      end
    end.flatten.minmax
  end
end # class GamesDice::Explainer
