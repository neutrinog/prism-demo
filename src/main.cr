require "prism"
require "./game"

#  Example creating a window
engine = CoreEngine.new(800, 600, 60.0, "3D Game Engine", TestGame.new())
engine.start
