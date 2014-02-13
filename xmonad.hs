-- Import statements
import XMonad
import System.Exit
import Control.Monad
import XMonad.Util.Run(spawnPipe)
import System.IO
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.EZConfig
import Graphics.X11.ExtraTypes.XF86

import XMonad.Actions.GridSelect
    
import XMonad.Layout.NoBorders (smartBorders, noBorders)
import XMonad.Layout.ResizableTile
import XMonad.Layout.SimpleFloat
import XMonad.Layout.Gaps
    
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- Define terminal
myTerminal = "gnome-terminal --hide-menubar"

-- Width of the window border in pixels.
myBorderWidth = 3

-- Border colors for unfocused and focused windows, respectively.
myNormalBorderColor = "#424242"
myFocusedBorderColor = "#ff00ff"

-- Define the names of all workspaces
myWorkspaces = ["main", "emacs", "webdoc", "gimp", "chat", "player", "rdesktop", "vbox", "hide"]
               
-- myLayout = gaps [(D,16)] $ avoidStruts $ smartBorders tiled ||| smartBorders (Mirror tiled)  ||| noBorders Full ||| smartBorders simpleFloat
myLayout = avoidStruts $ smartBorders tiled ||| noBorders Full
  where
    --tiled = ResizableTall 1 (2/100) (1/2) []
    tiled   = ResizableTall nmaster delta ratio []
    nmaster = 1   
    ratio   = 3/4
    delta   = 2/100

-- Key bindings. Add, modify or remove key bindings here.
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
 
    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
 
    -- launch dmenu
    , ((XMonad.mod4Mask,    xK_f     ), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")
 
    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")
 
    -- close focused window 
    , ((modm .|. shiftMask, xK_c     ), kill)
 
     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)
 
    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
 
    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)
 
    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)
 
    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)
 
    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )
 
    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )
 
    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)
 
    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )
 
    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )
 
    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)
 
    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)
 
    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)
 
    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))
 
    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))
 
    -- toggle the status bar gap (used with avoidStruts from Hooks.ManageDocks)
    -- , ((modm , xK_b ), sendMessage ToggleStruts)
 
    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))
 
    -- Restart xmonad
    , ((modm              , xK_q     ), restart "xmonad" True)

    -- , ((0, xK_Print), spawn "scrot Screenshot.png")
    , ((0, xK_Print), spawn "gnome-screenshot")

    , ((0            , 0x1008ff11), spawn "amixer -q set Master unmute & amixer -q set LFE unmute & amixer -q set PCM 7%-")
    -- XF86AudioRaiseVolume
    , ((0            , 0x1008ff13), spawn "amixer -q set Master unmute & amixer -q set LFE unmute & amixer -q set PCM 7%+")
    -- XF86AudioMute
    , ((0            , 0x1008ff12), spawn "amixer -q set Master toggle & amixer -q set LFE toggle")
    ]
    ++
 
    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
 
    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

    ++

    -- volumn
    [((0                     , 0x1008FF11), spawn "amixer set Master 5-")
    ,((0                     , 0x1008FF13), spawn "amixer set Master 5+")
    ,((0                     , 0x1008FF12), spawn "amixer -D pulse set Master toggle")
    ]

    ++

    [((modm, xK_v), spawnSelected defaultGSConfig ["google-chrome"
                                                  ,"xterm","smplayer","gnome-screenshot","emacs"
                                                  ,"gvim","rhythmbox","software-center","gimp","dia"])
    , ((modm, xK_g), goToSelected defaultGSConfig)
    ]

-- Define the workspace an application has to go to
myManageHook = composeAll . concat $
    [
          -- Float apps
        [ className =? c --> doFloat                 | c <- myClassFloats ]
          -- Applications that go to main
      , [ className =? c --> viewShift "main"         | c <- myClassMainShifts ]
          -- Applications that go to emacs
      , [ className =? c --> doF (W.shift "emacs")         | c <- myClassEmacsShifts ]
          -- Applications that go to web
      , [ className =? c --> doF (W.shift "webdoc")         | c <- myClassWebShifts ]
          -- Applications that go to virtual box
      , [ className =? c --> doF (W.shift "vbox")    | c <- myClassVirtualBoxShifts ]
          -- Applications that go to player
      , [ className =? c --> doF (W.shift "player")    | c <- myClassPlayerShifts ]
          -- Applications that go to rdesktop
      , [ className =? c --> doF (W.shift "rdesktop")    | c <- myClassRdesktopShifts ]
          -- Applications that go to gimp
      , [ className =? c --> doF (W.shift "gimp")    | c <- myClassGimpShifts ]
          -- Applications that go to chat
      , [ className =? c --> doF (W.shift "chat")    | c <- myClassChatShifts ]
          -- Applications that go to hide
      , [ className =? c --> doF (W.shift "hide")    | c <- myClassHideShifts ]
    ] 
    where
    viewShift                   = doF . liftM2 (.) W.greedyView W.shift
    myClassFloats               = ["Pidgin"]
    myClassMainShifts           = []
    myClassEmacsShifts          = ["Emacs24"]
    myClassWebShifts            = ["Google-chrome", "Evince"]
    myClassRdesktopShifts       = ["rdesktop"]
    myClassVirtualBoxShifts     = ["VirtualBox"]
    myClassPlayerShifts         = ["Rhythmbox"]
    myClassGimpShifts           = ["Gimp","Dia-normal"]
    myClassChatShifts           = ["Pidgin", "Thunderbird"]
    myClassHideShifts           = ["Stardict"]

gsconfig colorizer = (buildDefaultGSConfig colorizer) { gs_cellheight = 60, gs_cellwidth = 200 }
-- | A green monochrome colorizer based on window class
greenColorizer = colorRangeFromClassName
                      black            -- lowest inactive bg
                      (0x70,0xFF,0x70) -- highest inactive bg
                      black            -- active bg
                      white            -- inactive fg
                      white            -- active fg
  where black = minBound
        white = maxBound

-- Run XMonad 
main = do
  xmproc <- spawnPipe "/home/xb/.cabal/bin/xmobar /home/xb/.xmonad/xmonbar.hs"

  xmonad $ defaultConfig {
      	modMask            = mod1Mask
      , borderWidth        = myBorderWidth
      ,	normalBorderColor  = myNormalBorderColor
      ,	focusedBorderColor = myFocusedBorderColor
      , terminal           = myTerminal
      , keys               = myKeys
      , workspaces         = myWorkspaces
      , manageHook         = manageDocks <+> myManageHook
                             <+> manageHook defaultConfig
      -- , layoutHook = avoidStruts  $  layoutHook defaultConfig
      , layoutHook         = myLayout
      , logHook     = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
     }
