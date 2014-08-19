class CurrentHotspotsReport

  def initialize(repo, glob)
    @repo = repo
    @glob = glob
    @summarised = false
    @raw_data = nil
  end

  def raw_data
    if @summarised
      return @raw_data
    end
    file_reports = @repo.current_files(@glob).generate_reports
    @summarised = true
    @raw_data = remove_nils(file_reports)
  end

  private

  def remove_nils(file_reports)
    cleansed = []

    if not file_reports.empty?
      file_reports.each do |rpt|
        if not rpt.nil?
          cleansed.push(rpt)
        end
      end
    end

    cleansed
  end

end
