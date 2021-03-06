require "prism"
require "./tween.cr"
require "./obstacle.cr"

include Prism

class Door < GameComponent
    include Obstacle

    START = 0f32
    LENGTH = 1f32
    WIDTH = 0.125f32
    HEIGHT = 1f32
    TIME_TO_OPEN = 1f32
    CLOSE_DELAY = 2.0f32
    SIZE = Vector3f.new(LENGTH, HEIGHT, WIDTH)

    @@mesh : Mesh?

    @material : Material
    @is_opening : Bool
    @is_closing : Bool
    @close_position : Vector3f?
    @open_position: Vector3f?
    @open_movement : Vector3f
    @tween : Tween?
    @time_opened : Float32

    def initialize(@material, @open_movement)
        @is_opening = false
        @is_closing = false
        @time_opened = 0

        if @@mesh == nil
            # create new mesh

            spritemap = Spritemap.new(4, 4)
            face = spritemap.get(0, 2)

            # NOTE: add top and bottom face if you need hight less than 1
            verticies = [
                Vertex.new(Vector3f.new(START, START, START), face[:bottom_right]),
                Vertex.new(Vector3f.new(START, HEIGHT, START), face[:top_right]),
                Vertex.new(Vector3f.new(LENGTH, HEIGHT, START), face[:top_left]),
                Vertex.new(Vector3f.new(LENGTH, START, START), face[:bottom_left]),

                Vertex.new(Vector3f.new(START, START, START), Vector2f.new(0.73, 1)),
                Vertex.new(Vector3f.new(START, HEIGHT, START), Vector2f.new(0.73, 0.75)),
                Vertex.new(Vector3f.new(START, HEIGHT, WIDTH), Vector2f.new(0.75, 0.75)),
                Vertex.new(Vector3f.new(START, START, WIDTH), Vector2f.new(0.75, 1)),

                Vertex.new(Vector3f.new(START, START, WIDTH), face[:bottom_right]),
                Vertex.new(Vector3f.new(START, HEIGHT, WIDTH), face[:top_right]),
                Vertex.new(Vector3f.new(LENGTH, HEIGHT, WIDTH), face[:top_left]),
                Vertex.new(Vector3f.new(LENGTH, START, WIDTH), face[:bottom_left]),

                Vertex.new(Vector3f.new(LENGTH, START, START), Vector2f.new(0.73, 1)),
                Vertex.new(Vector3f.new(LENGTH, HEIGHT, START), Vector2f.new(0.73, 0.75)),
                Vertex.new(Vector3f.new(LENGTH, HEIGHT, WIDTH), Vector2f.new(0.75, 0.75)),
                Vertex.new(Vector3f.new(LENGTH, START, WIDTH), Vector2f.new(0.75, 1))
            ]
            indicies = [
                0, 1, 2,
                0, 2, 3,

                6, 5, 4,
                7, 6, 4,

                10, 9, 8,
                11, 10, 8,

                12, 13, 14,
                12, 14, 15
            ]
            @@mesh = Mesh.new(verticies, indicies, true)
        end
    end

    def position : Prism::Vector3f
        self.transform.pos
    end

    def size : Prism::Vector3f
        SIZE.rotate(self.transform.rot)
    end

    # Returns or generates the door tween
    private def get_tween(delta : Float32, key_frame_time : Float32) : Tween
        if tween = @tween
            return tween
        else
            tween = Tween.new(delta, key_frame_time)
            @tween = tween
            return tween
        end
    end

    # Resets the tween progress to the beginning
    private def reset_tween
        if tween = @tween
            tween.reset
        end
    end

    private def get_open_position : Vector3f
        if position = @open_position
            return position
        else
            position = self.transform.pos - @open_movement
            @open_position = position
            return position
        end
    end

    private def get_close_position : Vector3f
        if position = @close_position
            return position
        else
            position = self.transform.pos
            @close_position = position
            return position
        end
    end

    # Opens the door
    def open
        return if @is_opening || @is_closing
        reset_tween
        @is_opening = true
        @is_closing = false
        @time_opened = 0
    end

    def input(delta : Float32, input : Input)
    end

    def update(delta : Float32)
        close_position = self.get_close_position
        open_position = self.get_open_position

        if @is_opening
            tween = get_tween(delta, TIME_TO_OPEN)
            lerp_factor = tween.step
            self.transform.pos = self.transform.pos.lerp(open_position, lerp_factor)
            if lerp_factor == 1
                reset_tween
                @is_opening = false
                @is_closing = true
            end
        elsif @is_closing
            @time_opened += delta
            if @time_opened >= CLOSE_DELAY
                tween = get_tween(delta, TIME_TO_OPEN)
                lerp_factor = tween.step
                self.transform.pos = self.transform.pos.lerp(close_position, lerp_factor)
                if lerp_factor == 1
                    @is_closing = false
                end
            end
        end
    end

    def render(shader : Shader, rendering_engine : RenderingEngineProtocol)
        if mesh = @@mesh
            shader.bind
            shader.update_uniforms(self.transform, @material, rendering_engine)
            mesh.draw
        else
            puts "Error: The door mesh has not been created"
            exit 1
        end
    end

end
