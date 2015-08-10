{-# LANGUAGE CPP, OverloadedStrings, ForeignFunctionInterface #-}
import Haste.Foreign
import Foreign
import Foreign.C
import Foreign.C.Types

foreign import ccall "wrapper" wrap :: (Double -> IO ()) -> IO (FunPtr (Double -> IO ()))
foreign import ccall fficall :: FunPtr (Double -> IO ()) -> IO ()

call :: (Double -> IO ()) -> IO ()
call = ffi "(function(f){for(var i=0;i<10000;++i){f(i);}})"

f :: Double -> IO ()
f x = x `seq` return ()

times :: IO () -> Int -> IO ()
times act n = go n
  where
    go 0 = return ()
    go n = act >> go (n-1)

#ifdef __USE_HASTE_FOREIGN__

#ifdef __USE_TIGHT_LOOP__
main = times (call f) 1000
#else
main = mapM_ (\_ -> call f) [1..1000::Int]
#endif

#else

#ifdef __USE_TIGHT_LOOP__
main = times (wrap f >>= fficall) 1000
#else
main = mapM_ (\_ -> wrap f >>= fficall) [1..1000::Int]
#endif


#endif
