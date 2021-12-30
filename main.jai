#import "Basic";
#import "Math";
#import "Window_Creation";

Simp  :: #import "Simp";
Input :: #import "Input";

KEY_Q :: 81;
KEY_S :: 83;
KEY_W :: 87;

window_width  : s32 : 1920;
window_height : s32 : 1080;

sprite_sheet_path :: "img/sprite_sheet.png";
sprite_width  :: 64;
sprite_height :: 205;

height_ratio :: (cast(float) sprite_height) / (cast(float) window_height);

window : Window_Type;
sprite_sheet_texture : Simp.Texture;

main :: () {

    window = create_window(window_width, window_height, "LazyFOO");
    Simp.set_render_target(window);

    success := Simp.texture_load_from_file(*sprite_sheet_texture, sprite_sheet_path);
    assert(success);

    reset_temporary_storage();

    sprite_idx := 0;
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
                }
            }
        }

        draw_one_frame(sprite_idx);

        sprite_idx += 1;
        if sprite_idx == 4 sprite_idx = 0;

        sleep_milliseconds(100);
    }
}

draw_one_frame :: (sprite_idx: int) {

    Simp.set_shader_for_images(*sprite_sheet_texture);
    Simp.immediate_begin();

    sprite_start_width  :: cast(float)window_width  / 2 - sprite_width  / 2;
    sprite_start_height :: cast(float)window_height / 2 - sprite_height / 2;
    sprite_end_width    :: cast(float)window_width  / 2 + sprite_width  / 2;
    sprite_end_height   :: cast(float)window_height / 2 + sprite_height / 2;

    Simp.immediate_quad(
        #run Vector2.{sprite_start_width, sprite_start_height},
        #run Vector2.{sprite_end_width,   sprite_start_height},
        #run Vector2.{sprite_end_width,   sprite_end_height},
        #run Vector2.{sprite_start_width, sprite_end_height},
        rgba(1,1,1,1),
        xy(sprite_idx       / 4.0, 0),
        xy((sprite_idx + 1) / 4.0, 0),
        xy((sprite_idx + 1) / 4.0, 1),
        xy(sprite_idx       / 4.0, 1),
    );

    Simp.immediate_flush();
    Simp.swap_buffers(window);
}
