{-# LANGUAGE CPP, OverloadedStrings, ForeignFunctionInterface, BangPatterns #-}
import Haste
import Haste.Foreign

#ifdef __USE_HASTE_FOREIGN__
import Safe

f :: Double -> Double -> Double -> Double -> Double -> IO Double
f = ffi "(function(a,b,c,d,e){return 0;})"

#else

foreign import stdcall f :: Double -> Double -> Double -> Double -> Double -> IO Double

#endif

#ifdef __USE_TIGHT_LOOP__

theTest = do
  n <- for 500000 $ \n -> f 1 2 3 4 n
  print n

#else

#ifdef __MARSHAL_INBOUND__
theTest = do
  x <- flip mapM [1..500::Int] $ \_ -> do
    x <- mapM (\x -> f 1 2 3 4 x) [1..1000]
    return $ sum x
  print $ sum x
#else
theTest = do
  x <- flip mapM_ [1..500::Int] $ \_ -> do
    x <- mapM_ (\x -> f 1 2 3 4 x) [1..1000]
    return ()
  print ()
#endif

#endif

for :: Double -> (Double -> IO Double) -> IO Double
for to f = go 0 to 0
  where
    go from to !acc
#ifdef __MARSHAL_INBOUND__
      | from < to = f from >>= \x -> go (from+1) to (x+acc)
#else
      | from < to = f from >>= \x -> go (from+1) to (1+acc)
#endif
      | otherwise = return acc

main = theTest
