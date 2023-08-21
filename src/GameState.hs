-- |
-- This module defines the logic of the game and the communication with the `Board.RenderState`
module GameState where

-- These are all the import. Feel free to use more if needed.

import Data.Maybe (isJust)
import Data.Sequence (Seq (..))
import qualified Data.Sequence as S
import RenderState (BoardInfo (..), DeltaBoard, Point)
import qualified RenderState as Board
import System.Random (Random (randomR), RandomGen (split), StdGen, uniformR)

-- The movement is one of this.
data Movement = North | South | East | West deriving (Show, Eq)

-- | The snakeSeq is a non-empty sequence. It is important to use precise types in Haskell
--   In first sight we'd define the snake as a sequence, but If you think carefully, an empty
--   sequence can't represent a valid Snake, therefore we must use a non empty one.
--   You should investigate about Seq type in haskell and we it is a good option for our porpouse.
data SnakeSeq = SnakeSeq {snakeHead :: Point, snakeBody :: Seq Point} deriving (Show, Eq)

-- | The GameState represents all important bits in the game. The Snake, The apple, the current direction of movement and
--   a random seed to calculate the next random apple.
data GameState = GameState
  { snakeSeq :: SnakeSeq,
    applePosition :: Point,
    movement :: Movement,
    randomGen :: StdGen
  }
  deriving (Show, Eq)

-- | This function should calculate the opposite movement.
opositeMovement :: Movement -> Movement
opositeMovement mv =
  case mv of
    North -> South
    South -> North
    East -> West
    West -> East

-- >>> opositeMovement North == South
-- >>> opositeMovement South == North
-- >>> opositeMovement East == West
-- >>> opositeMovement West == East

-- | Purely creates a random point within the board limits
--   You should take a look to System.Random documentation.
--   Also, in the import list you have all relevant functions.
makeRandomPoint :: BoardInfo -> StdGen -> (Point, StdGen)
makeRandomPoint bi =
  let h = height bi
      w = width bi
   in randomR ((h, w), (h, w))

{-
We can't test makeRandomPoint, because different implementation may lead to different valid result.
-}

-- | Check if a point is in the snake
inSnake :: Point -> SnakeSeq -> Bool
inSnake p ss =
  p == snakeHead ss || p `elem` snakeBody ss

{-
This is a test for inSnake. It should return
True
True
False
-}
-- >>> snake_seq = SnakeSeq (1,1) (Data.Sequence.fromList [(1,2), (1,3)])
-- >>> inSnake (1,1) snake_seq
-- >>> inSnake (1,2) snake_seq
-- >>> inSnake (1,4) snake_seq
-- True
-- True
-- False

-- | Calculates de new head of the snake. Considering it is moving in the current direction
--   Take into acount the edges of the board
nextHead :: BoardInfo -> GameState -> Point
nextHead bi gs =
  let head_pos = snakeHead $ snakeSeq gs
   in if atWall head_pos (movement gs) bi
        then head_pos
        else advancePoint head_pos (movement gs)


atWall :: Point -> Movement -> BoardInfo -> Bool
atWall p mv bi =
  let target = advancePoint p mv
      i = fst target
      j = snd target
   in (i >= height bi || j >= width bi) || (i == 0 || j == 0)

advancePoint :: Point -> Movement -> BoardInfo -> Point
advancePoint p mv bi =
  case mv of
    North -> (determineWrap $ fst p - 1 (height bi), snd p) -- top left corner is 1,1
    South -> (determineWrap $ fst p + 1 (height bi), snd p)
    East -> (fst p, determineWrap snd p + 1 (width bi))
    West -> (fst p, determineWrap snd p - 1 (width bi), a)

determineWrap :: Int -> Int -> Int
determineWrap coord max =
  if coord == 0 then max
  else if coord == max + 1
  then 1

{-
This is a test for nextHead. It should return
True
True
True
-}
-- >>> snake_seq = SnakeSeq (1,1) (Data.Sequence.fromList [(1,2), (1,3)])
-- >>> apple_pos = (2,2)
-- >>> board_info = BoardInfo 4 4
-- >>> game_state1 = GameState snake_seq apple_pos West (System.Random.mkStdGen 1)
-- >>> game_state2 = GameState snake_seq apple_pos South (System.Random.mkStdGen 1)
-- >>> game_state3 = GameState snake_seq apple_pos North (System.Random.mkStdGen 1)
-- >>> snake_head = snakeHead snake_seq
-- >>> snake_head
-- >>> mvmt = West
-- >>> advancePoint snake_head mvmt
-- >>> atWall snake_head mvmt board_info
-- >>> nextHead board_info game_state1
-- >>> nextHead board_info game_state1 -- == (1,4)
-- >>> nextHead board_info game_state2 -- == (2,1)
-- >>> nextHead board_info game_state3 -- == (4,1)
-- (1,1)
-- (1,0)
-- True
-- (1,1)
-- (1,1)
-- (2,1)
-- (1,1)

-- | Calculates a new random apple, avoiding creating the apple in the same place, or in the snake body
newApple :: BoardInfo -> GameState -> (Point, StdGen)
newApple = undefined

{- We can't test this function because it depends on makeRandomPoint -}

-- | Moves the snake based on the current direction. It sends the adequate RenderMessage
-- Notice that a delta board must include all modified cells in the movement.
-- For example, if we move between this two steps
--        - - - -          - - - -
--        - 0 $ -    =>    - - 0 $
--        - - - -    =>    - - - -
--        - - - X          - - - X
-- We need to send the following delta: [((2,2), Empty), ((2,3), Snake), ((2,4), SnakeHead)]
--
-- Another example, if we move between this two steps
--        - - - -          - - - -
--        - - - -    =>    - X - -
--        - - - -    =>    - - - -
--        - 0 $ X          - 0 0 $
-- We need to send the following delta: [((2,2), Apple), ((4,3), Snake), ((4,4), SnakeHead)]
move :: BoardInfo -> GameState -> (Board.RenderMessage, GameState)
move = undefined

{- This is a test for move. It should return

RenderBoard [((1,4),SnakeHead),((1,1),Snake),((1,3),Empty)]
RenderBoard [((2,1),SnakeHead),((1,1),Snake),((3,1),Apple)] ** your Apple might be different from mine
RenderBoard [((4,1),SnakeHead),((1,1),Snake),((1,3),Empty)]

-}

-- >>> snake_seq = SnakeSeq (1,1) (Data.Sequence.fromList [(1,2), (1,3)])
-- >>> apple_pos = (2,1)
-- >>> board_info = BoardInfo 4 4
-- >>> game_state1 = GameState snake_seq apple_pos West (System.Random.mkStdGen 1)
-- >>> game_state2 = GameState snake_seq apple_pos South (System.Random.mkStdGen 1)
-- >>> game_state3 = GameState snake_seq apple_pos North (System.Random.mkStdGen 1)
-- >>> fst $ move board_info game_state1
-- >>> fst $ move board_info game_state2
-- >>> fst $ move board_info game_state3
