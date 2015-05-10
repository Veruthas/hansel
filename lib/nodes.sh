#!/bin/bash

## Implement node utilitly functions

DEBUG::off NODES


# (String path) => int... ids;
function NODES::get_all() {
    alert NODES "in NODES::get_all";

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
function NODES::get_last() {
    alert NODES "in NODES::get_last";
    local path="${1:-.}";
    
    local -a nodes=( $(NODES::get_all "$path") );
    
    (( ${#nodes[@]} > 0 )) && echo ${nodes[-1]};
}

# (String path) => int id
function NODES::get_next() {
    alert NODES "in NODES::get_next";
    
    local path="${1:-.}";
    
    local last=$(NODES::get_last "$path");
    
    [[ -n $last ]] && echo $(( last + 1 )) || echo 0;
    
}

# (String path, int id) => String node_path
function NODES::get_path() {
    alert NODES "in NODES::get_path";
    
    local path="${1:-.}";
    local id="$2";
    
    local last_index=$(( ${#path} - 1 ));
    [[ ${path:$last_index} == '/' ]] && path=${path:0:$last_index}
    
    echo "$path/$id";
}


# (String path) => int id -> create path/id
function NODES::create_dir() {
    alert NODES "in NODES::create_dir";
    
    local path="${1:-.}";
    local verbal="$2";
    
    local next=$(NODES::get_next "$path");
        
    local node_path=$(NODES::get_path "$path" "$next");
    alert NODES "$node_path";
    
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
function NODES::create() {
    alert NODES "in NODES::create";
    
    local path="${1:-.}";
    
    local parent_id="$2";
    
    local child_id=$(NODES::create_dir "$path");
    
    if [[ -n $parent_id ]]; then
    
        NODES::set_parent "$path" "$child_id" "$id";
    
        NODES::add_child "$path" "$id" "$child_id";
    fi
    
    echo $child_id;
}


# (String path, int child_id, int parent_id) -> sets parent
function NODES::set_parent() {
    alert NODES "in NODES::set_parent";
    
    local path="${1:-.}";
    local child_id="$2";
    local parent_id="$3";
    
    local node_path=$(NODES::get_path "$path" "$child_id");
    
    echo "$parent_id" > "$node_path/.parent";
}

# (String path, int id) => parent_id
function NODES::get_parent() {
    alert NODES "in NODES::get_parent";
    
    local path="${1:-.}";    
    local id="$2";
    
    local node_path=$(NODES::get_path "$path" "$id");
    
    
    if [[ -e "$node_path/.parent" ]]; then
        cat "$node_path/.parent";
    fi
}

# (String path, int parent_id, int child_id) -> adds child to parent's list
function NODES::add_child() {
    alert NODES "in NODES::add_child";
    
    local path="${1:-.}";
    local parent_id="$2";
    local child_id="$3";
    
    local node_path=$(NODES::get_path "$path" "$id");
    
    echo "$child_id" >> "$node_path/.children"
}
# (String path, int id) => int... id
function NODES::get_children() {   
    alert NODES "in NODES::get_children";
    
    local path="${1:-.}";
    local id="$2";
    
    local node_path=$(NODES::get_path "$path" "$id");
    
    if [[ -e "$node_path/.children" ]]; then
        
        while read -r line; do
            
            echo "$line";
            
        done < "$node_path/.children";
        
    fi
}


# (String path, int id) => int... id
function NODES::trace_root() {
    alert NODES "in NODES::trace_root";
    
    local path="${1:-.}";
    local id="$2";
    
    local parent_id=$(NODES::get_parent "$path" "$id");
    
    if [[ -n "$parent_id" ]]; then
        echo $parent_id;
        NODES::trace_root "$path" "$parent_id";
    fi
}

