#!/bin/bash
# some hackery to get R to load packrat.

# Bash3 Boilerplate. Copyright (c) 2014, kvz.io
set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"

# the Root project dir with Packrat is up one
# dir
rPackageDir=$(dirname $__dir)
cd $rPackageDir
Rscript bin/exampleAccuracyDensityPlot.R "$@"
cd -
