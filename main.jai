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

textures: struct {
    press: Simp.Texture;
    up: Simp.Texture;
    down: Simp.Texture;
    left: Simp.Texture;
    right: Simp.Texture;
}

current_texture: *Simp.Texture;

frame := 0;
frame_rate: float64;
frames_to_wait :: 30;

main :: () {

    window = create_window(window_width, window_height, "LazyFOO");
    Simp.set_render_target(window);

    init_font();

    assert(Simp.texture_load_from_file(*textures.press, "img/press.png")
        && Simp.texture_load_from_file(*textures.up,    "img/up.png")
        && Simp.texture_load_from_file(*textures.down,  "img/down.png")
        && Simp.texture_load_from_file(*textures.left,  "img/left.png")
        && Simp.texture_load_from_file(*textures.right, "img/right.png")
    );
    reset_temporary_storage();

    current_texture = *textures.press;

    framerate_measurement_start := get_current_file_time();
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
                    break;
                }

                if Input.input_button_states[cast(int) Input.Key_Code.ARROW_UP] & Input.Key_Current_State.DOWN {
                    current_texture = *textures.up;
                } else if Input.input_button_states[cast(int) Input.Key_Code.ARROW_DOWN] & Input.Key_Current_State.DOWN {
                    current_texture = *textures.down;
                } else if Input.input_button_states[cast(int) Input.Key_Code.ARROW_LEFT] & Input.Key_Current_State.DOWN {
                    current_texture = *textures.left;
                } else if Input.input_button_states[cast(int) Input.Key_Code.ARROW_RIGHT] & Input.Key_Current_State.DOWN {
                    current_texture = *textures.right;
                } else {
                    current_texture = *textures.press;
                }
            }
        }

        draw_one_frame();
        frame += 1;
        if frame % frames_to_wait == 0 {
            framerate_measurement_stop := get_current_file_time();
            frame_rate = frames_to_wait * 10000000.0 / (framerate_measurement_stop - framerate_measurement_start);
            framerate_measurement_start = framerate_measurement_stop;
        }
    }
}

draw_one_frame :: () {

    Simp.clear_render_target(0, 0, 0, 1);

    time_str := tprint("% fps", frame_rate);
    Simp.draw_text(font, 30, window_height - 90, time_str);

    Simp.set_shader_for_images(current_texture);
    Simp.immediate_begin();

    top_left := xy(
        window_width / 2.0 - current_texture.width / 2.0,
        window_height / 2.0 - current_texture.height / 2.0,
    );
    texture_width := cast(float) current_texture.width;
    texture_height := cast(float) current_texture.height;
    Simp.immediate_quad(
        top_left,
        top_left + xy(texture_width, 0),
        top_left + xy(texture_width, texture_height),
        top_left + xy(0, texture_height),
        rgba(1, 1, 1, 1),
    );

    Simp.immediate_flush();

    Simp.swap_buffers(window);
}

font: *Simp.Dynamic_Font;

init_font :: () {
    pixel_height := window_height / 48;
    font = Simp.get_font_at_size(".", "OpenSans-BoldItalic.ttf", pixel_height);
    assert(font != null);
}
