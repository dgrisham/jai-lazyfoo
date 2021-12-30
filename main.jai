#import "Basic";
#import "Math";
#import "Window_Creation";

Simp  :: #import "Simp";
Input :: #import "Input";

buttons_file :: "img/button.png";

KEY_Q :: 81;

window_width  : s32 : 2560;
window_height : s32 : 1280;

button_width  : float : 300;
button_height : float : 200;

window : Window_Type;

buttons_texture: Simp.Texture;

L_Button_Sprite :: enum u8 {
    BUTTON_SPRITE_MOUSE_OUT;
    BUTTON_SPRITE_MOUSE_OVER_MOTION;
    BUTTON_SPRITE_MOUSE_DOWN;
    BUTTON_SPRITE_MOUSE_UP;
}

NUM_BUTTONS :: #run type_info(L_Button_Sprite).names.count;
buttons: [NUM_BUTTONS] L_Button = .[
    .{ top_left = .{window_width / 2.0 - button_width, window_height / 2.0 - button_height} },
    .{ top_left = .{window_width / 2.0               , window_height / 2.0 - button_height} },
    .{ top_left = .{window_width / 2.0 - button_width, window_height / 2.0                } },
    .{ top_left = .{window_width / 2.0               , window_height / 2.0                } },
];

L_Button :: struct {
    top_left: Vector2;
    currentSprite: L_Button_Sprite = .BUTTON_SPRITE_MOUSE_OUT;
    mouse_inside := false;
}

main :: () {

    window = create_window(window_width, window_height, "LazyFOO");
    Simp.set_render_target(window);

    success := Simp.texture_load_from_file(*buttons_texture, buttons_file);
    assert(success);

    reset_temporary_storage();

    mouse_x, mouse_y: int;
    mouse_x, mouse_y, success = get_mouse_pointer_position(window, true);
    assert(success);
    mouse_moved := false;

    quit := false;
    frame := 0;
    while !quit {
        Input.update_window_events();

        // we don't get a mouse motion event from OpenGL, so we check it ourselves
        x, y := get_mouse_pointer_position(window, true);
        mouse_moved = mouse_x != x || mouse_y != y;
        mouse_x, mouse_y = x, y;

        for *button: buttons {
            inside := true;

            x_float := cast(float) mouse_x;
            y_float := cast(float) mouse_y;
            if x_float < button.top_left.x {
                inside = false;
            } else if x_float > button.top_left.x + button_width {
                inside = false;
            } else if y_float < button.top_left.y {
                inside = false;
            } else if y_float > button.top_left.y + button_height {
                inside = false;
            }
            button.mouse_inside = inside;

            if !button.mouse_inside button.currentSprite = .BUTTON_SPRITE_MOUSE_OUT;

            for Input.events_this_frame {
                if it.type == {

                  case .QUIT;
                    quit = true;
                    break button;

                  case .KEYBOARD;
                    if it.key_pressed && it.key_code == KEY_Q {
                        quit = true;
                        break button;
                    }

                    if it.key_code == .MOUSE_BUTTON_LEFT && button.mouse_inside {
                        if it.key_pressed  button.currentSprite = .BUTTON_SPRITE_MOUSE_DOWN;
                        else               button.currentSprite = .BUTTON_SPRITE_MOUSE_UP;
                    }
                }
            }

            if mouse_moved && button.mouse_inside
                button.currentSprite = .BUTTON_SPRITE_MOUSE_OVER_MOTION;
        }

        draw_one_frame();
        frame += 1;
    }
}

draw_one_frame :: () {

    Simp.clear_render_target(0, 0, 0, 1);

    for *button: buttons {
        if button.mouse_inside && button.currentSprite == .BUTTON_SPRITE_MOUSE_OUT {
            button.currentSprite = .BUTTON_SPRITE_MOUSE_OVER_MOTION;
        }
        render_button(<<button);
    }

    Simp.swap_buffers(window);
}

render_button :: (using button: L_Button) {

    num_buttons :: #run cast(float) NUM_BUTTONS;

    Simp.set_shader_for_images(*buttons_texture);
    Simp.immediate_begin();

    sprite_idx := cast(int) button.currentSprite;
    Simp.immediate_quad(
        top_left,
        top_left + xy(button_width, 0),
        top_left + xy(button_width, button_height),
        top_left + xy(0,            button_height),
        rgba(1, 1, 1, 1),
        xy(0, (NUM_BUTTONS - sprite_idx - 1) / num_buttons),
        xy(1, (NUM_BUTTONS - sprite_idx - 1) / num_buttons),
        xy(1, (NUM_BUTTONS - sprite_idx)     / num_buttons),
        xy(0, (NUM_BUTTONS - sprite_idx)     / num_buttons),
    );

    Simp.immediate_flush();
}
