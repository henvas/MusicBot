#!/usr/bin/env python3

import os
from pathlib import Path
import subprocess
import io


if __name__ == '__main__':
    script_path = Path(os.path.dirname(os.path.abspath(__file__)))
    run_command_script = Path('run_command.sh')
    docker_log_cmd = " | tee \$(pwd)/log/log_docker_\$(date +%Y-%m-%dT%H.%M.%SZ).txt"

    local_cmd = " --detached 'tmux new-session \"./run.py "
    local_cmd = local_cmd + docker_log_cmd + "\"'"
    cmd = (script_path / run_command_script).as_posix() + local_cmd
    subprocess.call(cmd, shell=True)
