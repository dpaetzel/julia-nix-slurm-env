# NOTE All of this should probably rather go into devenv/flake.nix's scripts
# thingy.


# Start a Julia REPL for this project.
repl:
    @# Interestingly, I need to provide `--interactive` when I provide `-L startup.jl`
    julia --startup-file=no -L startup.jl --project=. --interactive


# Make sure this project's Julia environment is all set up.
setup:
    #!/usr/bin/env fish
    # Threadsafe(r than the default). This may be run more than once in parallel
    # by Slurm.
    set fpath_lock ~/JULIALOCK
    echo "Waiting for lock $fpath_lock …"
    while not mkdir $fpath_lock 2>/dev/null
        sleep 1
    end
    echo "Acquired lock $fpath_lock."
    and julia --project=. --eval "using Pkg; Pkg.instantiate()"
    echo "Relinquishing lock $fpath_lock …"
    rmdir ~/JULIALOCK
    echo "Relinquished lock $fpath_lock."


# Do your stuff, but first setup.
dostuff someparam: setup
    #!/usr/bin/env bash
    # Set to default value of 3 if not set (need at least 2 processes for
    # sampling and writing files).
    : ${SLURM_CPUS_PER_TASK:=2}
    procs=$((SLURM_CPUS_PER_TASK - 1))
    julia --procs=$procs --project=. \
        scripts/dothestuff.jl {{someparam}}
