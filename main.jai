#import "Basic";
#import "Math";
#import "Window_Creation";
#import "Time";

Simp  :: #import "Simp";
Input :: #import "Input";

KEY_Q :: 81;

camera_width  : int : 960;
camera_height : int : 540;

map_width  : float : 1920;
map_height : float : 1080;

window : Window_Type;

frame := 0;
frame_rate: float64;
frames_between_rate_measurements :: 30;

Camera :: struct {
    x, y: float;
    width  :: camera_width;
    height :: camera_height;
}

map_texture : *Simp.Texture;

dot_width   : float : 20;
dot_height  : float : 20;
dot_texture : *Simp.Texture;

dot_speed : float : 5;

Dot :: struct {
    width  := dot_width;
    height := dot_height;
    r := dot_width / 2;

    x, y: float;
    vx, vy: float;

    texture: Simp.Texture;
}

NewDot :: (x: float, y: float) -> Dot {
    dot: Dot;
    dot.x = x;
    dot.y = y;

    assert(dot_texture != null);
    dot.texture = <<dot_texture;

    return dot;
}

main :: () {

    init_font();

    camera: Camera;
    camera.x = map_width  / 2 - camera.width  / 2.0;
    camera.y = map_height / 2 - camera.height / 2.0;

    window = create_window(camera.width, camera.height, "DotManVSOTHERDotMansAndWallWoMans");
    Simp.set_render_target(window);

    {
        dot_texture = New(Simp.Texture);
        assert(Simp.texture_load_from_file(dot_texture, "img/dot.bmp"));

        map_texture = New(Simp.Texture);
        assert(Simp.texture_load_from_file(map_texture, "img/bg.png"));

        reset_temporary_storage();
    }

    dot := NewDot(camera_width / 2.0, camera_height / 2.0);

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
                    dot.vy += ifx it.key_pressed then dot_speed else -dot_speed;
                  case Input.Key_Code.ARROW_DOWN;
                    dot.vy += ifx it.key_pressed then -dot_speed else dot_speed;
                  case Input.Key_Code.ARROW_LEFT;
                    dot.vx += ifx it.key_pressed then -dot_speed else dot_speed;
                  case Input.Key_Code.ARROW_RIGHT;
                    dot.vx += ifx it.key_pressed then dot_speed else -dot_speed;
                }
            }
        }

        if dot.vx != 0 &&
           dot.x + dot.vx >= 0 &&
           dot.x + dot.vx + dot.width <= cast(float) map_width
        {
            dot.x += dot.vx;
        }

        if dot.vy != 0 &&
           dot.y + dot.vy >= 0 &&
           dot.y + dot.vy + dot.height <= cast(float) map_height
        {
            dot.y += dot.vy;
        }

        camera.x = min(max(0.0, dot.x + dot.width / 2.0 - camera.width  / 2.0), map_width  - camera.width);
        camera.y = min(max(0.0, dot.y + dot.width / 2.0 - camera.height / 2.0), map_height - camera.height);

        draw_one_frame(camera, dot);
        frame += 1;

        if frame % frames_between_rate_measurements == 0 {
            frame_rate_end := get_current_file_time();
            frame_rate = frames_between_rate_measurements * 10000000.0 / (frame_rate_end - frame_rate_start);
            frame_rate_start = frame_rate_end;
        }
    }
}

draw_one_frame :: (camera: Camera, dot: Dot) {

    Simp.clear_render_target(1,1,1,1);
    Simp.immediate_begin();

    {
        Simp.set_shader_for_images(map_texture);
        Simp.immediate_quad(
            .{0                       , 0},
            .{cast(float) camera_width, 0},
            .{cast(float) camera_width, cast(float) camera_height},
            .{0                       , cast(float) camera_height},
            rgba(1,1,1,1),
            xy(camera.x / map_width                 , camera.y / map_height),
            xy((camera.x + camera.width) / map_width, camera.y / map_height),
            xy((camera.x + camera.width) / map_width, (camera.y + camera.height) / map_height),
            xy(camera.x / map_width                 , (camera.y + camera.height) / map_height),
        );
    }

    { // draw the frame rate
        time_str := tprint("% fps", formatFloat(frame_rate, 2, 3));
        Simp.draw_text(font, 30, camera.height - 50, time_str, rgba(0,0,0,1)); // TODO: update for camera
    }

    { // draw the dot
        Simp.set_shader_for_images(dot_texture);
        Simp.immediate_quad(
            dot.x - camera.x, dot.y - camera.y, dot.x + dot.width - camera.x, dot.y + dot.height - camera.y,
            rgba(1,1,1,1),
        );
    }

    Simp.immediate_flush();
    Simp.swap_buffers(window);
}

font: *Simp.Dynamic_Font;

init_font :: () {
    pixel_height := camera_height / 32;
    font = Simp.get_font_at_size(".", "OpenSans-BoldItalic.ttf", pixel_height);
    assert(font != null);
}
