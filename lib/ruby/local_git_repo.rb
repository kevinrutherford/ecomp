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

  private

  def git_command(cmd)
    gitout = `git #{cmd} 2>&1`
    abort(gitout) if $? != 0
    gitout
  end

end