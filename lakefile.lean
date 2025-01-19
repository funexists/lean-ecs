import Lake
open Lake DSL

package "lean-ecs" where
  srcDir := "src"

@[default_target]
lean_lib «ECS» where
