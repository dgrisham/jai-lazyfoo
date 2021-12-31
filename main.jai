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

Dot :: struct {
    texture: Simp.Texture;
    x, y: int;
    vx, vy: int;
}

main :: () {

    window = create_window(window_width, window_height, "DotMan");
    Simp.set_render_target(window);

    init_font();

    dot: Dot;
    dot.x = window_width / 2;
    dot.y = window_height / 2;
    assert(Simp.texture_load_from_file(*dot.texture, "img/dot.bmp"));
    reset_temporary_storage();

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

                if Input.input_button_states[cast(int) Input.Key_Code.ARROW_UP] & Input.Key_Current_State.START {
                    dot.vy += 10;
                } else if Input.input_button_states[cast(int) Input.Key_Code.ARROW_DOWN] & Input.Key_Current_State.START {
                    dot.vy -= 10;
                } else if Input.input_button_states[cast(int) Input.Key_Code.ARROW_LEFT] & Input.Key_Current_State.START {
                    dot.vx -= 10;
                } else if Input.input_button_states[cast(int) Input.Key_Code.ARROW_RIGHT] & Input.Key_Current_State.START {
                    dot.vx += 10;
                } else if Input.input_button_states[cast(int) Input.Key_Code.ARROW_UP] & Input.Key_Current_State.END {
                    dot.vy -= 10;
                } else if Input.input_button_states[cast(int) Input.Key_Code.ARROW_DOWN] & Input.Key_Current_State.END {
                    dot.vy += 10;
                } else if Input.input_button_states[cast(int) Input.Key_Code.ARROW_LEFT] & Input.Key_Current_State.END {
                    dot.vx += 10;
                } else if Input.input_button_states[cast(int) Input.Key_Code.ARROW_RIGHT] & Input.Key_Current_State.END {
                    dot.vx -= 10;
                }
            }
        }

        dot.x = ifx dot.x + dot.vx < 0 || dot.x + dot.vx > window_width  then dot.x else dot.x + dot.vx;
        dot.y = ifx dot.y + dot.vy < 0 || dot.y + dot.vy > window_height then dot.y else dot.y + dot.vy;

        draw_one_frame(dot);
        frame += 1;

        if frame % frames_between_rate_measurements == 0 {
            frame_rate_end := get_current_file_time();
            frame_rate = frames_between_rate_measurements * 10000000.0 / (frame_rate_end - frame_rate_start);
            frame_rate_start = frame_rate_end;
        }
    }
}

draw_one_frame :: (dot: Dot) {

    Simp.clear_render_target(1,1,1,1);

    { // draw the frame rate
        time_str := tprint("% fps", formatFloat(frame_rate, 2, 3));
        Simp.draw_text(font, 30, window_height - 50, time_str, rgba(0,0,0,1));
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

init_font :: () {
    pixel_height := window_height / 64;
    font = Simp.get_font_at_size(".", "OpenSans-BoldItalic.ttf", pixel_height);
    assert(font != null);
}
