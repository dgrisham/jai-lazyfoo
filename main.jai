#import "Basic";
#import "Math";
#import "Window_Creation";
#import "Time";

Simp  :: #import "Simp";
Input :: #import "Input";

KEY_Q :: 81;

window_width  : s32 : 1920;
window_height : s32 : 1080;

window : Window_Type;

frame := 0;
frame_rate: float64;
frames_between_rate_measurements :: 30;

Dot :: struct {
    texture: Simp.Texture;
    x, y: int;
    vx, vy: int;
}

Wall :: struct {
    x, y: float;
    width, height: float;
    thickness: float;
}

main :: () {

    window = create_window(window_width, window_height, "DotManVSWallWoMan");
    Simp.set_render_target(window);

    init_font();

    dot: Dot;
    dot.x = window_width / 2;
    dot.y = window_height / 2;
    assert(Simp.texture_load_from_file(*dot.texture, "img/dot.bmp"));

    reset_temporary_storage();

    wall: Wall;
    wall.x = window_width * 7 / 12.0;
    wall.y = window_height * 1 / 2.0;
    wall.width = window_width / 20.0;
    wall.height = window_height / 5.0;
    wall.thickness = 2.0;

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

        can_move_x :: inline (x: int, wall: Wall) -> bool {
            return x >= 0 && x <= window_width;
        }
        can_move_y :: inline (y: int, wall: Wall) -> bool {
            return y >= 0 && y <= window_height;
        }

        if can_move_x(dot.x + dot.vx, wall) dot.x += dot.vx;
        if can_move_y(dot.y + dot.vy, wall) dot.y += dot.vy;

        draw_one_frame(dot, wall);
        frame += 1;

        if frame % frames_between_rate_measurements == 0 {
            frame_rate_end := get_current_file_time();
            frame_rate = frames_between_rate_measurements * 10000000.0 / (frame_rate_end - frame_rate_start);
            frame_rate_start = frame_rate_end;
        }
    }
}

draw_one_frame :: (dot: Dot, wall: Wall) {

    Simp.clear_render_target(1,1,1,1);

    { // draw the frame rate
        time_str := tprint("% fps", formatFloat(frame_rate, 2, 3));
        Simp.draw_text(font, 30, window_height - 50, time_str, rgba(0,0,0,1));
    }

    { // draw the wall
        Simp.set_shader_for_color();
        draw_hollow_rectangle(wall.x, wall.y, wall.width, wall.height, wall.thickness, Vector4.{1,1,1,1}, Vector4.{0,0,0,1});
    }

    { // draw the dot
        Simp.set_shader_for_images(*dot.texture);
        Simp.immediate_begin();

        Simp.immediate_quad(
            dot.x - dot.texture.width / 2.0, dot.y - dot.texture.height / 2.0,
            dot.x + dot.texture.width / 2.0, dot.y + dot.texture.height / 2.0,
            rgba(1,1,1,1),
        );

        Simp.immediate_flush();
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
