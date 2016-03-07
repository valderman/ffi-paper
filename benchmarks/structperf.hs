{-# LANGUAGE OverloadedStrings, ForeignFunctionInterface, CPP #-}
import Data.Word
import Haste.Foreign
import Control.Applicative
import Data.Time.Clock
import Foreign
import Foreign.C.Types
import Safe

data MyTime = MyTime {
    secs  :: Word,
    usecs :: Word
  } deriving Show

instance FromAny MyTime where
  fromAny x = MyTime <$> get x "secs" <*> get x "usecs"

instance ToAny MyTime where
  toAny (MyTime s u) = toObject [("secs", toAny s), ("usecs", toAny u)]

getMyTime :: MyTime -> IO MyTime
getMyTime =
  ffi "(function(tv){var ms = new Date().getTime();\
                    return {secs:  ms/1000,\
                            usecs: (ms % 1000)*1000};})"

instance Storable MyTime where
        sizeOf _ = (sizeOf (undefined :: CLong)) * 2
        alignment _ = alignment (undefined :: CLong)
        peek p = do
                MyTime <$> peekElemOff (castPtr p) 0
                       <*> peekElemOff (castPtr p) 1
        poke p (MyTime s mus) = do
                pokeElemOff (castPtr p) 0 s
                pokeElemOff (castPtr p) 1 mus

foreign import ccall unsafe "gettimeofday"
   gettimeofday :: Ptr MyTime -> Ptr () -> IO CInt

getTime :: MyTime -> IO MyTime
getTime tv = with tv $ \ptval -> do
  gettimeofday ptval nullPtr
  peek ptval

bench :: (MyTime -> IO MyTime) -> Int -> IO ()
bench act n = go n
  where
    go 0   = return ()
    go n = do
      x <- act (MyTime 0 0)
      x `seq` go (n-1)

#ifdef __USE_HASTE_FOREIGN__
getT = getMyTime
#else
getT = getTime
#endif

#ifdef __USE_TIGHT_LOOP__
main = bench getT 500000
#else
main = do
  x <- flip mapM_ [1..500000::Int] $ \_ -> do
    x <- getT (MyTime 0 0)
    return ()
  return ()
#endif
