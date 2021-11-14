#import "Basic";
#import "SDL";

SCREEN_WIDTH  :: 640;
SCREEN_HEIGHT :: 480;

gWindow : *SDL_Window;
gScreenSurface : *SDL_Surface;
gHelloWorld : *SDL_Surface;

main :: () {

    if !init() {
        print("Initialization failed!\n");
    } else {
        if !loadMedia() {
            print("Failed to load media!\n");
        } else {
            SDL_BlitSurface(gHelloWorld, null, gScreenSurface, null);
            SDL_UpdateWindowSurface(gWindow);
            SDL_Delay(2000);
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
        gWindow = SDL_CreateWindow("SDL TutTut", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_WIDTH, SDL_WINDOW_SHOWN);
        if !gWindow {
            print("Failed to create gWindow: %\n", SDL_GetError());
            success = false;
        } else {
            gScreenSurface = SDL_GetWindowSurface(gWindow);
        }
    }

    return success;
}

loadMedia :: () -> bool {
    success := true;

    imgFile :: "img/hello_word.bmp";
    gHelloWorld =  SDL_LoadBMP(imgFile);
    if !gHelloWorld {
            print("Unable to load image %: %\n", imgFile, SDL_GetError());
            success = false;
    }

    return success;
}

close :: () {
    SDL_FreeSurface(gHelloWorld);
    gHelloWorld = null;

    SDL_DestroyWindow(gWindow);
    gWindow = null;

    SDL_Quit();
}
