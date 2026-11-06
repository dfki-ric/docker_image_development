#!/bin/bash

# translates docker run arguments (ADDITIONAL_DOCKER_RUN_ARGS) into the "workspace" service of a compose file

# quotes a string for yaml, $ is escaped to keep docker compose from interpolating it
yaml_quote(){
    local VALUE=${1//\\/\\\\}
    VALUE=${VALUE//\"/\\\"}
    VALUE=${VALUE//\$/\$\$}
    printf '"%s"' "$VALUE"
}

# usage: run_args_to_compose_yaml "<docker run args>"
# sets RUN_ARGS_COMPOSE_YAML (empty if no args given) and RUN_ARGS_NAMED_VOLUMES (named volumes used via -v)
# returns 1 and prints the arguments that cannot be translated
run_args_to_compose_yaml(){
    local -a ARGS
    read -ra ARGS <<< "$1"
    local -A VALUES=()
    local -a KEYS=()
    local -a UNSUPPORTED=()
    local i=0 ARG OPT VALUE HAS_VALUE KEY TYPE ULIMIT_NAME ULIMIT
    RUN_ARGS_COMPOSE_YAML=""
    RUN_ARGS_NAMED_VOLUMES=()

    while [ $i -lt ${#ARGS[@]} ]; do
        ARG=${ARGS[$i]}
        i=$((i+1))
        # --option=value or -o=value
        if [[ "$ARG" =~ ^(--[^=]+|-[a-zA-Z])=(.*)$ ]]; then
            OPT=${BASH_REMATCH[1]}
            VALUE=${BASH_REMATCH[2]}
            HAS_VALUE=true
        else
            OPT=$ARG
            VALUE=""
            HAS_VALUE=false
        fi

        case "$OPT" in
            # flags (optional =true/=false)
            --privileged)               KEY=privileged;          TYPE=flag;;
            --init)                     KEY=init;                TYPE=flag;;
            --read-only)                KEY=read_only;           TYPE=flag;;
            # single values
            --net|--network)            KEY=network_mode;        TYPE=value;;
            --ipc)                      KEY=ipc;                 TYPE=value;;
            --pid)                      KEY=pid;                 TYPE=value;;
            --uts)                      KEY=uts;                 TYPE=value;;
            --shm-size)                 KEY=shm_size;            TYPE=value;;
            -h|--hostname)              KEY=hostname;            TYPE=value;;
            --runtime)                  KEY=runtime;             TYPE=value;;
            -w|--workdir)               KEY=working_dir;         TYPE=value;;
            --restart)                  KEY=restart;             TYPE=value;;
            -m|--memory)                KEY=mem_limit;           TYPE=value;;
            --cpus)                     KEY=cpus;                TYPE=value;;
            --platform)                 KEY=platform;            TYPE=value;;
            --stop-signal)              KEY=stop_signal;         TYPE=value;;
            # lists
            -p|--publish)               KEY=ports;               TYPE=list;;
            -v|--volume)                KEY=volumes;             TYPE=list;;
            -e|--env)                   KEY=environment;         TYPE=list;;
            --env-file)                 KEY=env_file;            TYPE=list;;
            --dns)                      KEY=dns;                 TYPE=list;;
            --dns-search)               KEY=dns_search;          TYPE=list;;
            --dns-opt|--dns-option)     KEY=dns_opt;             TYPE=list;;
            --add-host)                 KEY=extra_hosts;         TYPE=list;;
            --device)                   KEY=devices;             TYPE=list;;
            --device-cgroup-rule)       KEY=device_cgroup_rules; TYPE=list;;
            --cap-add)                  KEY=cap_add;             TYPE=list;;
            --cap-drop)                 KEY=cap_drop;            TYPE=list;;
            --security-opt)             KEY=security_opt;        TYPE=list;;
            --group-add)                KEY=group_add;           TYPE=list;;
            --tmpfs)                    KEY=tmpfs;               TYPE=list;;
            --expose)                   KEY=expose;              TYPE=list;;
            --sysctl)                   KEY=sysctls;             TYPE=list;;
            -l|--label)                 KEY=labels;              TYPE=list;;
            # --ulimit name=soft[:hard]
            --ulimit)                   KEY=ulimits;             TYPE=ulimit;;
            *)
                # unknown options might have a value, report it along with the option
                if ! $HAS_VALUE && [ $i -lt ${#ARGS[@]} ] && [[ "${ARGS[$i]}" != -* ]]; then
                    ARG="$ARG ${ARGS[$i]}"
                    i=$((i+1))
                fi
                UNSUPPORTED+=("$ARG")
                continue;;
        esac

        if [ "$TYPE" = "flag" ]; then
            VALUE=${VALUE:-true}
            if [ "$VALUE" != "true" ] && [ "$VALUE" != "false" ]; then
                UNSUPPORTED+=("$ARG")
                continue
            fi
        elif ! $HAS_VALUE; then
            if [ $i -ge ${#ARGS[@]} ]; then
                UNSUPPORTED+=("$ARG (value missing)")
                continue
            fi
            VALUE=${ARGS[$i]}
            i=$((i+1))
        fi

        if [ "$TYPE" = "ulimit" ] && [[ ! "$VALUE" =~ ^[a-z]+=-?[0-9]+(:-?[0-9]+)?$ ]]; then
            UNSUPPORTED+=("$OPT $VALUE")
            continue
        fi

        # named volumes (-v name:/path) need to be declared, docker run creates them automatically
        if [ "$KEY" = "volumes" ] && [[ ! "$VALUE" =~ ^[/.~$] ]]; then
            RUN_ARGS_NAMED_VOLUMES+=("${VALUE%%:*}")
        fi

        # keep the order of the run args
        if [ -z "${VALUES[$KEY]+set}" ]; then
            KEYS+=("$KEY")
        fi
        case "$TYPE" in
            flag)  VALUES[$KEY]=" $VALUE";;
            value) VALUES[$KEY]=" $(yaml_quote "$VALUE")";;
            list)  VALUES[$KEY]+=$'\n'"      - $(yaml_quote "$VALUE")";;
            ulimit)
                ULIMIT_NAME=${VALUE%%=*}
                ULIMIT=${VALUE#*=}
                if [[ "$ULIMIT" == *:* ]]; then
                    VALUES[$KEY]+=$'\n'"      $ULIMIT_NAME:"$'\n'"        soft: ${ULIMIT%%:*}"$'\n'"        hard: ${ULIMIT##*:}"
                else
                    VALUES[$KEY]+=$'\n'"      $ULIMIT_NAME: $ULIMIT"
                fi;;
        esac
    done

    if [ ${#UNSUPPORTED[@]} -gt 0 ]; then
        $PRINT_WARNING -e "\e[31mError: these ADDITIONAL_DOCKER_RUN_ARGS cannot be translated to docker compose:\e[0m"
        for ARG in "${UNSUPPORTED[@]}"; do
            $PRINT_WARNING "    $ARG"
        done
        $PRINT_WARNING "Please add them to the \"workspace\" service in docker-compose.exec.bash.yml instead"
        return 1
    fi

    if [ ${#KEYS[@]} -eq 0 ]; then
        return 0
    fi

    RUN_ARGS_COMPOSE_YAML="services:"$'\n'"  workspace:"
    for KEY in "${KEYS[@]}"; do
        RUN_ARGS_COMPOSE_YAML+=$'\n'"    $KEY:${VALUES[$KEY]}"
    done
    if [ ${#RUN_ARGS_NAMED_VOLUMES[@]} -gt 0 ]; then
        RUN_ARGS_COMPOSE_YAML+=$'\n'"volumes:"
        for VALUE in "${RUN_ARGS_NAMED_VOLUMES[@]}"; do
            RUN_ARGS_COMPOSE_YAML+=$'\n'"  $(yaml_quote "$VALUE"):"$'\n'"    name: $(yaml_quote "$VALUE")"$'\n'"    external: true"
        done
    fi
}
