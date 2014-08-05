class CurrentHotspotsReport

  def initialize(repo, glob)
    @repo = repo
    @glob = glob
  end

  def raw_data
    @repo.current_files(@glob).map(&:complexity_report)
  end

end
