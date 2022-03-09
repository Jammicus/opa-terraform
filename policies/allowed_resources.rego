package terraform.analysis

import input as tfplan

blast_radius := 30

# Force recreated will trigger delete
weights := {
    "time_rotating": {"delete": 0, "create": 0, "modify": 0},
    "local_file": {"delete": 0, "create": 0, "modify": 0},
    "tls_private_key": {"delete": 0, "create": 5, "modify": 5},
    "tls_self_signed_cert": {"delete": 2, "create": 10, "modify":0}
}

resource_types := {"time_rotating", "local_file", "tls_private_key", "tls_self_signed_cert"}

# If the blast radius is 
auth {
    score < blast_radius
}

# Compute the score for a Terraform plan as the weighted sum of deletions, creations, modifications
score = s {
    all := [ x |
            some resource_type
            crud := weights[resource_type];
            del := crud["delete"] * num_deletes[resource_type];
            new := crud["create"] * num_creates[resource_type];
            mod := crud["modify"] * num_modifies[resource_type];
            x := del + new + mod
            print("Resource ", resource_type)
            print("score ", x)

    ]
    s := sum(all)
    print("Total score", s, " Max score", blast_radius)
}

# Whether there is any change to IAM
touches_iam {
    all := resources["aws_iam"]
    count(all) > 0
}



# list of all resources of a given type
resources[resource_type] = all {
    some resource_type
    resource_types[resource_type]
    all := [name |
        name:= tfplan.resource_changes[_]
        name.type == resource_type
    ]
}

# number of creations of resources of a given type
num_creates[resource_type] = num {
    some resource_type
    resource_types[resource_type]
    all := resources[resource_type]
    creates := [res |  res:= all[_]; res.change.actions[_] == "create"]
    num := count(creates)
}


# number of deletions of resources of a given type
num_deletes[resource_type] = num {
    some resource_type
    resource_types[resource_type]
    all := resources[resource_type]
    deletions := [res |  res:= all[_]; res.change.actions[_] == "delete"]
    num := count(deletions)
}

# number of modifications to resources of a given type
num_modifies[resource_type] = num {
    some resource_type
    resource_types[resource_type]
    all := resources[resource_type]
    modifies := [res |  res:= all[_]; res.change.actions[_] == "update"]
    num := count(modifies)
}