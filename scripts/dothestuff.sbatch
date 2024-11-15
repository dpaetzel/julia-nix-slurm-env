#!/usr/bin/env bash
#SBATCH --partition=cpu-prio
#SBATCH --array=0-3
#SBATCH --output=output/%x-%A-%a.txt


echo "SLURM_ARRAY_JOB_ID=${SLURM_ARRAY_JOB_ID}"
echo "{SLURM_ARRAY_JOB_ID}_{SLURM_ARRAY_TASK_ID}=${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}"
echo "SLURM_JOB_ID=${SLURM_JOB_ID}"
echo hostname=$(hostname)


# Circumvent weird bug because of XDG_RUNTIME_DIR pointing to unwritable folder.
# Default mode of `srun` is to make all env vars available to the process so
# this is made available to `nix develop`.
export XDG_RUNTIME_DIR=~/XDG_RUNTIME_DIR
srun nix develop --impure --command bash -c "
    just dostuff ${SLURM_ARRAY_TASK_ID}
"
