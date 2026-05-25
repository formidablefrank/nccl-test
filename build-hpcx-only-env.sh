#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
env_dir="${repo_root}/hpcx-only-external-env"

set +u
module load spack/0.22-06
set -u

spack -e "${env_dir}" concretize -f
spack -e "${env_dir}" install --fail-fast
