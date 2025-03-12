#include <slog/slog.h>
#include <stdio.h>

#define CLAY_IMPLEMENTATION
#include <clay/clay.h>

#include <clay/renderers/raylib/clay_renderer_raylib.c>

#include "raylib.h"
#include "raymath.h"

#define WIDTH 800
#define HEIGHT 600

void handle_clay_errors(Clay_ErrorData errorData) {
  slog_error("%s", errorData.errorText.chars);

  switch (errorData.errorType) {
    // etc
  }
}
const Clay_Color COLOR_LIGHT = (Clay_Color){224, 215, 210, 255};
const Clay_Color COLOR_RED = (Clay_Color){168, 66, 28, 255};
const Clay_Color COLOR_ORANGE = (Clay_Color){225, 138, 50, 255};

int main(int argc, char** argv) {
  uint64_t totalMemorySize = Clay_MinMemorySize();
  Clay_Arena arena = Clay_CreateArenaWithCapacityAndMemory(
      totalMemorySize, malloc(totalMemorySize));

  Clay_Raylib_Initialize(WIDTH, HEIGHT, "Introducing Clay Demo",
                         FLAG_WINDOW_RESIZABLE | FLAG_WINDOW_HIGHDPI |
                             FLAG_MSAA_4X_HINT | FLAG_VSYNC_HINT);

  Clay_Context* ctx =
      Clay_Initialize(arena,
                      (Clay_Dimensions){.width = GetScreenWidth(),
                                        .height = GetScreenHeight() / 2},
                      (Clay_ErrorHandler){handle_clay_errors});
  Font font[] = {GetFontDefault()};
  while (!WindowShouldClose()) {
    Clay_SetLayoutDimensions(
        (Clay_Dimensions){GetScreenWidth(), GetScreenHeight()});

    Clay_BeginLayout();
    CLAY({.id = CLAY_ID("OuterContainer"),
          .layout = {.sizing = {CLAY_SIZING_GROW(0), CLAY_SIZING_GROW(0)},
                     .padding = CLAY_PADDING_ALL(16),
                     .childGap = 16},
          .backgroundColor = {250, 250, 255, 255}}) {
      CLAY({.id = CLAY_ID("SideBar"),
            .layout = {.layoutDirection = CLAY_TOP_TO_BOTTOM,
                       .sizing = {.width = CLAY_SIZING_FIXED(300),
                                  .height = CLAY_SIZING_GROW(0)},
                       .padding = CLAY_PADDING_ALL(16),
                       .childGap = 16},
            .backgroundColor = COLOR_LIGHT}) {
        CLAY({.id = CLAY_ID("ProfilePictureOuter"),
              .layout = {.sizing = {.width = CLAY_SIZING_GROW(0)},
                         .padding = CLAY_PADDING_ALL(16),
                         .childGap = 16,
                         .childAlignment = {.y = CLAY_ALIGN_Y_CENTER}},
              .backgroundColor = COLOR_RED}) {
          CLAY_TEXT(CLAY_STRING("Clay - UI Library"),
                    CLAY_TEXT_CONFIG(
                        {.fontSize = 24, .textColor = {255, 255, 255, 255}}));
        }

        CLAY({.id = CLAY_ID("MainContent"),
              .layout = {.sizing = {.width = CLAY_SIZING_GROW(0),
                                    .height = CLAY_SIZING_GROW(0)}},
              .backgroundColor = COLOR_LIGHT}) {}
      }
    }
    Clay_RenderCommandArray renderCommands = Clay_EndLayout();

    BeginDrawing();
    ClearBackground(BLACK);
    Clay_Raylib_Render(renderCommands, font);
    EndDrawing();
  }
  return 0;
}