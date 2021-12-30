#import "Basic";
#import "Math";
#import "Window_Creation";

Simp  :: #import "Simp";
Input :: #import "Input";

KEY_Q :: 81;
KEY_S :: 83;
KEY_W :: 87;

window_width  : s32 : 640;
window_height : s32 : 480;

window : Window_Type;

fade_in_texture  : Simp.Texture;
fade_out_texture : Simp.Texture;

fade_out_path :: "img/fadeout.png";
fade_in_path  :: "img/fadein.png";

main :: () {

    window = create_window(window_width, window_height, "LazyFOO");
    Simp.set_render_target(window);

    success := Simp.texture_load_from_file(*fade_in_texture, fade_in_path);
    assert(success);

    success = Simp.texture_load_from_file(*fade_out_texture, fade_out_path);
    assert(success);

    alpha: u8 = 255;

    quit := false;
    while !quit {
        Input.update_window_events();

        for Input.events_this_frame {
            if it.type == {
              case .QUIT;
                quit = true;
              case .KEYBOARD;
                if !it.key_pressed continue;
                if it.key_code == {
                  case KEY_Q;
                    quit = true;
                 case KEY_W;
                    alpha = ifx alpha >= #run (255 - 32) then 255 else alpha + 32;
                 case KEY_S;
                    alpha = ifx alpha <= 32 then 0 else alpha - 32;
                }
            }
        }

        draw_one_frame(alpha / 255.0);
    }

    sleep_milliseconds(10);
    reset_temporary_storage();
}

draw_one_frame :: (alpha: float) {

    Simp.set_shader_for_images(*fade_in_texture);
    Simp.immediate_begin();

    Simp.immediate_quad(
        xy(0, 0),
        xy(cast(float)window_width, 0),
        xy(cast(float)window_width, cast(float)window_height),
        xy(0, cast(float)window_height),
    );

    Simp.set_shader_for_images(*fade_out_texture);

    Simp.immediate_quad(
        xy(0, 0),
        xy(cast(float)window_width, 0),
        xy(cast(float)window_width, cast(float)window_height),
        xy(0, cast(float)window_height),
        rgba(1, 1, 1, alpha),
    );

    Simp.immediate_flush();

    Simp.swap_buffers(window);
}
