import Lake
open Lake DSL

require raylean from git "https://github.com/funexists/raylean.git" @ "3a60f54222e06767daa93e50a8fcbc68975eee4c" with
  NameMap.empty
    |>.insert `bundle "off"
    |>.insert `resvg "disable"

require «lean-ecs» from "../"

package "ecs-examples" where
  srcDir := "src"

lean_lib «Examples» where

@[default_target]
lean_exe "ecs-examples" where
  root := `Main
  moreLinkArgs := Id.run do
    let mut args := #[ "lib/libraylib.a"]
    if (← System.Platform.isOSX) then
      args := args ++
        #[ "-isysroot", "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
         , "-framework", "IOKit"
         , "-framework", "Cocoa"
         , "-framework", "OpenGL"
         ]
    args
