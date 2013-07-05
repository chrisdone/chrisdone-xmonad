{-# LANGUAGE FlexibleContexts #-}

-- | The client window (webkit).

module XMonad.Suave.Window where

import XMonad.Suave.Types

import Control.Monad
import Data.Monoid
import Graphics.UI.Gtk hiding (LayoutClass)
import Graphics.UI.Gtk.WebKit.WebView
import XMonad hiding (Window)
import XMonad.Layout.Gaps
import XMonad.Layout.LayoutModifier
import XMonad.StackSet

-- | Start up a Suave panel.
suaveStart :: IO Suave
suaveStart = do
  void initGUI
  window <- windowNew
  vContainer <- vBoxNew False 0
  scrolledWindow <- scrolledWindowNew Nothing Nothing
  scrolledWindowSetPolicy scrolledWindow PolicyNever PolicyNever
  webview <- webViewNew
  set window [containerChild := vContainer
             ,windowTitle    := suaveWindowTitle]
  boxPackStart vContainer scrolledWindow PackGrow 0
  set scrolledWindow [containerChild := webview]
  webViewLoadUri webview ("http://localhost:" ++ show suavePort)
  void (onDestroy window mainQuit)
  void (widgetShowAll window)
  return (Suave window)

-- | Setup the right panel layout for Suave.
suaveLayout :: ModifiedLayout Gaps (Choose Tall Full) a
suaveLayout = gaps [(U,40)] (Tall 1 (3/100) (1/2) ||| Full)

-- | Set the position of the Suave panel.
suaveStartupHook :: Suave -> X ()
suaveStartupHook (Suave suave) = withWindowSet $ \stackset -> do
  liftIO (windowResize suave
                       (head (map (fromIntegral . rect_width . screenRect . screenDetail)
                                  (screens stackset)))
                       40)

-- | Ignore the Suave window as a panel.
suaveManageHook :: Query (Endo WindowSet)
suaveManageHook = composeAll [ title =? suaveWindowTitle --> doIgnore]

-- | Window title of the Suave panel.
suaveWindowTitle :: String
suaveWindowTitle = "xmonad-suave-panel"
