require 'date'

class DeveloperBehaviourReport

  DELTA_CUTOFF_DAYS = 365

  def initialize(summaries)
    @summaries = summaries
  end

  def raw_data
    recent = @summaries.select {|summary| is_recent?(summary) }
    group_by_author(recent[1..-1])
  end

  private

  def cutoff_date
    @cutoff_date ||= DateTime.parse(@summaries[-1].date) - DELTA_CUTOFF_DAYS
  end

  def is_recent?(summary)
    DateTime.parse(summary.date) > cutoff_date
  end

  def group_by_author(summaries)
    summaries.group_by {|summary| summary.author }.map do |author, summaries|
      { author: author, commits: summaries.map {|s| s.raw_data } }
    end
  end

end
