#import "Basic";
#import "Math";
#import "Window_Creation";

Simp  :: #import "Simp";
Input :: #import "Input";

KEY_D :: 68;
KEY_H :: 72;
KEY_I :: 73;
KEY_Q :: 81;
KEY_V :: 86;

window_width  : s32 : 1920;
window_height : s32 : 1080;

arrow_path :: "img/arrow.png";

window : Window_Type;
arrow_texture : Simp.Texture;

main :: () {

    window = create_window(window_width, window_height, "LazyFOO");
    Simp.set_render_target(window);

    success := Simp.texture_load_from_file(*arrow_texture, arrow_path);
    assert(success);

    reset_temporary_storage();

    degrees: float = 0;
    flip_horizontal, flip_vertical := false;
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

                  case KEY_H;
                    flip_horizontal = !flip_horizontal;
                  case KEY_V;
                    flip_vertical = !flip_vertical;

                  case KEY_I;
                    degrees += 45;
                  case KEY_D;
                    degrees -= 45;
                }
            }
        }

        draw_one_frame(degrees * PI / 180, flip_horizontal, flip_vertical);
        sleep_milliseconds(10);
        // assert(context.temporary_storage.occupied == 0);
    }
}

// alpha:           angle to rotate the image CCW in radians
// flip_horizontal: whether to flip the image about the x-axis
// flip_vertical:   whether to flip the image about the y-axis
draw_one_frame :: (alpha: float, mirror_x_axis := false, mirror_y_axis := false) {

    Simp.clear_render_target(0, 0, 0, 1);

    Simp.set_shader_for_images(*arrow_texture);
    Simp.immediate_begin();

    width  := arrow_texture.width  / 2;
    height := arrow_texture.height / 2;

    p: Vector2;
    p.x = cast(float)(window_width  / 2);
    p.y = cast(float)(window_height / 2);

    ca := cos(alpha);
    sa := sin(alpha);

    mirror_x: float = ifx mirror_x_axis then -1.0 else 1.0;
    mirror_y: float = ifx mirror_y_axis then -1.0 else 1.0;

    w := xy(mirror_y * width * ca,   mirror_x * height * sa);
    h := xy(mirror_y * width * sa, - mirror_x * height * ca);

    Simp.immediate_quad(
        p - w - h,
        p + w - h,
        p + w + h,
        p - w + h,
    );

    Simp.immediate_flush();
    Simp.swap_buffers(window);
}
