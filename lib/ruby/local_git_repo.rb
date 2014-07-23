class LocalGitRepo

  def reset
    git_command('checkout master')
  end

  def checkout(ref)
    git_command("checkout #{ref}")
  end

  def num_commits_involving(path)
    git_command("log --pretty=%h #{path}").split("\n").length
  end

  def all_commits
    raw_log = git_command('log --pretty="%h/%aN/%ci/%s" --shortstat')
    lines = raw_log.split("\n")
    result = []
    (0..(lines.length-1)).each do |i|
      if lines[i].empty?
        fields = lines[i-1].split('/')
        count = lines[i+1].to_i
        result << {
          ref: fields[0],
          author: fields[1],
          date: fields[2],
          comment: fields[3..-1].join,
          num_files_touched: count
        }
      end
    end
    result.reverse
  end

  private

  def git_command(cmd)
    gitout = `git #{cmd} 2>&1`
    abort(gitout) if $? != 0
    gitout
  end

end