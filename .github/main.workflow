workflow "New workflow" {
  on = "push"
  resolves = ["Deploy"]
}

action "Deploy" {
  uses = "maxheld83/ghpages@v0.2.0"
  env = {
    BUILD_DIR = "public/"
  }
  needs = ["CNAME"]
  secrets = ["GH_PAT"]
}

action "Build" {
  uses = "actions/bin/sh@master"
  args = ["binaries/hugo --forceSyncStatic -b //blog.lineufelipe.com/"]
  needs = ["git submodules"]
}

action "Filter Master" {
  uses = "actions/bin/filter@b2bea0749eed6beb495a8fa194c071847af60ea1"
  args = "branch master"
}

action "CNAME" {
  uses = "actions/bin/sh@master"
  needs = ["Build"]
  args = ["cp CNAME public/CNAME"]
}

action "git submodules" {
  uses = "srt32/git-actions@v0.0.3"
  needs = ["Filter Master"]
  args = "git submodule update --init"
}
