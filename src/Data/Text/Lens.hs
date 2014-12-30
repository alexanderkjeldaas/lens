{-# LANGUAGE CPP #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TypeSynonymInstances #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Data.Text.Lens
-- Copyright   :  (C) 2012-14 Edward Kmett
-- License     :  BSD-style (see the file LICENSE)
-- Maintainer  :  Edward Kmett <ekmett@gmail.com>
-- Stability   :  experimental
-- Portability :  non-portable
--
----------------------------------------------------------------------------
module Data.Text.Lens
  ( IsText(..)
  , unpacked
  , _Text
  ) where

import           Control.Lens
import           Data.Text as Strict
import qualified Data.Text.Strict.Lens as Strict
import           Data.Text.Lazy as Lazy
import qualified Data.Text.Lazy.Lens as Lazy
import           Data.Text.Lazy.Builder

-- | Traversals for strict or lazy 'Text'
class IsText t where
  -- | This isomorphism can be used to 'pack' (or 'unpack') strict or lazy 'Text'.
  --
  -- @
  -- 'pack' x ≡ x '^.' 'packed'
  -- 'unpack' x ≡ x '^.' 'from' 'packed'
  -- 'packed' ≡ 'from' 'unpacked'
  -- @
  packed :: Iso' String t

  -- | Convert between strict or lazy 'Text' and a 'Builder'.
  --
  -- @
  -- 'fromText' x ≡ x '^.' 'builder'
  -- @
  builder :: Iso' t Builder

  -- | Traverse the individual characters in strict or lazy 'Text'.
  --
  -- @
  -- 'text' = 'unpacked' . 'traversed'
  -- @
  text :: IndexedTraversal' Int t Char
  text = unpacked . traversed
  {-# INLINE text #-}

instance IsText String where
  packed = id
  {-# INLINE packed #-}
  text = indexing traverse
  {-# INLINE text #-}
  builder = Lazy.packed . builder
  {-# INLINE builder #-}

-- | This isomorphism can be used to 'unpack' (or 'pack') both strict or lazy 'Text'.
--
-- @
-- 'unpack' x ≡ x '^.' 'unpacked'
-- 'pack' x ≡ x '^.' 'from' 'unpacked'
-- @
--
-- This 'Iso' is provided for notational convenience rather than out of great need, since
--
-- @
-- 'unpacked' ≡ 'from' 'packed'
-- @
--
unpacked :: IsText t => Iso' t String
unpacked = from packed
{-# INLINE unpacked #-}

-- | This is an alias for 'unpacked' that makes it clearer how to use it with @('#')@.
--
-- @
-- '_Text' = 'from' 'packed'
-- @
--
-- >>> _Text # "hello" :: Strict.Text
-- "hello"
_Text :: IsText t => Iso' t String
_Text = from packed
{-# INLINE _Text #-}

instance IsText Strict.Text where
  packed = Strict.packed
  {-# INLINE packed #-}
  builder = Strict.builder
  {-# INLINE builder #-}
  text = Strict.text
  {-# INLINE text #-}

instance IsText Lazy.Text where
  packed = Lazy.packed
  {-# INLINE packed #-}
  builder = Lazy.builder
  {-# INLINE builder #-}
  text = Lazy.text
  {-# INLINE text #-}
