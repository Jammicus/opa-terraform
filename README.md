# opa-terraform
Play repo for playing with opa + terraform

## Running

The make file will hold the various commmands for running

## What it does

Given a series of resources, a weight is assigned to them based on how much it would "cost" to delete, modify or create. If a series of changes is greater than the accepted blast radius for a deploy, it will fail

