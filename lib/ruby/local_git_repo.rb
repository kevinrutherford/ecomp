class LocalGitRepo

  def reset
    `git checkout master`
  end

  def checkout(ref)
    gitout = `git checkout #{ref} 2>&1`
    abort(gitout) if $? != 0
  end
end