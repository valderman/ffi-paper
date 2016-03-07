{-# LANGUAGE OverloadedStrings #-}
module Safe where
import Haste
import Haste.Foreign
import Control.Exception

data DerpException = DerpException JSString
  deriving Show
instance Exception DerpException

safely :: (ToAny a, FromAny a) => (JSString -> IO ()) -> IO a -> IO a
safely = ffi "(function(h,m){try {return m();} catch(e) {h(e);}})"

class Safely a where
  addSafety :: a -> a

instance Safely b => Safely (a -> b) where
  addSafety f = \x -> addSafety (f x)

instance (ToAny a, FromAny a) => Safely (IO a) where
  addSafety = safely handler

handler :: JSString -> IO ()
handler = throwIO . DerpException

xsafe_ffi :: (Safely a, FFI a) => JSString -> a
xsafe_ffi = addSafety ffi
