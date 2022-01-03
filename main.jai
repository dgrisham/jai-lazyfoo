#import "Basic";
#import "Math";
#import "Window_Creation";
#import "Time";

Simp  :: #import "Simp";
Input :: #import "Input";

KEY_Q :: 81;

window_width  : s32 : 2560;
window_height : s32 : 1440;

window : Window_Type;

frame := 0;
frame_rate: float64;
frames_between_rate_measurements :: 30;

dot_width  : float : 20;
dot_height : float : 20;

Entity :: struct {
    x, y: float;
    width, height: float;
    colliders: [] Collider;
}

Dot :: struct {
    using entity: Entity;
    width  = dot_width;
    height = dot_height;

    texture: Simp.Texture;
    vx, vy: float;
}

New_Dot :: () -> Dot {
    dot: Dot;

    colliders : [11] Collider : Collider.[
        .{width = 6,  height = 1},
        .{width = 10, height = 1},
        .{width = 14, height = 1},
        .{width = 16, height = 2},
        .{width = 18, height = 2},
        .{width = 20, height = 6},
        .{width = 18, height = 2},
        .{width = 16, height = 2},
        .{width = 14, height = 1},
        .{width = 10, height = 1},
        .{width = 6,  height = 1},
    ];
    dot.colliders = colliders;

    return dot;
}

Wall :: struct {
    using entity: Entity;
    thickness : float : 2;
}

New_Wall :: (width: float, height: float) -> Wall {
    wall: Wall;
    wall.width = width;
    wall.height = height;

    collider: Collider;
    collider.width  = width;
    collider.height = height;

    wall.colliders = NewArray(1, Collider);
    wall.colliders[0] = collider;

    return wall;
}

Collider :: struct {
    width, height: float;
}

main :: () {

    window = create_window(window_width, window_height, "DotManVSWallWoMan");
    Simp.set_render_target(window);

    init_font();

    dot := New_Dot();
    dot.x = cast(float) (window_width / 2);
    dot.y = cast(float) (window_height / 2);
    assert(Simp.texture_load_from_file(*dot.texture, "img/dot.bmp"));

    reset_temporary_storage();

    walls := NewArray(3, Wall);

    walls[0] = New_Wall(cast(float) window_width / 20, cast(float) window_height / 5);
    walls[0].x = window_width  * 7 / 12.0;
    walls[0].y = window_height * 1 / 2.0;

    walls[1] = New_Wall(cast(float) window_width / 10, cast(float) window_height / 20);
    walls[1].x = window_width  * 2 / 12.0;
    walls[1].y = window_height * 1 / 5.0;

    walls[2] = New_Wall(cast(float) window_width / 50, cast(float) window_height - 100);
    walls[2].x = window_width  * 3 / 50.0;
    walls[2].y = 50;

    frame_rate_start := get_current_file_time();
    quit := false;
    while !quit {

        Input.update_window_events();

        for Input.events_this_frame {
            if it.type == {
              case .QUIT;
                quit = true;
                break;

              case .KEYBOARD;
                if it.key_pressed && it.key_code == KEY_Q {
                    quit = true;
                    break it;
                }

                if it.key_code == {
                  case Input.Key_Code.ARROW_UP;
                    dot.vy += ifx it.key_pressed then 10 else -10;
                  case Input.Key_Code.ARROW_DOWN;
                    dot.vy += ifx it.key_pressed then -10 else 10;
                  case Input.Key_Code.ARROW_LEFT;
                    dot.vx += ifx it.key_pressed then -10 else 10;
                  case Input.Key_Code.ARROW_RIGHT;
                    dot.vx += ifx it.key_pressed then 10 else -10;
                }
            }
        }

        check_collision :: (entity_a: Entity, entity_b: Entity) -> Vector2 {

            row_a: float = 0;

            bounce_back := xy(0, 0);
            for collider_a: entity_a.colliders {
                left_a   := entity_a.x + (entity_a.width - collider_a.width) / 2;
                right_a  := left_a + collider_a.width;
                bottom_a := entity_a.y + row_a;
                top_a    := bottom_a + collider_a.height;

                row_a += collider_a.height;

                row_b: float = 0;
                for collider_b: entity_b.colliders {

                    left_b   := entity_b.x;
                    right_b  := left_b + collider_b.width;
                    bottom_b := entity_b.y + row_b;
                    top_b    := bottom_b + collider_b.height;

                    row_b += collider_b.height;

                    if !(right_a  <= left_b   ||
                         left_a   >= right_b  ||
                         top_b    <= bottom_a ||
                         bottom_b >= top_a)
                    { // collision detected
                        bounce_back.x = max(bounce_back.x, min(right_a - left_b, right_b - left_a));
                        bounce_back.y = max(bounce_back.y, min(top_b - bottom_a, top_a - bottom_b));
                    }
                }
            }

            return bounce_back;
        }

        {
            if dot.x + dot.vx >= 0 &&
               dot.x + dot.vx + dot.width <= cast(float)window_width
            {
                dot.x += dot.vx;
                for wall: walls {
                    bounce_back := check_collision(dot, wall);
                    dot.x += ifx dot.vx > 0 then -bounce_back.x else bounce_back.x;
                }
            }
        }

        {
            if dot.y + dot.vy >= 0 &&
               dot.y + dot.vy + dot.height <= cast(float)window_height
            {
                dot.y += dot.vy;
                for wall: walls {
                    bounce_back := check_collision(dot, wall);
                    dot.y += ifx dot.vy > 0 then -bounce_back.y else bounce_back.y;
                }
            }
        }

        draw_one_frame(dot, walls);
        frame += 1;

        if frame % frames_between_rate_measurements == 0 {
            frame_rate_end := get_current_file_time();
            frame_rate = frames_between_rate_measurements * 10000000.0 / (frame_rate_end - frame_rate_start);
            frame_rate_start = frame_rate_end;
        }
    }
}

draw_one_frame :: (dot: Dot, walls: [] Wall) {

    Simp.clear_render_target(1,1,1,1);

    { // draw the frame rate
        time_str := tprint("% fps", formatFloat(frame_rate, 2, 3));
        Simp.draw_text(font, 30, window_height - 50, time_str, rgba(0,0,0,1));
    }

    { // draw the dot
        Simp.set_shader_for_images(*dot.texture);
        Simp.immediate_begin();

        Simp.immediate_quad(
            dot.x, dot.y, dot.x + dot.width, dot.y + dot.height,
            rgba(1,1,1,1),
        );

        Simp.immediate_flush();
    }

    for wall: walls { // draw the wall
        Simp.set_shader_for_color();
        draw_hollow_rectangle(wall.x, wall.y, wall.width, wall.height, wall.thickness, Vector4.{1,1,1,1}, Vector4.{0,0,0,1});
    }

    Simp.swap_buffers(window);
}

font: *Simp.Dynamic_Font;

draw_hollow_rectangle :: inline (x: float, y: float, width: float, height: float, thickness: float, inner_color: Vector4, outer_color: Vector4) {
    Simp.immediate_quad(x, y, x + width, y + height, outer_color);
    Simp.immediate_quad(x + thickness, y + thickness, x + width - thickness, y + height - thickness, inner_color);
}

init_font :: () {
    pixel_height := window_height / 64;
    font = Simp.get_font_at_size(".", "OpenSans-BoldItalic.ttf", pixel_height);
    assert(font != null);
}
