def gitRepo = "https://github.com/Oluwole-Faluwoye/realworld-cicd-pipeline-project.git"
def defaultBranch = "main"

try {
    def proc = ["git", "ls-remote", "--heads", gitRepo].execute()
    proc.waitFor()
    
    if (proc.exitValue() != 0) {
        return [defaultBranch]
    }

    return proc.in.text.readLines()
                .collect { it.split()[1].replace("refs/heads/", "") }
                .sort()
} catch (err) {
    return [defaultBranch]
}
