#!/usr/bin/env bash
# `bundle exec rspec spec` from root project dir to run test

set -o nounset
set -o errexit
set -o pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
decidim_repo_dir="../../decidim"
decidim_tag="v0.22.0"
decidim_tmp_branch="tmp-tests"
decidim_modules=(
  # "decidim-accountability"
  # "decidim-admin"
  # "decidim-api"
  # "decidim-assemblies"
  "decidim-blogs"
  # "decidim-budgets"
  "decidim-comments"
  # "decidim-conferences"
  # "decidim-consultations"
  # "decidim-core"
  # "decidim-debates"
  # "decidim-dev"
  # "decidim-elections"
  # "decidim-forms"
  # "decidim-generators"
  # "decidim-initiatives"
  # "decidim-meetings"
  "decidim-pages"
  # "decidim-participatory_processes"
  # "decidim-proposals"
  # "decidim-sortitions"
  # "decidim-surveys"
  # "decidim-system"
  # "decidim-verifications"
)

trap cleanup SIGINT SIGTERM ERR EXIT

_main() {
  # Get the latest changes from Decidim on a temporary branch.
  if [[ ! -d "$script_dir/$decidim_repo_dir" ]]; then
    echo "The Decidim repository doesn't exist at $script_dir/$decidim_repo_dir."
    exit 1
  fi
  pushd "$script_dir/$decidim_repo_dir" > /dev/null
  git fetch --all --prune
  git checkout -b "$decidim_tmp_branch"
  git reset --hard "$decidim_tag"
  decidim_rev=$(git rev-parse --short HEAD)
  popd > /dev/null
  git fetch --all --prune

  # Loop over `decidim_modules`. If we don't have a directory for them yet,
  # paste their content here. If we have one, merge the changes in the
  # directory.
  for module in "${decidim_modules[@]}"; do
    echo "Processing $module"
    if [[ -d "$script_dir/$module" ]]; then
      echo "-- found a directory, looking for new upstream commits"
      pushd "$script_dir/$decidim_repo_dir" > /dev/null

      previous_commit=false
      while IFS= read -r line; do
          previous_commit="$line"
      done < "$script_dir/$module/decidim_rev.txt"
      echo "-- last upstream commit was $previous_commit"

      new_commits=$(git log --pretty=format:"%h" --reverse "$previous_commit"..HEAD "$module/spec")
      if [ -z "$new_commits" ]; then
          echo "-- no new upstream commits found"
          continue
      fi
      while read -r new_commit; do
          echo "-- applying rev $new_commit"
          git show "$new_commit" "$module/spec" > "/tmp/$new_commit.patch"
          popd > /dev/null
          pushd "$script_dir/.." > /dev/null
          git apply --directory spec -3 "/tmp/$new_commit.patch"
          rm "/tmp/$new_commit.patch"
          echo "$new_commit" > "$script_dir/$module/decidim_rev.txt"
          git commit -am "spec: $module: applied rev $new_commit from upstream"
          popd > /dev/null
          pushd "$script_dir/$decidim_repo_dir" > /dev/null
      done <<< "$new_commits"
      popd > /dev/null
    else
      echo "-- did not found a directory, will copy the tests in it"
      mkdir -p "$script_dir/$module"
      echo "$decidim_rev" > "$script_dir/$module/decidim_rev.txt"
      cp -r "$script_dir/$decidim_repo_dir/$module/spec" "$script_dir/$module"
      mkdir -p "$script_dir/$module/lib/decidim/${module:8}"
      if [ -d "$script_dir/$decidim_repo_dir/$module/lib/decidim/${module:8}/test" ]; then
          cp -r "$script_dir/$decidim_repo_dir/$module/lib/decidim/${module:8}/test" "$script_dir/$module/lib/decidim/${module:8}"
      fi
    fi
  done
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  if [[ -d "$script_dir/$decidim_repo_dir" ]]; then
    pushd "$script_dir/$decidim_repo_dir" > /dev/null
    echo "Cleaning-up the temporary branch"
    git checkout develop
    git branch -D "$decidim_tmp_branch"
    popd > /dev/null
  fi
}

_main "$@"
cleanup "$@"
