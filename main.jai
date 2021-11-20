#import "Basic";
#import "SDL";
#import "SDL_image";

SCREEN_WIDTH  :: 640;
SCREEN_HEIGHT :: 480;

gWindow           : *SDL_Window;
gTexture          : *SDL_Texture;
gRenderer         : *SDL_Renderer;

main :: () {

    if !init() {
        print("Initialization failed!\n");
    } else {
        if !loadMedia() {
            print("Failed to load media!\n");
        } else {

            quit := false;
            e : SDL_Event;
            while !quit {
                while SDL_PollEvent(*e) {
                    if e.type == SDL_QUIT {
                        quit = true;
                    }
                }

                // clear screen
                SDL_RenderClear(gRenderer);

                // render texture to screen
                SDL_RenderCopy(gRenderer, gTexture, null, null);

                // update screen
                SDL_RenderPresent(gRenderer);
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

            gRenderer = SDL_CreateRenderer(gWindow, -1, .ACCELERATED);
            if !gRenderer {
                print("Failed to create renderer: %\n", SDL_GetError());
                success = false;
            } else {

                SDL_SetRenderDrawColor(gRenderer, 0xFF, 0xFF, 0xFF,0xFF);

                if !(IMG_Init(IMG_INIT_PNG) & cast(u32)IMG_INIT_PNG) {
                    print("Failed to initialize SDL_image: %s\n", IMG_GetError());
                    success = false;
                }
            }
        }
    }

    return success;
}

loadMedia :: () -> bool {
    success := true;

    gTexture = loadTexture("img/texture.png");
    if !gTexture {
        print("Failed to load texture image!\n");
        success = false;
    }

    return success;
}

loadTexture :: (path: *u8) -> *SDL_Texture {

    newTexture: *SDL_Texture;

    loadedSurface :=  IMG_Load(path);
    if !loadedSurface {
        print("Unable to load image %: %\n", path, SDL_GetError());
    } else {
        newTexture = SDL_CreateTextureFromSurface(gRenderer, loadedSurface);
        if !newTexture {
            print("Failed to create texture from %: %\n", path, SDL_GetError());
        }

        SDL_FreeSurface(loadedSurface);
    }

    return newTexture;
}

close :: () {

    SDL_DestroyTexture(gTexture);
    gTexture = null;

    SDL_DestroyRenderer(gRenderer);
    SDL_DestroyWindow(gWindow);
    gWindow = null;
    gRenderer = null;

    IMG_Quit();
    SDL_Quit();
}
