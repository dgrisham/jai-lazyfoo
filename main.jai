#import "Basic";
#import "SDL";
#import "SDL_image";

SCREEN_WIDTH  :: cast(s32)640;
SCREEN_HEIGHT :: cast(s32)480;

gWindow:   *SDL_Window;
gRenderer: *SDL_Renderer;

gFooTexture:        LTexture;
gBackgroundTexture: LTexture;

gSpriteClips: [4]SDL_Rect;
gSpriteSheetTexture: LTexture;

LTexture :: struct {
    mTexture: *SDL_Texture;
    mWidth:   s32;
    mHeight:  s32;
}

renderSprite :: (lt: *LTexture, x: s32, y: s32, clip: *SDL_Rect = null) {

    renderQuad : SDL_Rect;
    renderQuad.x = x;
    renderQuad.y = y;
    renderQuad.w = ifx clip then clip.w else lt.mWidth;
    renderQuad.h = ifx clip then clip.h else lt.mHeight;

    SDL_RenderCopy(gRenderer, lt.mTexture, clip, *renderQuad);
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
            while !quit {
                while SDL_PollEvent(*e) {
                    if e.type == SDL_QUIT {
                        quit = true;
                    }
                }

                SDL_SetRenderDrawColor(gRenderer, 0xFF, 0xFF, 0xFF, 0xFF);
                SDL_RenderClear(gRenderer);

                renderSprite(*gSpriteSheetTexture, 0, 0, *gSpriteClips[0]);
                renderSprite(*gSpriteSheetTexture, SCREEN_WIDTH - gSpriteClips[1].w, 0, *gSpriteClips[1]);
                renderSprite(*gSpriteSheetTexture, 0, SCREEN_HEIGHT - gSpriteClips[2].h, *gSpriteClips[2]);
                renderSprite(*gSpriteSheetTexture, SCREEN_WIDTH - gSpriteClips[3].w, SCREEN_HEIGHT - gSpriteClips[3].h, *gSpriteClips[3]);

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

    dotsPath :: "img/dots.png";
    gSpriteSheetTexture = loadFromFile(dotsPath);
    if !gSpriteSheetTexture.mTexture {
        print("Failed to load background texture image\n");
        success = false;
    } else {
        gSpriteClips[0] = .{
            x = 0,
            y = 0,
            w = 100,
            h = 100,
        };
        gSpriteClips[1] = .{
            x = 100,
            y = 0,
            w = 100,
            h = 100,
        };
        gSpriteClips[2] = .{
            x = 0,
            y = 100,
            w = 100,
            h = 100,
        };
        gSpriteClips[3] = .{
            x = 100,
            y = 100,
            w = 100,
            h = 100,
        };
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

close :: () {

    SDL_DestroyTexture(gFooTexture.mTexture);
    gFooTexture.mTexture = null;
    gFooTexture.mWidth = 0;
    gFooTexture.mHeight = 0;

    SDL_DestroyTexture(gBackgroundTexture.mTexture);
    gBackgroundTexture.mTexture = null;
    gBackgroundTexture.mWidth = 0;
    gBackgroundTexture.mHeight = 0;

    SDL_DestroyRenderer(gRenderer);
    SDL_DestroyWindow(gWindow);
    gWindow = null;
    gRenderer = null;

    IMG_Quit();
    SDL_Quit();
}
