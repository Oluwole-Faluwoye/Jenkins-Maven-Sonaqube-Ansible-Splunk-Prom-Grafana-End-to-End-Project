def gitRepo = "https://github.com/Oluwole-Faluwoye/realworld-cicd-pipeline-project.git"

try {
    def proc = ["git", "ls-remote", "--heads", gitRepo].execute()
    proc.waitFor()
    if (proc.exitValue() != 0) {
        return ["main"]
    }

    def branches = proc.in.text.readLines().collect { line ->
        line.split()[1].replace("refs/heads/", "")
    }

    return branches.sort()
} catch (err) {
    return ["main"]
}
