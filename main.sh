deno_working_dir="$HOME/Desktop/cd_stack"
debug_flag="$2"

# eg: init_kv --debug
# $1: --debug
init_kv() {
  if [[ "$1" == "--debug" ]]
  then
    deno task --cwd="$deno_working_dir" init_kv
  else
    deno task --cwd="$deno_working_dir" init_kv > /dev/null 2>&1
  fi
  init_kv_code="$?"
  if [[ "$init_kv_code" != 0 ]]
  then
    echo 'ERROR: error running `deno task init_kv`, exiting early'
    return
  fi
}

# eg: init_stack path/to/dir --debug
# $1: pwd before navigating
# $2: --debug
init_stack() {
  if [[ "$2" == "--debug" ]]
  then
    deno task --cwd="$deno_working_dir" init_stack --before_nav_pwd="$1"
  else 
    deno task --cwd="$deno_working_dir" init_stack --before_nav_pwd="$1" > /dev/null 2>&1
  fi
  init_stack_code="$?"
  if [[ "$init_stack_code" != 0 ]]
  then
    echo 'ERROR: error running `deno task init_stack`, exiting early'
    return
  fi
}

case "$1" in 
  --forwards)
    init_kv "$debug_flag"
    init_stack "$(pwd)" "$debug_flag"

    # run deno command directly to avoid the output from `deno task` i.e. Task init_kv ...
    forwards_out=$(deno run --allow-env --allow-read --allow-sys --allow-run --unstable-kv "$deno_working_dir/scripts/forwards.ts")
    if [[ "$2" == "--debug" ]]; then echo "forwards_out: $forwards_out"; fi
    if [[ "$forwards_out" == "__err" ]]
    then
      echo "Can't move forwards!"
      return
    else
      cd "$forwards_out"
    fi
    ;;
  --backwards)
    before_nav_pwd=$(pwd)

    if cd ".."
      init_kv "$debug_flag"
      init_stack "$before_nav_pwd" "$debug_flag"
      if [[ "$debug_flag" == "--debug" ]]
      then
        deno task --cwd="$deno_working_dir" backwards --after_nav_pwd="$(pwd)"
      else 
        deno task --cwd="$deno_working_dir" backwards --after_nav_pwd="$(pwd)" > /dev/null 2>&1
      fi
    then
    fi
    ;;
  *)

    before_nav_pwd=$(pwd)
    if cd "$1"
    then 
      init_kv "$debug_flag"
      init_stack "$before_nav_pwd" "$debug_flag"

      after_nav_pwd=$(pwd)
      if [[ "$2" == "--debug" ]]
      then
        deno task --cwd="$deno_working_dir" push_stack --after_nav_pwd="$after_nav_pwd" "$1"
      else 
        deno task --cwd="$deno_working_dir" push_stack --after_nav_pwd="$after_nav_pwd" "$1" > /dev/null 2>&1
      fi
    fi
    ;;
esac