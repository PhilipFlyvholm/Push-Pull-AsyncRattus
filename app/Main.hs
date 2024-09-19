{-# OPTIONS -fplugin=AsyncRattus.Plugin #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Avoid lambda" #-}
module Main where

import AsyncRattus
import AsyncRattus.Channels
import AsyncRattus.Signal
import Prelude hiding (init)

everySecond :: Box (O ()) -- Box makes the function stable and O() is a delayed unit
everySecond = timer 1000000 -- 1 second = 1.000.000 microseconds

everySecondSig :: Sig ()
everySecondSig =  () ::: mkSig everySecond

setPrint :: (Producer p a, Show a) => p -> IO ()
setPrint sig = setOutput sig print

-- Scan http://www.zvon.org/other/haskell/Outputprelude/scanl_f.html
nats :: Int -> Sig Int
nats init = scan (box (\ n _ -> n+1)) init everySecondSig

main :: IO ()
main = do
    showNat <- trigger (box (\_ n -> n)) everySecondSig (nats 0)

    setPrint showNat
    startEventLoop

