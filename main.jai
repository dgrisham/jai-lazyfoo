#import "Basic";
#import "Math";
#import "Window_Creation";

Simp  :: #import "Simp";
Input :: #import "Input";

KEY_Q :: 81;

window_width  : s32 : 2560;
window_height : s32 : 1280;

window : Window_Type;

textures: struct {
    press: Simp.Texture;
    up: Simp.Texture;
    down: Simp.Texture;
    left: Simp.Texture;
    right: Simp.Texture;
}

current_texture: *Simp.Texture;

main :: () {

    window = create_window(window_width, window_height, "LazyFOO");
    Simp.set_render_target(window);

    assert(Simp.texture_load_from_file(*textures.press, "img/press.png")
        && Simp.texture_load_from_file(*textures.up,    "img/up.png")
        && Simp.texture_load_from_file(*textures.down,  "img/down.png")
        && Simp.texture_load_from_file(*textures.left,  "img/left.png")
        && Simp.texture_load_from_file(*textures.right, "img/right.png")
    );
    reset_temporary_storage();

    current_texture = *textures.press;

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
    }
}

draw_one_frame :: () {

    Simp.clear_render_target(0, 0, 0, 1);

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
