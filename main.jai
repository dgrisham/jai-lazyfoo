#import "Basic";
#import "SDL";
#import "SDL_image";

SCREEN_WIDTH  :: cast(s32)640;
SCREEN_HEIGHT :: cast(s32)480;

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

            topLeftViewport :: SDL_Rect.{
                x = 0,
                y = 0,
                w = SCREEN_WIDTH / 2,
                h = SCREEN_HEIGHT / 2,
            };

            topRightViewport :: SDL_Rect.{
                x = SCREEN_WIDTH / 2,
                y = 0,
                w = SCREEN_WIDTH / 2,
                h = SCREEN_HEIGHT / 2,
            };

            bottomViewport :: SDL_Rect.{
                x = 0,
                y = SCREEN_HEIGHT / 2,
                w = SCREEN_WIDTH,
                h = SCREEN_HEIGHT / 2,
            };

            quit := false;
            e : SDL_Event;
            while !quit {
                while SDL_PollEvent(*e) {
                    if e.type == SDL_QUIT {
                        quit = true;
                    }
                }

                SDL_SetRenderDrawColor(gRenderer, 0xFF, 0xFF, 0xFF, 0xFF);
                SDL_RenderClear(gRenderer);

                SDL_RenderSetViewport(gRenderer, *topLeftViewport);
                SDL_RenderCopy(gRenderer, gTexture, null, null);

                SDL_RenderSetViewport(gRenderer, *topRightViewport);
                SDL_RenderCopy(gRenderer, gTexture, null, null);

                SDL_RenderSetViewport(gRenderer, *bottomViewport);
                SDL_RenderCopy(gRenderer, gTexture, null, null);

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

    path :: "img/viewport.png";
    gTexture = loadTexture(path);
    if !gTexture {
        print("Failed to load texture %: %\n", path, gTexture);
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
