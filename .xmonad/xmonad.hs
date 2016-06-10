import System.IO                    (hPutStrLn)
import XMonad
import XMonad.Hooks.DynamicLog      (xmobarPP, xmobarColor, ppOutput, ppTitle, shorten, dynamicLogWithPP)
import XMonad.Hooks.ManageDocks     (avoidStruts, manageDocks)
import XMonad.Util.Run              (spawnPipe)
import XMonad.Util.EZConfig         (additionalKeys)
import XMonad.Actions.CycleWS       (nextWS, prevWS, shiftToNext, shiftToPrev)

myterminal = "/usr/bin/xfce4-terminal"
winKey     = mod4Mask
altKey     = mod1Mask
ctrlKey    = controlMask
shiftKey   = shiftMask

myAddedKeys =
      ((winKey .|. ctrlKey, xK_Delete), spawn "xscreensaver-command -lock")
    -- : ((winKey .|. ctrlKey, xK_h), prevWS)
    -- : ((winKey .|. ctrlKey, xK_l), nextWS)
    : ((winKey .|. ctrlKey .|. shiftKey, xK_h), shiftToPrev >> prevWS)
    : ((winKey .|. ctrlKey .|. shiftKey, xK_l), shiftToNext >> nextWS)
    : ((winKey, xK_p), spawn "dmenu_run -p 'RUN:' -l 16 -b -i")
    : ((winKey .|. altKey, xK_h), spawn "xdotool mousemove_relative -- -20 0")
    : ((winKey .|. altKey, xK_j), spawn "xdotool mousemove_relative -- 0 20")
    : ((winKey .|. altKey, xK_k), spawn "xdotool mousemove_relative -- 0 -20")
    : ((winKey .|. altKey, xK_l), spawn "xdotool mousemove_relative -- 20 0")
    : ((winKey .|. altKey .|. shiftKey, xK_h), spawn "xdotool mousemove_relative -- -5 0")
    : ((winKey .|. altKey .|. shiftKey, xK_j), spawn "xdotool mousemove_relative -- 0 5")
    : ((winKey .|. altKey .|. shiftKey, xK_k), spawn "xdotool mousemove_relative -- 0 -5")
    : ((winKey .|. altKey .|. shiftKey, xK_l), spawn "xdotool mousemove_relative -- 5 0")
    : ((winKey .|. altKey, xK_i), spawn "xdotool getwindowfocus click 1")
    : ((winKey .|. altKey, xK_o), spawn "xdotool getwindowfocus click 3")
    : ((winKey .|. altKey, xK_p), spawn "xdotool getwindowfocus click 4")
    : ((winKey .|. altKey, xK_n), spawn "xdotool getwindowfocus click 5")
    : []

main = do
  xmproc <- spawnPipe "xmobar"
  xmonad $ defaultConfig
    { manageHook        = manageDocks <+> manageHook defaultConfig
    , layoutHook        = avoidStruts $ layoutHook defaultConfig
    , logHook           = dynamicLogWithPP $ xmobarPP
      { ppOutput        = hPutStrLn xmproc
      , ppTitle         = xmobarColor "green" "" .shorten 94
      }
    , modMask           = winKey
    , terminal          = myterminal
    , borderWidth       = 3
    , focusFollowsMouse = True
    }

    `additionalKeys` myAddedKeys

