#import "Basic";
#import "SDL";
#import "SDL_image";

SCREEN_WIDTH  :: 640;
SCREEN_HEIGHT :: 480;

gWindow           : *SDL_Window;
gScreenSurface    : *SDL_Surface;
gStretchedSurface : *SDL_Surface;
gKeyPressSurfaces : [Key_Press_Surfaces.KEY_PRESS_SURFACE_TOTAL] *SDL_Surface;

Key_Press_Surfaces :: enum u32 {
    KEY_PRESS_SURFACE_DEFAULT;
    KEY_PRESS_SURFACE_UP;
    KEY_PRESS_SURFACE_DOWN;
    KEY_PRESS_SURFACE_LEFT;
    KEY_PRESS_SURFACE_RIGHT;
    KEY_PRESS_SURFACE_STRETCH;
    KEY_PRESS_SURFACE_TOTAL;
}

main :: () {

    if !init() {
        print("Initialization failed!\n");
    } else {
        if !loadMedia() {
            print("Failed to load media!\n");
        } else {

            gStretchedSurface = gKeyPressSurfaces[Key_Press_Surfaces.KEY_PRESS_SURFACE_DEFAULT];

            stretchRect := SDL_Rect.{ x = 0, y = 0, w = SCREEN_WIDTH, h = SCREEN_HEIGHT };
            SDL_BlitScaled(gStretchedSurface, null, gScreenSurface, *stretchRect);
            SDL_UpdateWindowSurface(gWindow);

            quit := false;
            e : SDL_Event;
            while !quit {
                while SDL_PollEvent(*e) {
                    if e.type == SDL_QUIT {
                        quit = true;
                    } else if e.type == SDL_KEYDOWN {

                        if e.key.keysym.sym == {
                            case SDLK_UP;
                                gStretchedSurface = gKeyPressSurfaces[Key_Press_Surfaces.KEY_PRESS_SURFACE_UP];
                            case SDLK_DOWN;
                                gStretchedSurface = gKeyPressSurfaces[Key_Press_Surfaces.KEY_PRESS_SURFACE_DOWN];
                            case SDLK_LEFT;
                                gStretchedSurface = gKeyPressSurfaces[Key_Press_Surfaces.KEY_PRESS_SURFACE_LEFT];
                            case SDLK_RIGHT;
                                gStretchedSurface = gKeyPressSurfaces[Key_Press_Surfaces.KEY_PRESS_SURFACE_RIGHT];
                            case SDLK_s;
                                gStretchedSurface = gKeyPressSurfaces[Key_Press_Surfaces.KEY_PRESS_SURFACE_STRETCH];
                            case;
                                gStretchedSurface = gKeyPressSurfaces[Key_Press_Surfaces.KEY_PRESS_SURFACE_DEFAULT];
                        }

                        // stretchRect := SDL_Rect.{ x = 0, y = 0, w = SCREEN_WIDTH, h = SCREEN_HEIGHT };
                        SDL_BlitScaled(gStretchedSurface, null, gScreenSurface, *stretchRect);
                        SDL_UpdateWindowSurface(gWindow);
                    }
                }
            }
        }
    }

    close();
}

init :: () -> bool {

    success := true;

    if SDL_Init(SDL_INIT_VIDEO) < 0 {
        print("SDL failed to initialize: %\n", SDL_GetError());
        success = false;
    } else {
        gWindow = SDL_CreateWindow("SDL TutTut", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_SHOWN);
        if !gWindow {
            print("Failed to create gWindow: %\n", SDL_GetError());
            success = false;
        } else {
            if !(IMG_Init(IMG_INIT_PNG) & cast(u32)IMG_INIT_PNG) {
                print("THERE");
                print("Failed to initialize SDL_image: %s\n", IMG_GetError());
                success = false;
            }
            gScreenSurface = SDL_GetWindowSurface(gWindow);
        }
    }

    return success;
}

loadMedia :: () -> bool {
    success := true;

    gKeyPressSurfaces[Key_Press_Surfaces.KEY_PRESS_SURFACE_DEFAULT] = loadSurface("img/press.bmp");
    if !gKeyPressSurfaces[Key_Press_Surfaces.KEY_PRESS_SURFACE_DEFAULT] {
        print("Failed to load default image!\n");
        success = false;
    }

    gKeyPressSurfaces[Key_Press_Surfaces.KEY_PRESS_SURFACE_UP] = loadSurface("img/up.bmp");
    if !gKeyPressSurfaces[Key_Press_Surfaces.KEY_PRESS_SURFACE_UP] {
        print("Failed to load default image!\n");
        success = false;
    }

    gKeyPressSurfaces[Key_Press_Surfaces.KEY_PRESS_SURFACE_DOWN] = loadSurface("img/down.bmp");
    if !gKeyPressSurfaces[Key_Press_Surfaces.KEY_PRESS_SURFACE_DOWN] {
        print("Failed to load down image!\n");
        success = false;
    }

    gKeyPressSurfaces[Key_Press_Surfaces.KEY_PRESS_SURFACE_LEFT] = loadSurface("img/left.bmp");
    if !gKeyPressSurfaces[Key_Press_Surfaces.KEY_PRESS_SURFACE_LEFT] {
        print("Failed to load left image!\n");
        success = false;
    }

    gKeyPressSurfaces[Key_Press_Surfaces.KEY_PRESS_SURFACE_RIGHT] = loadSurface("img/right.bmp");
    if !gKeyPressSurfaces[Key_Press_Surfaces.KEY_PRESS_SURFACE_RIGHT] {
        print("Failed to load right image!\n");
        success = false;
    }

    gKeyPressSurfaces[Key_Press_Surfaces.KEY_PRESS_SURFACE_STRETCH] = loadSurface("img/stretch.bmp");
    if !gKeyPressSurfaces[Key_Press_Surfaces.KEY_PRESS_SURFACE_STRETCH] {
        print("Failed to load stretch image!\n");
        success = false;
    }

    return success;
}

loadSurface :: (path: *u8) -> *SDL_Surface {

    optimizedSurface : *SDL_Surface;

    loadedSurface :=  IMG_Load(path);
    if !loadedSurface {
        print("Unable to load image %: %\n", path, SDL_GetError());
    } else {
        optimizedSurface = SDL_ConvertSurface(loadedSurface, gScreenSurface.format, 0);
        if !optimizedSurface {
            print("Unable to optimize image %: %\n", path, SDL_GetError());
        }
        SDL_FreeSurface(loadedSurface);
    }

    return optimizedSurface;
}

close :: () {
    SDL_FreeSurface(gStretchedSurface);

    SDL_DestroyWindow(gWindow);
    gWindow = null;

    SDL_Quit();
}
