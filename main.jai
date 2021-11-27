#import "Basic";
#import "SDL";
#import "SDL_image";

SCREEN_WIDTH  : s32 : 640;
SCREEN_HEIGHT : s32 : 480;

gWindow:   *SDL_Window;
gRenderer: *SDL_Renderer;

gModulatedTexture: LTexture;

LTexture :: struct {
    mTexture: *SDL_Texture;
    mWidth:   s32;
    mHeight:  s32;
}

main :: () {

    if !init() {
        print("Initialization failed!\n");
    } else {
        if !loadMedia() {
            print("Failed to load media!\n");
        } else {
            quit := false;
            e : SDL_Event;

            red   : u8 = 255;
            green : u8 = 255;
            blue  : u8 = 255;

            while !quit {
                while SDL_PollEvent(*e) {
                    if e.type == SDL_QUIT {
                        quit = true;
                    } else if e.type == SDL_KEYDOWN {
                        if e.key.keysym.sym == {

                            case SDLK_q;
                                red += 32;
                            case SDLK_a;
                                red -= 32;

                            case SDLK_w;
                                green += 32;
                            case SDLK_s;
                                green -= 32;

                            case SDLK_e;
                                blue += 32;
                            case SDLK_d;
                                blue -= 32;
                        }
                    }
                }

                SDL_SetRenderDrawColor(gRenderer, 0xFF, 0xFF, 0xFF, 0xFF);
                SDL_RenderClear(gRenderer);

                SDL_SetTextureColorMod(gModulatedTexture.mTexture, red, blue, green);
                renderTexture(*gModulatedTexture, 0, 0);

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

    path :: "img/colors.png";
    gModulatedTexture = loadFromFile(path);
    if !gModulatedTexture.mTexture {
        print("Failed to load colored rectangle texture image\n");
        success = false;
    }

    return success;
}

loadFromFile :: (path: *u8) -> LTexture {

    lt: LTexture;

    newTexture: *SDL_Texture = null;

    loadedSurface := IMG_Load(path);
    if !loadedSurface {
        print("Unable to load image %: %\n", path, SDL_GetError());
    } else {

        SDL_SetColorKey(loadedSurface, SDL_TRUE, SDL_MapRGB(loadedSurface.format, 0x00, 0xFF, 0xFF));

        newTexture = SDL_CreateTextureFromSurface(gRenderer, loadedSurface);
        if !newTexture {
            print("Failed to create texture from %: %\n", path, SDL_GetError());
        } else {
            lt.mWidth  = loadedSurface.w;
            lt.mHeight = loadedSurface.h;
        }

        SDL_FreeSurface(loadedSurface);
    }

    lt.mTexture = newTexture;

    return lt;
}

renderTexture :: (lt: *LTexture, x: s32, y: s32, clip: *SDL_Rect = null) {

    renderQuad : SDL_Rect;
    renderQuad.x = x;
    renderQuad.y = y;
    renderQuad.w = ifx clip then clip.w else lt.mWidth;
    renderQuad.h = ifx clip then clip.h else lt.mHeight;

    SDL_RenderCopy(gRenderer, lt.mTexture, clip, *renderQuad);
}

close :: () {

    SDL_DestroyTexture(gModulatedTexture.mTexture);
    gModulatedTexture.mTexture = null;
    gModulatedTexture.mWidth = 0;
    gModulatedTexture.mHeight = 0;

    SDL_DestroyRenderer(gRenderer);
    SDL_DestroyWindow(gWindow);
    gWindow = null;
    gRenderer = null;

    IMG_Quit();
    SDL_Quit();
}
