#!/bin/bash

## Implement node utilitly functions

[[ -z "$NODE" ]] && declare NODE=true || return;

DEBUG::off NODE


# (String path) => int... ids;
function NODE::get_all() {
    alert NODE "in NODE::get_all";

    local path="${1:-.}";
    
    local -a nodes=();
   
    local node; for node in $path/*; do
        [[ "$node" == "$path/*" ]] && return;
        
        node=$(basename $node);
        
        [[ "$node" =~ ^[0-9]+$ ]] && nodes+=("$node");
    done
    
    # slow selection sort
    local i; for (( i = 0; i < ${#nodes[@]}; i++ )); do
        
        local next=$i;
        
        local j; for (( j = i; j < ${#nodes[@]}; j++ )); do
            (( ${nodes[j]} < ${nodes[next]} )) && next=$j;
        done
        
        local temp=${nodes[$i]};
        nodes[$i]=${nodes[$next]};
        nodes[$next]=$temp;
        
    done
    
    echo ${nodes[@]};
}

# (String path) => int id
function NODE::get_last() {
    alert NODE "in NODE::get_last";
    local path="${1:-.}";
    
    local -a nodes=( $(NODE::get_all "$path") );
    
    (( ${#nodes[@]} > 0 )) && echo ${nodes[-1]};
}

# (String path) => int id
function NODE::get_next() {
    alert NODE "in NODE::get_next";
    
    local path="${1:-.}";
    
    local last=$(NODE::get_last "$path");
    
    [[ -n $last ]] && echo $(( last + 1 )) || echo 0;
    
}

# (String path, int id) => String node_path
function NODE::get_path() {
    alert NODE "in NODE::get_path";
    
    local path="${1:-.}";
    local id="$2";
    
    local last_index=$(( ${#path} - 1 ));
    [[ ${path:$last_index} == '/' ]] && path=${path:0:$last_index}
    
    echo "$path/$id";
}


# (String path) => int id -> create path/id
function NODE::create_dir() {
    alert NODE "in NODE::create_dir";
    
    local path="${1:-.}";
    local verbal="$2";
    
    local next=$(NODE::get_next "$path");
        
    local node_path=$(NODE::get_path "$path" "$next");
    alert NODE "$node_path";
    
    ERROR::clear;    
    local err_msg=$(mkdir -p "$node_path" 2>&1);
    local err_no="$?";
    
    if (( err_no > 0 )); then
        error "err_no" "$err_msg";
        return;
    fi
    
    echo $next;
}



# (String path, int parent_id) => int child_id
function NODE::create() {
    alert NODE "in NODE::create";
    
    local path="${1:-.}";
    
    local parent_id="$2";
    
    local child_id=$(NODE::create_dir "$path");
    
    if [[ -n $parent_id ]]; then
    
        NODE::set_parent "$path" "$child_id" "$id";
    
        NODE::add_child "$path" "$id" "$child_id";
    fi
    
    echo $child_id;
}


# (String path, int child_id, int parent_id) -> sets parent
function NODE::set_parent() {
    alert NODE "in NODE::set_parent";
    
    local path="${1:-.}";
    local child_id="$2";
    local parent_id="$3";
    
    local node_path=$(NODE::get_path "$path" "$child_id");
    
    echo "$parent_id" > "$node_path/.parent";
}

# (String path, int id) => parent_id
function NODE::get_parent() {
    alert NODE "in NODE::get_parent";
    
    local path="${1:-.}";    
    local id="$2";
    
    local node_path=$(NODE::get_path "$path" "$id");
    
    
    if [[ -e "$node_path/.parent" ]]; then
        cat "$node_path/.parent";
    fi
}

# (String path, int parent_id, int child_id) -> adds child to parent's list
function NODE::add_child() {
    alert NODE "in NODE::add_child";
    
    local path="${1:-.}";
    local parent_id="$2";
    local child_id="$3";
    
    local node_path=$(NODE::get_path "$path" "$id");
    
    echo "$child_id" >> "$node_path/.children"
}
# (String path, int id) => int... id
function NODE::get_children() {   
    alert NODE "in NODE::get_children";
    
    local path="${1:-.}";
    local id="$2";
    
    local node_path=$(NODE::get_path "$path" "$id");
    
    if [[ -e "$node_path/.children" ]]; then
        
        while read -r line; do
            
            echo "$line";
            
        done < "$node_path/.children";
        
    fi
}


# (String path, int id) => int... id
function NODE::trace_root() {
    alert NODE "in NODE::trace_root";
    
    local path="${1:-.}";
    local id="$2";
    
    local parent_id=$(NODE::get_parent "$path" "$id");
    
    if [[ -n "$parent_id" ]]; then
        echo $parent_id;
        NODE::trace_root "$path" "$parent_id";
    fi
}

