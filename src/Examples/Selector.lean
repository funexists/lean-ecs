import «Raylib»
import Examples

import Examples.Elab

namespace Selector

/-- Demos supported in the selector --/
inductive Demo where
  | window
  | platformer2d
  | cube3d
  | inputKeys

def Demo.all := allElements Demo

def screenWidth : Nat := 800
def optionHeight : Nat := 80
def screenHeight : Nat := Demo.all.size * optionHeight
def fps : Nat := 60
def textSize : Nat := 20
def lightSelectorColor : Color := Color.Raylib.blue
def darkSelectorColor : Color := Color.Raylib.darkblue
def selectorTextColor : Color := Color.black

structure DemoInfo where
  /-- The action that starts the demo --/
  start : IO Unit
  /-- The title that identifies the demo --/
  title : String

def mkDemoInfo : Demo -> DemoInfo
   | .window => {start := window, title := "Basic window"}
   | .platformer2d => {start := camera2DPlatformer, title := "2D Platformer"}
   | .cube3d => {start := camera3D, title := "3D Cube"}
   | .inputKeys => {start := inputKeys, title := "Input keys"}

structure DemoRenderInfo where
  /-- The action that starts the demo --/
  start : IO Unit
  /-- The action that renders the demo selector --/
  render : IO Unit
  /-- An action that determines if the position has clicked the demo selector --/
  isClicked : Vector2 -> IO Bool

/-- Construct a DemoRenderInfo for each Demo --/
def demoRenderInfos : Array DemoRenderInfo :=
  let f {n : Nat} (idx : Fin n) (demo : Demo) :=
    let demoInfo := mkDemoInfo demo
    let yOffset := idx * optionHeight
    let rect : Rectangle :=
      { x := 0
      , y := yOffset.toFloat
      , width := screenWidth.toFloat
      , height := optionHeight.toFloat }
    let color := if idx.val % 2 == 0 then lightSelectorColor else darkSelectorColor
    let render := do
      drawRectangleRec rect color
      drawText demoInfo.title (Nat.div screenWidth 3) (yOffset + Nat.div optionHeight 2) textSize selectorTextColor
    let isClicked (pos : Vector2) := checkCollisionPointRec pos rect
    {start := demoInfo.start, render, isClicked : DemoRenderInfo}
  (allElements Demo).mapIdx f

/-- Start the selector --/
def start : IO Unit := do
  let mut launchDemo : Option (IO Unit) := none
  while not (← windowShouldClose) do
    if (← isMouseButtonPressed MouseButton.left) then do
      let pos ← getMousePosition
      launchDemo := DemoRenderInfo.start <$> (← demoRenderInfos.findM? (·.isClicked pos))
      if launchDemo.isSome then break

    renderFrame do
      clearBackground Color.green
      for i in demoRenderInfos do i.render
  closeWindow

  match launchDemo with
    | some start => start
    | _ => return ()

end Selector

def selector : IO Unit := do
  initWindow Selector.screenWidth Selector.screenHeight "Select a demo"
  setTargetFPS 60
  Selector.start
