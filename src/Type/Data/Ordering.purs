module Type.Data.Ordering
  ( module PO
  , OProxy(..)
  , class IsOrdering
  , reflectOrdering
  , reifyOrdering
  , class Append
  , append
  , class Invert
  , invert
  , class Equals
  , equals
  ) where

import Prim.Ordering (LT, EQ, GT, Ordering) as PO
import Data.Ordering (Ordering(..))
import Type.Data.Boolean (True, False, BProxy(..))
import Type.Proxy (Proxy(..))

-- | Value proxy for `Ordering` types
data OProxy :: PO.Ordering -> Type
data OProxy ordering = OProxy

-- | Class for reflecting a type level `Ordering` at the value level
class IsOrdering :: PO.Ordering -> Constraint
class IsOrdering ordering where
  reflectOrdering :: forall proxy. proxy ordering -> Ordering

instance isOrderingLT :: IsOrdering PO.LT where reflectOrdering _ = LT
instance isOrderingEQ :: IsOrdering PO.EQ where reflectOrdering _ = EQ
instance isOrderingGT :: IsOrdering PO.GT where reflectOrdering _ = GT

-- | Use a value level `Ordering` as a type-level `Ordering`
reifyOrdering :: forall r. Ordering -> (forall proxy o. IsOrdering o => proxy o -> r) -> r
reifyOrdering LT f = f (Proxy :: Proxy PO.LT)
reifyOrdering EQ f = f (Proxy :: Proxy PO.EQ)
reifyOrdering GT f = f (Proxy :: Proxy PO.GT)

-- | Append two `Ordering` types together
-- | Reflective of the semigroup for value level `Ordering`
class Append :: PO.Ordering -> PO.Ordering -> PO.Ordering -> Constraint
class Append lhs rhs output | lhs -> rhs output
instance appendOrderingLT :: Append PO.LT rhs PO.LT
instance appendOrderingEQ :: Append PO.EQ rhs rhs
instance appendOrderingGT :: Append PO.GT rhs PO.GT

append :: forall l r o. Append l r o => OProxy l -> OProxy r -> OProxy o
append _ _ = OProxy

-- | Invert an `Ordering`
class Invert :: PO.Ordering -> PO.Ordering -> Constraint
class Invert ordering result | ordering -> result
instance invertOrderingLT :: Invert PO.LT PO.GT
instance invertOrderingEQ :: Invert PO.EQ PO.EQ
instance invertOrderingGT :: Invert PO.GT PO.LT

invert :: forall i o. Invert i o => OProxy i -> OProxy o
invert _ = OProxy

class Equals :: PO.Ordering -> PO.Ordering -> Boolean -> Constraint
class Equals lhs rhs out | lhs rhs -> out

instance equalsEQEQ :: Equals PO.EQ PO.EQ True
instance equalsLTLT :: Equals PO.LT PO.LT True
instance equalsGTGT :: Equals PO.GT PO.GT True
instance equalsEQLT :: Equals PO.EQ PO.LT False
instance equalsEQGT :: Equals PO.EQ PO.GT False
instance equalsLTEQ :: Equals PO.LT PO.EQ False
instance equalsLTGT :: Equals PO.LT PO.GT False
instance equalsGTLT :: Equals PO.GT PO.LT False
instance equalsGTEQ :: Equals PO.GT PO.EQ False

equals :: forall l r o. Equals l r o => OProxy l -> OProxy r -> BProxy o
equals _ _ = BProxy
