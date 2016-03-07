{-# LANGUAGE CPP, OverloadedStrings, ForeignFunctionInterface #-}
import Haste.Foreign
import Foreign
import Foreign.C
import Foreign.C.Types
import Safe

foreign import stdcall "wrapper" wrap :: (Double -> IO ()) -> IO (FunPtr (Double -> IO ()))
foreign import stdcall fficall :: FunPtr (Double -> IO ()) -> IO ()

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
main = times (call f) 500000
#else
main = mapM_ (\_ -> call f) [1..500000::Int]
#endif

#else

#ifdef __USE_TIGHT_LOOP__
main = times (wrap f >>= fficall) 500000
#else
main = mapM_ (\_ -> wrap f >>= fficall) [1..500000::Int]
#endif


#endif
